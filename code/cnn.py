import gzip
import struct
import array
import numpy as np
import matplotlib.pyplot as plt

def parse_labels(filename):
    with gzip.open(filename, "rb") as fh:
        _ = struct.unpack(">II", fh.read(8))
        return np.array(array.array("B", fh.read()), dtype=np.uint8)
def parse_images(filename):
    with gzip.open(filename, "rb") as fh:
        _, num_data, rows, cols = struct.unpack(">IIII", fh.read(16))
        return np.array(array.array("B", fh.read()),dtype=np.uint8).reshape(num_data, rows, cols)
x = parse_images("data/t10k-images-idx3-ubyte.gz")
y = parse_labels("data/t10k-labels-idx1-ubyte.gz")
plt.imshow(x[0,:,:], cmap='gray'); plt.title(f'Label: {y[0]}'); plt.savefig('fig/mnist-0.png')
plt.imshow(x[1,:,:], cmap='gray'); plt.title(f'Label: {y[1]}'); plt.savefig('fig/mnist-1.png')
plt.imshow(x[2,:,:], cmap='gray'); plt.title(f'Label: {y[2]}'); plt.savefig('fig/mnist-2.png')
plt.imshow(x[3,:,:], cmap='gray'); plt.title(f'Label: {y[3]}'); plt.savefig('fig/mnist-3.png')

import numpy.random as npr
def flatten(x):
    """Flatten all but the first dimension of an ndarray."""
    return np.reshape(x, (x.shape[0], -1))

def one_hot(x, k, dtype=np.float32):
    """Create a one-hot encoding of x of size k."""
    return np.array(x[:, None] == np.arange(k), dtype)
rng = npr.RandomState(0)
n = x.shape[0]
perm = rng.permutation(n)
traini = perm[0:8000]
testi = perm[8000:n]
train_images = flatten(x[traini,:,:])/ np.float32(255.)
test_images = flatten(x[testi,:,:])/ np.float32(255.)
train_labels  = one_hot(y[traini],10)
test_labels =  one_hot(y[testi],10)

def loss(params, batch):
  inputs, targets = batch
  preds = predict(params, inputs)
  return -jnp.mean(jnp.sum(preds * targets, axis=1))

def accuracy(params, batch):
  inputs, targets = batch
  target_class = jnp.argmax(targets, axis=1)
  predicted_class = jnp.argmax(predict(params, inputs), axis=1)
  return jnp.mean(predicted_class == target_class)

def predict(params, inputs):
    activations = inputs
    for w, b in params[:-1]:
        outputs = jnp.dot(activations, w) + b
        activations = jnp.tanh(outputs)

    final_w, final_b = params[-1]
    logits = jnp.dot(activations, final_w) + final_b
    return logits - logsumexp(logits, axis=1, keepdims=True)

from jax import jit, grad
import jax.numpy as jnp
from jax.scipy.special import logsumexp
layer_sizes = [784, 1024, 1024, 10]
param_scale = 0.1
step_size = 0.001
num_epochs = 10
batch_size = 128

num_train = train_images.shape[0]
num_complete_batches, leftover = divmod(num_train, batch_size)
num_batches = num_complete_batches + bool(leftover)

def init_random_params(scale, layer_sizes, rng=npr.RandomState(0)):
  return [(scale * rng.randn(m, n), scale * rng.randn(n))
          for m, n, in zip(layer_sizes[:-1], layer_sizes[1:])]

def data_stream():
    while True:
        perm = rng.permutation(num_train)
        for i in range(num_batches):
            batch_idx = perm[i * batch_size:(i + 1) * batch_size]
            yield train_images[batch_idx], train_labels[batch_idx]
batches = data_stream()

@jit
def update(params, batch):
    grads = grad(loss)(params, batch)
    return [(w - step_size * dw, b - step_size * db) for (w, b), (dw, db) in zip(params, grads)]

params = init_random_params(param_scale, layer_sizes)
log = np.empty((2,num_epochs))
for epoch in range(num_epochs):
    for _ in range(num_batches):
        params = update(params, next(batches))
    train_acc = accuracy(params, (train_images, train_labels))
    test_acc = accuracy(params, (test_images, test_labels))
    log[:,epoch] = [train_acc,test_acc,]
print(f"Training set accuracy {train_acc}")
print(f"Test set accuracy {test_acc}")
plt.close('all')
plt.plot(range(num_epochs),log[0,:]);
plt.plot(range(num_epochs),log[1,:]);
plt.legend(['Training', 'Test'])
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.title('Fully Connected MNIST')
plt.savefig('fig/mnist-fc-test.png')

import torch
import torch.nn as nn
from torch.nn import functional as F
x = parse_images("data/t10k-images-idx3-ubyte.gz")
y = parse_labels("data/t10k-labels-idx1-ubyte.gz")
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()

        self.conv1 = nn.Conv2d(1, 8, 3, 1)  # 1 input channel (grayscale), 8 output channels, 3x3 kernel
        self.conv2 = nn.Conv2d(8, 16, 3, 1)  # 8 input channels, 16 output channels
        # Note: PyTorch defaults to valid padding (no padding). 
        # After conv1 (28->26), pool1 (26->13), conv2 (13->11), pool2 (11->5): 16 channels × 5 × 5 = 400
        self.fc1 = nn.Linear(400, 32)
        self.fc2 = nn.Linear(32, 10)
    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = self.conv2(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = torch.flatten(x, 1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.fc2(x)
        output = F.log_softmax(x, dim=1)
        return output

def data_stream():
    perm = rng.permutation(num_train)
    while True:
        for i in range(num_batches):
            batch_idx = perm[i * batch_size:(i + 1) * batch_size]
            yield torch.from_numpy(x[batch_idx,:,:]/ np.float32(255.))[:, None, :, :], torch.from_numpy(y[batch_idx])

def train(model, optimizer):
    model.train()
    batches = data_stream()
    for epoch in range(num_epochs):
        for _ in range(num_batches):
            optimizer.zero_grad()
            data, target = next(batches)
            output = model(data)
            loss = F.nll_loss(output, target)
            loss.backward()
            optimizer.step()
        # print(f"Epoch {epoch}: Loss {loss.item()}")

model = Net()
optimizer = torch.optim.Adadelta(model.parameters(), lr=0.1)
train(model, optimizer)

model.eval()
with torch.no_grad():
    test_data = torch.from_numpy(x[testi,:,:]/ np.float32(255.))[:, None, :, :]
    test_targets = torch.from_numpy(y[testi])
    output = model(test_data)
    pred = output.argmax(dim=1)
    correct = pred.eq(test_targets).sum().item()
    accuracy = 100. * correct / len(testi)
    print(f"CNN Test Accuracy: {accuracy:.1f}%")

# Count number of parameters in the model
def count_parameters(model):
    return sum(p.numel() for p in model.parameters() if p.requires_grad)
print(f"Number of parameters in the model: {count_parameters(model)}")