"""
HKJC Data Preparation Script
============================
Prepares Hong Kong Jockey Club race data for the Benter combined model analysis.

This script:
1. Downloads HKJC race data from Kaggle (if not already present)
2. Computes historical jockey and trainer win rates (avoiding lookahead bias)
3. Normalizes draw positions and horse ratings within each race
4. Outputs a clean dataset ready for the combined model analysis

Data Sources:
- gdaley/hkracing: https://www.kaggle.com/datasets/gdaley/hkracing (1997-2005)

Usage:
    python code/13-logistic-hkjc-prepare.py   (run from the book folder)

Output:
    data/df_hkjc_with_factors.csv
"""

import pandas as pd
import numpy as np
import os
import subprocess
from pathlib import Path


def download_kaggle_data(data_dir: Path) -> bool:
    """Download HKJC data from Kaggle if not present."""
    races_file = data_dir / "races.csv"
    runs_file = data_dir / "runs.csv"
    
    if races_file.exists() and runs_file.exists():
        print("Kaggle data already downloaded.")
        return True
    
    print("Downloading data from Kaggle...")
    data_dir.mkdir(parents=True, exist_ok=True)
    
    # Try to download using curl (works without Kaggle API key for public datasets)
    zip_file = data_dir / "hkracing.zip"
    url = "https://www.kaggle.com/api/v1/datasets/download/gdaley/hkracing"
    
    try:
        result = subprocess.run(
            ["curl", "-L", url, "-o", str(zip_file)],
            capture_output=True, text=True, timeout=120
        )
        if result.returncode == 0 and zip_file.exists():
            subprocess.run(["unzip", "-o", str(zip_file), "-d", str(data_dir)])
            return True
    except Exception as e:
        print(f"Download failed: {e}")
    
    print("Please download manually from: https://www.kaggle.com/datasets/gdaley/hkracing")
    return False


def compute_cumulative_stats(df: pd.DataFrame, group_col: str, 
                              prefix: str) -> pd.DataFrame:
    """
    Compute cumulative win rate for a grouping variable (jockey/trainer).
    
    Uses a shifted cumulative sum to avoid lookahead bias - each row gets
    the win rate computed from all PRIOR races only.
    """
    stats_list = []
    
    for group_id in df[group_col].unique():
        group_data = df[df[group_col] == group_id].copy()
        group_data = group_data.sort_values("date")
        
        # Cumulative wins and rides (shifted by 1 to exclude current race)
        group_data["cum_wins"] = group_data["win"].cumsum().shift(1, fill_value=0)
        group_data["cum_rides"] = np.arange(len(group_data))
        group_data["cum_rides"] = group_data["cum_rides"].clip(lower=1)
        
        # Win rate
        group_data[f"{prefix}_win_rate"] = (
            group_data["cum_wins"] / group_data["cum_rides"]
        )
        group_data[f"{prefix}_rides"] = group_data["cum_rides"]
        
        stats_list.append(
            group_data[["race_id", "horse_no", f"{prefix}_win_rate", f"{prefix}_rides"]]
        )
    
    return pd.concat(stats_list, ignore_index=True)


def prepare_hkjc_data(data_dir: str = "data/hkjc", 
                       output_file: str = "data/df_hkjc_with_factors.csv",
                       min_history_days: int = 180) -> pd.DataFrame:
    """
    Prepare HKJC data with fundamental factors for combined model analysis.
    
    Parameters
    ----------
    data_dir : str
        Directory containing races.csv and runs.csv from Kaggle
    output_file : str
        Path for output CSV file
    min_history_days : int
        Number of days to skip at start for reliable historical stats
        
    Returns
    -------
    pd.DataFrame
        Processed dataset with fundamental factors
    """
    data_dir = Path(data_dir)
    
    # Download data if needed
    if not download_kaggle_data(data_dir):
        raise FileNotFoundError("Could not obtain Kaggle data")
    
    print("Loading raw data...")
    runs = pd.read_csv(data_dir / "runs.csv")
    races = pd.read_csv(data_dir / "races.csv")
    
    # Merge runs with race info
    df = runs.merge(
        races[["race_id", "date", "venue", "distance", "going", "race_class"]], 
        on="race_id"
    )
    
    # Basic cleaning
    df["date"] = pd.to_datetime(df["date"])
    df["win"] = df["won"].astype(int)
    df["win_odds"] = pd.to_numeric(df["win_odds"], errors="coerce")
    
    # Filter valid odds
    df = df[df["win_odds"] > 0].copy()
    df = df[df["win_odds"] < 200].copy()
    
    # Calculate implied probability and normalize within race. HKJC win odds
    # are dividends (a winning $1 returns win_odds, stake included), so the
    # implied probability is 1/win_odds; its race sum is 1/(1 - take).
    df["implied_prob"] = 1 / df["win_odds"]
    prob_sums = df.groupby("race_id")["implied_prob"].transform("sum")
    df["public_prob"] = df["implied_prob"] / prob_sums
    
    # Field size filter
    df["field_size"] = df.groupby("race_id")["horse_no"].transform("count")
    df = df[df["field_size"] >= 5].copy()
    
    # Sort chronologically
    df = df.sort_values(["date", "race_id", "horse_no"]).reset_index(drop=True)
    
    print(f"Base dataset: {len(df):,} rows, {df['race_id'].nunique():,} races")
    print(f"Date range: {df['date'].min().date()} to {df['date'].max().date()}")
    
    # Compute historical jockey stats
    print("Computing historical jockey statistics...")
    jockey_stats = compute_cumulative_stats(df, "jockey_id", "jockey")
    df = df.merge(jockey_stats, on=["race_id", "horse_no"], how="left")
    
    # Compute historical trainer stats
    print("Computing historical trainer statistics...")
    trainer_stats = compute_cumulative_stats(df, "trainer_id", "trainer")
    df = df.merge(trainer_stats, on=["race_id", "horse_no"], how="left")
    
    # Fill missing stats with overall mean
    overall_win_rate = df["win"].mean()
    df["jockey_win_rate"] = df["jockey_win_rate"].fillna(overall_win_rate)
    df["trainer_win_rate"] = df["trainer_win_rate"].fillna(overall_win_rate)
    
    # Normalize draw within race (positive = outside, negative = inside)
    df["draw_normalized"] = df.groupby("race_id")["draw"].transform(
        lambda x: (x - x.mean()) / x.std() if x.std() > 0 else 0
    )
    
    # Horse rating relative to field average
    df["rating_diff"] = df.groupby("race_id")["horse_rating"].transform(
        lambda x: x - x.mean()
    )
    
    # Weight relative to field average
    df["weight_diff"] = df.groupby("race_id")["actual_weight"].transform(
        lambda x: x - x.mean()
    )
    
    # Select final columns
    df_final = df[[
        "race_id", "date", "venue", "horse_no", "horse_id",
        "win", "win_odds", "public_prob", "field_size",
        "draw", "draw_normalized", "actual_weight", "weight_diff",
        "horse_rating", "rating_diff",
        "jockey_id", "jockey_win_rate", "jockey_rides",
        "trainer_id", "trainer_win_rate", "trainer_rides",
        "distance", "going", "race_class"
    ]].copy()
    
    # Remove initial period where historical stats are unreliable
    min_date = df_final["date"].min() + pd.Timedelta(days=min_history_days)
    df_final = df_final[df_final["date"] >= min_date].copy()
    
    print(f"\nFinal dataset: {len(df_final):,} rows, {df_final['race_id'].nunique():,} races")
    print(f"Date range: {df_final['date'].min().date()} to {df_final['date'].max().date()}")
    
    # Summary statistics
    print("\nFundamental factors summary:")
    print(f"  Jockey win rate:  mean={df_final['jockey_win_rate'].mean():.3f}, "
          f"std={df_final['jockey_win_rate'].std():.3f}")
    print(f"  Trainer win rate: mean={df_final['trainer_win_rate'].mean():.3f}, "
          f"std={df_final['trainer_win_rate'].std():.3f}")
    print(f"  Draw: range={df_final['draw'].min()}-{df_final['draw'].max()}")
    print(f"  Horse rating: range={df_final['horse_rating'].min()}-"
          f"{df_final['horse_rating'].max()}")
    
    # Save
    df_final.to_csv(output_file, index=False)
    print(f"\nSaved to {output_file}")
    
    return df_final


if __name__ == "__main__":
    prepare_hkjc_data()

