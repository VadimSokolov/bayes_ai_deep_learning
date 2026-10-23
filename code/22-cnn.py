# Code of chapter: Convolutional Neural Networks
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/22-cnn.py. Data are read from the data folder.
# Data: data/img-filter.tsv, data/img-x.tsv, data/t10k-images-idx3-ubyte.gz, data/t10k-labels-idx1-ubyte.gz
# Packages: array, gzip, jax, matplotlib, numpy, struct, torch

# ---- Key Concepts ----------------------------------------------------------

# [fig-conv1d]
import matplotlib.pyplot as plt

from jax import random
import jax.numpy as jnp
import numpy as np

key = random.PRNGKey(1701)

x = jnp.linspace(0, 10, 500)
y = jnp.sin(x) + 0.2 * random.normal(key, shape=(500,))

window = jnp.ones(10) / 10
y_smooth = jnp.convolve(y, window, mode='same')

plt.plot(x, y, 'lightgray')
plt.plot(x, y_smooth, 'black');

# ---- A Toy Example ---------------------------------------------------------

# [conv2d]
img = np.genfromtxt("data/img-x.tsv", delimiter="\t")
imgx = img[0:5,:]
imgd = img[5:10,:]
imgrd = img[10:15,:]
for im, name in [(imgx, 'Cross'), (imgd, 'Diagonal'), (imgrd, 'Right-Diagonal')]:
    plt.figure(figsize=(1.74, 1.5))
    plt.imshow(im, cmap='binary'); plt.title(name, fontsize=7); plt.tick_params(labelsize=6)
    plt.tight_layout(pad=0.3); plt.show()

# [conv2d1]
f = np.genfromtxt("data/img-filter.tsv", delimiter="\t")
f1 = f[0:3,:]
f2 = f[3:6,:]
plt.imshow(f1, cmap='binary'); plt.title(f'Filter 1'); plt.show();
plt.imshow(f2, cmap='binary'); plt.title(f'Filter 2'); plt.show();

def conv(img, f):
    out = np.zeros((3,3))
    for i in range(3):
        for j in range(3):
            out[i,j] = np.sum(img[i:i+3,j:j+3]*f)
    return out
def maxpool(img):
    return np.max(img)
def fc(x, w, b):
    return jnp.dot(w,x) + b
def softmax(x):
    return jnp.exp(x) / jnp.sum(jnp.exp(x))

def cnn(img, f1, f2):
    out1 = conv(img,f1)
    out2 = conv(img,f2)
    x = np.array([maxpool(out1), maxpool(out2)])
    w = np.array([[1,0],[0,1],[0.6,0.6]])
    b = 0
    z = fc(x,w,b)
    return softmax(z),out1,out2

# [conv2d2]
zx, outx1, outx2 = cnn(imgx,f1,f2)
plt.imshow(outx1, cmap='binary'); plt.title(f'Output 1'); plt.show();
plt.imshow(outx2, cmap='binary'); plt.title(f'Output 2'); plt.show();

# [conv2d3]
zd, outd1, outd2 = cnn(imgd,f1,f2)
plt.imshow(outd1, vmin=0,vmax=3,cmap='binary'); plt.title(f'Output 1');  plt.show();
plt.imshow(outd2, vmin=0,vmax=3, cmap='binary'); plt.title(f'Output 2'); plt.show();

# [conv2d4]
zrd, outrd1, outrd2 = cnn(imgrd,f1,f2)
print(f'Cross: {zx}')
print(f'Diagonal: {zd}')
print(f'Right-Diagonal: {zrd}')

# ---- The MNIST Dataset -----------------------------------------------------

# [load-mnist]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# import gzip
# import struct
# import array
# import numpy as np
# import matplotlib.pyplot as plt

# def parse_labels(filename):
#     with gzip.open(filename, "rb") as fh:
#         _ = struct.unpack(">II", fh.read(8))
#         return np.array(array.array("B", fh.read()), dtype=np.uint8)
# def parse_images(filename):
#     with gzip.open(filename, "rb") as fh:
#         _, num_data, rows, cols = struct.unpack(">IIII", fh.read(16))
#         return np.array(array.array("B", fh.read()),dtype=np.uint8).reshape(num_data, rows, cols)
# x = parse_images("data/t10k-images-idx3-ubyte.gz")
# y = parse_labels("data/t10k-labels-idx1-ubyte.gz")
# plt.imshow(x[0,:,:], cmap='gray'); plt.title(f'Label: {y[0]}'); plt.show()
# plt.imshow(x[1,:,:], cmap='gray'); plt.title(f'Label: {y[1]}'); plt.show()
# plt.imshow(x[2,:,:], cmap='gray'); plt.title(f'Label: {y[2]}'); plt.show()
# plt.imshow(x[3,:,:], cmap='gray'); plt.title(f'Label: {y[3]}'); plt.show()

# ---- Fully Connected Approach ----------------------------------------------

# [mnist-fc]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# import numpy.random as npr
# def flatten(x):
#     """Flatten all but the first dimension of an ndarray."""
#     return np.reshape(x, (x.shape[0], -1))

# def one_hot(x, k, dtype=np.float32):
#     """Create a one-hot encoding of x of size k."""
#     return np.array(x[:, None] == np.arange(k), dtype)
# rng = npr.RandomState(0)
# n = x.shape[0]
# perm = rng.permutation(n)
# traini = perm[0:8000]
# testi = perm[8000:n]
# train_images = flatten(x[traini,:,:])/ np.float32(255.)
# test_images = flatten(x[testi,:,:])/ np.float32(255.)
# train_labels  = one_hot(y[traini],10)
# test_labels =  one_hot(y[testi],10)

# [mnist-fc1]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# from jax import jit, grad
# import jax.numpy as jnp
# from jax.scipy.special import logsumexp

# def loss(params, batch):
#   inputs, targets = batch
#   preds = predict(params, inputs)
#   return -jnp.mean(jnp.sum(preds * targets, axis=1))

# def accuracy(params, batch):
#   inputs, targets = batch
#   target_class = jnp.argmax(targets, axis=1)
#   predicted_class = jnp.argmax(predict(params, inputs), axis=1)
#   return jnp.mean(predicted_class == target_class)

# [mnist-fc2]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# def predict(params, inputs):
#     activations = inputs
#     for w, b in params[:-1]:
#         outputs = jnp.dot(activations, w) + b
#         activations = jnp.tanh(outputs)

#     final_w, final_b = params[-1]
#     logits = jnp.dot(activations, final_w) + final_b
#     return logits - logsumexp(logits, axis=1, keepdims=True)

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# layer_sizes = [784, 1024, 1024, 10]
# param_scale = 0.1
# step_size = 0.001
# num_epochs = 10
# batch_size = 128

# num_train = train_images.shape[0]
# num_complete_batches, leftover = divmod(num_train, batch_size)
# num_batches = num_complete_batches + bool(leftover)

# def init_random_params(scale, layer_sizes, rng=npr.RandomState(0)):
#   return [(scale * rng.randn(m, n), scale * rng.randn(n))
#           for m, n, in zip(layer_sizes[:-1], layer_sizes[1:])]

# def data_stream():
#     while True:
#         perm = rng.permutation(num_train)
#         for i in range(num_batches):
#             batch_idx = perm[i * batch_size:(i + 1) * batch_size]
#             yield train_images[batch_idx], train_labels[batch_idx]
# batches = data_stream()

# @jit
# def update(params, batch):
#     grads = grad(loss)(params, batch)
#     return [(w - step_size * dw, b - step_size * db) for (w, b), (dw, db) in zip(params, grads)]

# [mnist-fc3]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# params = init_random_params(param_scale, layer_sizes)
# log = np.empty((2,num_epochs))
# for epoch in range(num_epochs):
#     for _ in range(num_batches):
#         params = update(params, next(batches))
#     train_acc = accuracy(params, (train_images, train_labels))
#     test_acc = accuracy(params, (test_images, test_labels))
#     log[:,epoch] = [train_acc,test_acc,]
# print(f"Training set accuracy {train_acc}")
# print(f"Test set accuracy {test_acc}")

# plt.plot(range(num_epochs),log[0,:]);
# plt.plot(range(num_epochs),log[1,:]);

# ---- CNN for MNIST ---------------------------------------------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# import torch
# import torch.nn as nn
# from torch.nn import functional as F
# x = parse_images("data/t10k-images-idx3-ubyte.gz")
# y = parse_labels("data/t10k-labels-idx1-ubyte.gz")
# class Net(nn.Module):
#     def __init__(self):
#         super(Net, self).__init__()

#         self.conv1 = nn.Conv2d(1, 32, 3, 1)  # 1 input channel (grayscale), 32 output channels, 3x3 kernel
#         self.conv2 = nn.Conv2d(32, 64, 3, 1)  # 32 input channels, 64 output channels
#         # Note: PyTorch defaults to valid padding (no padding). 
#         # After conv1 (28->26), conv2 (26->24), pool (24->12): 64 channels × 12 × 12 = 9216
#         self.fc1 = nn.Linear(9216, 128)
#         self.fc2 = nn.Linear(128, 10)
#     def forward(self, x):
#         x = self.conv1(x)
#         x = F.relu(x)
#         x = self.conv2(x)
#         x = F.relu(x)
#         x = F.max_pool2d(x, 2)
#         x = torch.flatten(x, 1)
#         x = self.fc1(x)
#         x = F.relu(x)
#         x = self.fc2(x)
#         output = F.log_softmax(x, dim=1)
#         return output

# [mnist-cnn]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# def data_stream():
#     perm = rng.permutation(num_train)
#     while True:
#         for i in range(num_batches):
#             # index into traini so we train on the same split as the FC network (no test leakage)
#             batch_idx = traini[perm[i * batch_size:(i + 1) * batch_size]]
#             yield torch.from_numpy(x[batch_idx,:,:]/ np.float32(255.))[:, None, :, :], torch.from_numpy(y[batch_idx])

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# def train(model, optimizer):
#     model.train()
#     batches = data_stream()
#     for epoch in range(num_epochs):
#         for _ in range(num_batches):
#             optimizer.zero_grad()
#             data, target = next(batches)
#             output = model(data)
#             loss = F.nll_loss(output, target)
#             loss.backward()
#             optimizer.step()
#         print(f"Epoch {epoch}: Loss {loss.item()}")

# torch.manual_seed(0)
# model = Net()
# optimizer = torch.optim.Adadelta(model.parameters(), lr=0.1)
# train(model, optimizer)

# [mnist-cnn-eval]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# model.eval()
# with torch.no_grad():
#     test_data = torch.from_numpy(x[testi,:,:]/ np.float32(255.))[:, None, :, :]
#     test_targets = torch.from_numpy(y[testi])
#     output = model(test_data)
#     pred = output.argmax(dim=1)
#     correct = pred.eq(test_targets).sum().item()
#     accuracy = 100. * correct / len(testi)
#     print(f"CNN Test Accuracy: {accuracy:.1f}%")

# ---- 2D Convolution from Scratch -------------------------------------------

import numpy as np

image = np.array([
    [0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 1],
], dtype=float)

sobel_x = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1],
], dtype=float)

# ---- Max and Average Pooling from Scratch ----------------------------------

import numpy as np
np.random.seed(22)

x = np.array([
    [0., 1., 9., 0., 2., 0.],
    [0., 1., 9., 0., 2., 0.],
])

# ---- Training and Shrinking a CNN on MNIST in PyTorch ----------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# import gzip, struct, array
# import numpy as np
# import numpy.random as npr
# import torch
# import torch.nn as nn
# from torch.nn import functional as F

# def parse_labels(filename):
#     with gzip.open(filename, "rb") as fh:
#         _ = struct.unpack(">II", fh.read(8))
#         return np.array(array.array("B", fh.read()), dtype=np.uint8)

# def parse_images(filename):
#     with gzip.open(filename, "rb") as fh:
#         _, num, rows, cols = struct.unpack(">IIII", fh.read(16))
#         return np.array(array.array("B", fh.read()), dtype=np.uint8).reshape(num, rows, cols)

# x = parse_images("data/t10k-images-idx3-ubyte.gz")
# y = parse_labels("data/t10k-labels-idx1-ubyte.gz")

# rng = npr.RandomState(0)
# n = x.shape[0]
# perm = rng.permutation(n)
# traini, testi = perm[0:8000], perm[8000:n]

# batch_size, num_epochs = 128, 5
# num_train = len(traini)
# num_batches = (num_train + batch_size - 1) // batch_size
