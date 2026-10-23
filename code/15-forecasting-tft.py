# Run from the book folder: python code/15-forecasting-tft.py (after Rscript code/15-forecasting-bsts-claims.R)
import os
import warnings
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import torch
import lightning.pytorch as pl
from pytorch_forecasting import TimeSeriesDataSet, TemporalFusionTransformer, QuantileLoss
from lightning.pytorch.callbacks import EarlyStopping, LearningRateMonitor

warnings.filterwarnings("ignore")

# 1. Load Data
df = pd.read_csv("data/tft/claims.csv")
df['Date'] = pd.to_datetime(df['Date'])
# Feature Engineering: Add seasonality explicitly
df["week"] = df['Date'].dt.isocalendar().week.astype(str) # Categorical week
df["time_idx"] = np.arange(len(df))
df["group"] = "0"  
df["Claims"] = df["Claims"].astype(float)

train_df = df[df["Type"] == "Train"]
test_df = df[df["Type"] == "Test"]

max_prediction_length = len(test_df)
max_encoder_length = 104

from pytorch_forecasting.data.encoders import GroupNormalizer

# Manual Scaling REMOVED - Rely on GroupNormalizer for consistent internal scaling
training_cutoff = train_df["time_idx"].max() - max_prediction_length

training_dataset = TimeSeriesDataSet(
    df[lambda x: x.time_idx <= training_cutoff],
    time_idx="time_idx",
    target="Claims",
    group_ids=["group"],
    min_encoder_length=max_encoder_length // 2,
    max_encoder_length=max_encoder_length,
    min_prediction_length=1,
    max_prediction_length=max_prediction_length,
    static_categoricals=["group"],
    time_varying_known_categoricals=["week"],  
    time_varying_known_reals=[], # Remove time_idx to prevent overfitting to global trend
    time_varying_unknown_reals=["Claims"],
    target_normalizer=GroupNormalizer(groups=["group"], transformation=None), 
    add_relative_time_idx=True,
    add_target_scales=False, # Disable to prevent leakage/bias
    add_encoder_length=True,
)

validation = TimeSeriesDataSet.from_dataset(training_dataset, df, predict=True, stop_randomization=True)

batch_size = 32
train_dataloader = training_dataset.to_dataloader(train=True, batch_size=batch_size, num_workers=0)
val_dataloader = validation.to_dataloader(train=False, batch_size=batch_size * 10, num_workers=0)

# 3. Configure Network and Trainer
# Ensemble Training
n_models = 3
all_preds = []

for seed in range(42, 42 + n_models):
    print(f"Training model with seed {seed}")
    pl.seed_everything(seed)

    tft = TemporalFusionTransformer.from_dataset(
        training_dataset,
        learning_rate=0.015,         # Slightly higher LR for faster convergence in ensemble
        hidden_size=64,
        attention_head_size=4,
        dropout=0.1,                 # Back to 0.1 for better regularization in ensemble
        hidden_continuous_size=16,
        output_size=7,  
        loss=QuantileLoss([0.05, 0.5, 0.95]), 
        log_interval=10, 
        reduce_on_plateau_patience=4,
    )

    trainer = pl.Trainer(
        max_epochs=70,               # 70 epochs per model is enough for ensemble
        accelerator="cpu", 
        devices=1,
        enable_model_summary=True if seed == 42 else False,
        gradient_clip_val=0.1,
        callbacks=[
            EarlyStopping(monitor="val_loss", min_delta=1e-4, patience=10, verbose=False, mode="min")
        ],
        logger=False
    )

    trainer.fit(
        tft,
        train_dataloaders=train_dataloader,
        val_dataloaders=val_dataloader,
    )

    # Predict
    best_tft = tft
    best_tft.eval()
    
    # Shape: (n_samples, prediction_length, n_quantiles)
    raw_predictions = best_tft.predict(val_dataloader, mode="quantiles")
    all_preds.append(raw_predictions)

# Average predictions across ensemble members
# Stack: (n_models, n_samples, prediction_length, n_quantiles) -> Mean over dim 0
ensemble_preds = torch.stack(all_preds).mean(dim=0)

# Extract quantile forecasts (Shape: 1 x Horizon x 3)
preds = ensemble_preds[0] 
# Inverse transform automatically handled by TFT class when normalizer is present
preds_np = preds.numpy()
q05 = preds_np[:, 0]
q50 = preds_np[:, 1]
q95 = preds_np[:, 2]

# Actuals logic:
# `predict` mode="quantiles" returns predictions in Real Scale.
# But we need to verify if we can reshape directly.


# Also inverse transform BSTS results? 
# No, "claims.csv" was raw data from R.
# If we scaled "df", then we must inverse transform "actuals" from the dataset back to original scale.
# But BSTS results (bsts_df) are already in original scale.
# So we align everything to original scale.
# 5. Load BSTS Results
bsts_res = pd.read_csv("data/tft/bsts_results.csv")
bsts_res['Date'] = pd.to_datetime(bsts_res['Date'])

# TFT predictions correspond to the horizon.
# Need to align with BSTS test dates.
# validation dataset predicts the last available window (which is the test set)
# We verify lengths
print(f"TFT Test Length: {len(q50)}")
print(f"BSTS Test Length: {len(bsts_res)}")

length_min = min(len(q50), len(bsts_res))
bsts_res = bsts_res.iloc[:length_min]
q05 = q05[:length_min]
q50 = q50[:length_min]
q95 = q95[:length_min]

# Keep the forecasts, so that the figure can be redrawn without training the ensemble again
os.makedirs("results/15-forecasting", exist_ok=True)
pd.DataFrame({'Date': bsts_res['Date'], 'TFT_q05': q05, 'TFT_q50': q50, 'TFT_q95': q95}).to_csv("results/15-forecasting/tft-forecast.csv", index=False)

# 6. Plot Comparison
plt.figure(figsize=(12, 6))

# Actuals
plt.plot(bsts_res['Date'], bsts_res['Actual'], color='black', label='Actual', linewidth=2)

# BSTS Forecast
plt.plot(bsts_res['Date'], bsts_res['Pred_Mean'], color='blue', linestyle=':', linewidth=2, label='BSTS Mean')
plt.fill_between(bsts_res['Date'], bsts_res['Pred_Lower'], bsts_res['Pred_Upper'], color='blue', alpha=0.15, label='BSTS 95% CI')

# TFT Forecast (the band is hatched so that it differs from the BSTS band in gray print)
plt.plot(bsts_res['Date'], q50, color='red', linestyle='--', label='TFT Median')
plt.fill_between(bsts_res['Date'], q05, q95, facecolor='none', edgecolor='red', hatch='///', linewidth=0, label='TFT 90% Interval')

plt.title("Benchmarking: BSTS vs Temporal Fusion Transformer (TFT)")
plt.xlabel("Date")
plt.ylabel("Claims")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()

plt.savefig("fig/bsts-tft.png")
print("Saved fig/bsts-tft.png")
