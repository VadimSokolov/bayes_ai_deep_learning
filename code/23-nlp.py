# Code of chapter: Natural Language Processing
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/23-nlp.py. Data are read from the data folder.
# Data: data/embedding_words.txt, data/warpeace.txt
# Packages: collections, gensim, matplotlib, numpy, sklearn

# ---- Global Vectors and Matrix Factorization -------------------------------

from gensim.models import Word2Vec
from sklearn.decomposition import PCA

# define training data, read from data/warpeace.txt
with open('data/warpeace.txt', 'r') as file:
    Text = file.read()
sentences = [s.split() for s in Text.split('. ')]  # split the text into sentences
# Strip punctuation from each word and drop empty tokens
sentences = [[word.strip('.,!?;:()[]') for word in sentence if word.strip('.,!?;:()[]')] for sentence in sentences]

# Remove empty sentences
sentences = [sentence for sentence in sentences if sentence]
model = Word2Vec(sentences, vector_size=100, window=5, min_count=1, seed=42, workers=1)
# fit a 2d PCA model to the vectors, only use the words from data/embedding_words.txt
with open('data/embedding_words.txt', 'r') as file:
    words = file.read().splitlines()
X = model.wv[words]  # get the vectors for the words
# reduce the dimensionality of the vectors to 2D using PCA
pca = PCA(n_components=2)
result = pca.fit_transform(X)

import matplotlib.pyplot as plt

# create a scatter plot of the projection
fig, ax = plt.subplots(figsize=(10, 4))
ax.scatter(result[:, 0], result[:, 1])
ax.set_xlabel('PC 1')
ax.set_ylabel('PC 2')

for i, word in enumerate(words):
    if word == 'society':
        ax.annotate(word, xy=(result[i, 0], result[i, 1]), xytext=(-5, 0), textcoords='offset points', ha='right', va='center')
    else:
        ax.annotate(word, xy=(result[i, 0], result[i, 1]), xytext=(5, 0), textcoords='offset points', ha='left', va='center')

# Remove top and right borders
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
plt.show()

# ---- Attention Mechanisms and Contextual Representations -------------------

# [fig-kernel-smoothing]
import numpy as np
import matplotlib.pyplot as plt

# Generate some data
np.random.seed(42)
x1 = np.random.uniform(0, 1, 100)
x2 = np.random.uniform(0, 1, 100)
y = np.sin(2 * np.pi * x1) + x2*x2+ np.random.normal(0, 0.1, 100)

plt.scatter(x1, x2, c=y, cmap='viridis')
plt.colorbar();
plt.show()

def gaussian_kernel_smoothing(X1, X2, x1_train, x2_train, y_train, bandwidth=0.1):
    # Get the shape of the grid
    shape = X1.shape
    
    # Flatten the grid points for easier computation
    X1_flat = X1.flatten()
    X2_flat = X2.flatten()
    
    # Initialize predictions array
    y_pred_flat = np.zeros(len(X1_flat))
    
    # For each test point, compute weighted average using Gaussian kernel
    for i in range(len(X1_flat)):
        test_x1, test_x2 = X1_flat[i], X2_flat[i]
        
        # Compute distances from test point to all training points
        distances_squared = (x1_train - test_x1)**2 + (x2_train - test_x2)**2
        
        # Compute Gaussian weights
        weights = np.exp(-distances_squared / (2 * bandwidth**2))
        
        # Compute weighted average (kernel smoothing prediction)
        if np.sum(weights) > 0:
            y_pred_flat[i] = np.sum(weights * y_train) / np.sum(weights)
        else:
            y_pred_flat[i] = 0  # fallback if all weights are zero
    
    # Reshape back to grid shape
    y_pred = y_pred_flat.reshape(shape)
    
    return y_pred

# [smoothing_debug]
import numpy as np
import matplotlib.pyplot as pyplot

# Generate grid data for x1 and x2 (test data)
x1 = np.linspace(0, 1, 100)
x2 = np.linspace(0, 1, 100)
# Now compute the grid of x1 and x2 values
X1, X2 = np.meshgrid(x1, x2)

# Generate training data
np.random.seed(42)
x1_train = np.random.uniform(0, 1, 100)
x2_train = np.random.uniform(0, 1, 100)
y_train = np.sin(2 * np.pi * x1_train) + x2_train*x2_train + np.random.normal(0, 0.1, 100)


# Test the function with the existing data
y_pred = gaussian_kernel_smoothing(X1, X2, x1_train, x2_train, y_train, bandwidth=0.1)

# Plot comparison between true function and kernel smoothing prediction
fig, axes = pyplot.subplots(1, 3, figsize=(5.5, 2.0))

# True function (without noise for cleaner visualization)
y_true = np.sin(2 * np.pi * X1) + X2*X2
lev = np.linspace(min(y_true.min(), y_pred.min()), max(y_true.max(), y_pred.max()), 21)

# Plot 1: True function
im1 = axes[0].contourf(X1, X2, y_true, levels=lev, cmap='viridis')
axes[0].scatter(x1_train, x2_train, c='white', edgecolors='black', marker='o', s=6, linewidths=0.5)
axes[0].set_title('True Function')
axes[0].set_xlabel('$x_1$')
axes[0].set_ylabel('$x_2$')
pyplot.colorbar(im1, ax=axes[0]);

# Plot 2: Kernel smoothing prediction
im2 = axes[1].contourf(X1, X2, y_pred, levels=lev, cmap='viridis')
axes[1].scatter(x1_train, x2_train, c='white', edgecolors='black', marker='o', s=6, linewidths=0.5)
axes[1].set_title('Gaussian Kernel Smoothing')
axes[1].set_xlabel('$x_1$')
axes[1].set_ylabel('$x_2$')
pyplot.colorbar(im2, ax=axes[1]);

# Plot 3: Difference (error)
diff = y_true - y_pred
im3 = axes[2].contourf(X1, X2, diff, levels=20, cmap='cividis')
axes[2].scatter(x1_train, x2_train, c='white', edgecolors='black', marker='o', s=6, linewidths=0.5)
axes[2].set_title('Error (True - Predicted)')
axes[2].set_xlabel('$x_1$')
axes[2].set_ylabel('$x_2$')
plt.colorbar(im3, ax=axes[2]);

for ax in fig.axes:
    ax.tick_params(labelsize=6)
    ax.title.set_fontsize(7)
    ax.xaxis.label.set_fontsize(8)
    ax.yaxis.label.set_fontsize(8)
plt.tight_layout()
plt.show()

# ---- Skip-Gram with Negative Sampling --------------------------------------

corpus = [
    "king queen throne", "queen king throne", "king queen palace", "queen king crown",
    "king throne crown", "queen throne palace", "king palace crown", "queen palace crown",
    "dog cat pet", "cat dog pet", "dog cat animal", "cat dog leash",
    "dog animal leash", "cat animal pet", "dog leash pet", "cat leash animal",
]
sentences = [s.split() for s in corpus]

# ---- GloVe from Global Co-occurrence Counts --------------------------------

vocab = ["gas", "ice", "solid", "steam", "water"]
idx = {w: i for i, w in enumerate(vocab)}
counts = {
    ("ice", "steam"): 3, ("ice", "solid"): 9, ("ice", "gas"): 1, ("ice", "water"): 5,
    ("steam", "solid"): 1, ("steam", "gas"): 9, ("steam", "water"): 5,
    ("solid", "gas"): 1, ("solid", "water"): 3, ("gas", "water"): 3,
}

# ---- Self-Attention from Scratch -------------------------------------------

import numpy as np

tokens = ["dog", "puppy", "car", "vehicle"]
X = np.array([
    [1.0, 0.5, 0.0],
    [0.9, 0.3, 0.0],
    [0.0, 0.4, 1.0],
    [0.0, 0.6, 0.9],
])

# ---- Byte Pair Encoding from Scratch ---------------------------------------

from collections import defaultdict

corpus = {"fast": 4, "faster": 3, "tall": 5, "taller": 4}
vocab = {tuple(word) + ("</w>",): freq for word, freq in corpus.items()}

# ---- Masked Language Modeling from Scratch ---------------------------------

corpus = [
    "the king rules the kingdom", "the queen rules the kingdom",
    "the king loves the queen",   "the queen loves the king",
    "the king guards the castle",  "the queen guards the castle",
    "the dog chases the ball",     "the cat chases the ball",
    "the dog sleeps on mat",       "the cat sleeps on mat",
    "the king sleeps on throne",   "the dog guards the castle",
]
sentences = [s.split() for s in corpus]
vocab = sorted(set(w for s in sentences for w in s))
word2id = {w: i for i, w in enumerate(vocab)}
Vsz = len(vocab)
MASK = Vsz  # id reserved for the [MASK] token
