# Code of chapter: Neural Networks
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/18-nn.py. Data are read from the data folder.
# Packages: numpy

# ---- Autoencoder Bottleneck versus PCA -------------------------------------

import numpy as np

np.random.seed(0)
M, K, N = 6, 2, 300                                # ambient dimension, true rank, sample size
B, _ = np.linalg.qr(np.random.randn(M, K))         # M x K orthonormal loading directions
Z = np.random.randn(N, K) @ np.diag([3.0, 1.0])    # latent factors on unequal scales
X = Z @ B.T + 0.05 * np.random.randn(N, M)         # M-dim data near a K-dim subspace
X = X - X.mean(axis=0)
