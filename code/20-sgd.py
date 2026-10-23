# Code of chapter: Gradient Descent
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/20-sgd.py. Data are read from the data folder.
# Data: data/circle.csv
# Packages: jax, matplotlib, pandas

# ---- Automatic Differentiation (Backpropagation) ---------------------------

# [py-jax]
import jax.numpy as jnp
import pandas as pd
from jax import random
import matplotlib.pyplot as plt

def abline(slope, intercept):
    """Plot a line from slope and intercept"""
    axes = plt.gca()
    x_vals = jnp.array(axes.get_xlim())
    ylim = axes.get_ylim()
    y_vals = intercept + slope * x_vals
    plt.plot(x_vals, y_vals, '-'); plt.ylim(ylim)

d = pd.read_csv('data/circle.csv').values
x = d[:, 1:3]; y = d[:, 0]
k1, k2, k3, k4 = random.split(random.PRNGKey(0), 4)
w1 = 0.1*random.normal(k1,(2,4))
b1 = 0.01*random.normal(k2,(4,))
w2 = 0.1*random.normal(k3,(4,1))
b2 = 0.01*random.normal(k4,(1,))

from jax import grad,jit
def sigmoid(x):
    return 1 / (1 + jnp.exp(-x))
def predict(x, w1,b1,w2,b2):
    z = sigmoid(jnp.dot(x, w1)+b1)
    return sigmoid(jnp.dot(z, w2)+b2)[:,0]
def nll(x, y, w1,b1,w2,b2):
    yhat = predict(x, w1,b1,w2,b2)
    return -jnp.sum(y * jnp.log(yhat) + (1 - y) * jnp.log(1 - yhat))
@jit
def gd_step(x, y, w1,b1,w2,b2, lr):
    grads = grad(nll,argnums=[2,3,4,5])(x, y, w1,b1,w2,b2)
    return w1 - lr * grads[0],b1 - lr * grads[1],w2 - lr * grads[2],b2 - lr * grads[3]
def accuracy(x, y, w1,b1,w2,b2):
    y_pred = predict(x, w1,b1,w2,b2)
    return jnp.mean((y_pred > 0.5) == y)


for i in range(1500):
    w1,b1,w2,b2 = gd_step(x,y,w1,b1,w2,b2,0.02)
print(accuracy(x,y,w1,b1,w2,b2))

fig, ax = plt.subplots(figsize=(3.2, 3));
ax.scatter(x[y==1,0], x[y==1,1], c='r', marker='o', s=7); ax.scatter(x[y==0,0], x[y==0,1], c='g', marker='x', s=12); plt.xlabel("$x_1$", fontsize=8); plt.ylabel("$x_2$", fontsize=8); plt.xlim(-10,10);
ax.spines['top'].set_visible(False); ax.set_aspect('equal'); ax.tick_params(labelsize=6);
for j in range(4):
    abline(-w1[0,j]/w1[1,j], -b1[j]/w1[1,j])
plt.tight_layout();
plt.show();
