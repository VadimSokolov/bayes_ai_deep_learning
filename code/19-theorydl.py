# Code of chapter: Theory of Deep Learning
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/19-theorydl.py. Data are read from the data folder.
# Packages: matplotlib, numpy

# ---- Double Descent Demonstration Using Polynomial Regression --------------

# [global-setup]
import numpy as np
import numpy.random as rand
import numpy.linalg as la
import matplotlib.pyplot as plt

# Set random seed for reproducibility
np.random.seed(42)
# Functions
def arctan_gt(x): 
    return np.arctan(5*x)

def cubic_gt(x): 
    return poly(x, np.array([0, -1, 0, 1]), 3)

def relu(x): 
    return x*(x >= 0)

def sin(x): 
    return np.sin(5*x)

def Vand(x, d):
    """Vandermonde matrix for pts x, to degree d"""
    X = np.array([x**i for i in range(0, d+1)]).T
    return X

n = 20  # number of samples
sigma = 0.3  # stdev of noise
a = -1
b = 1  # range of x values
# Legendre polynomial basis
G = np.polynomial.legendre.legvander

# Initialize data
ground_truth = sin
x = np.linspace(a, b, n)
y = ground_truth(x) + sigma * np.random.normal(size=n)
xdense = np.linspace(a, b, 100)
ygt = ground_truth(xdense)

def fit(d):
    betaHat = la.pinv(G(x, d)).dot(y)
    mseos = np.mean((G(xdense, d).dot(betaHat) - ygt)**2)
    mseis = np.mean((G(x, d).dot(betaHat) - y)**2)
    return betaHat, mseos, mseis

def poly(pts, beta, d):
    return G(pts, d).dot(beta)

def run(d, ax):
    """Compute the regressor for degree d, and plot the solution."""
    betaHat, mseos, mseois = fit(d)
    ax.plot(xdense, ygt, label='ground-truth')
    ax.scatter(x, y, c='r', label='samples')
    ax.plot(xdense, poly(xdense, betaHat, d), label='model')
    ax.set_ylim(-2, 2)
    ax.axis('off')
    ax.legend()
    ax.set_title('d=%d, MSE: Test=%.2f, Train=%.2f' % (d, mseos, mseois))

# [fig-double-descent-grid]
# Create 2x2 subplot grid (all functions and variables are now persistent!)
fig, axes = plt.subplots(2, 2, figsize=(5.5, 4.6))
fig.suptitle('Double Descent Phenomenon: Polynomial Regression', fontsize=10)

# Plot each degree in its respective subplot
run(1, axes[0, 0])   # Top left
run(5, axes[0, 1])   # Top right  
run(20, axes[1, 0])  # Bottom left
run(50, axes[1, 1])  # Bottom right

for ax in axes.flat:
    ax.legend(fontsize=6)
    ax.title.set_fontsize(8)

plt.tight_layout()
plt.show()

# [fig-mse-curve]
# Generate MSE data for different polynomial degrees (using persistent functions!)
nd = 51
mse1 = np.zeros(nd)  # Test MSE
mse2 = np.zeros(nd)  # Train MSE

for d in range(1, nd):
    betaHat, mseos, mseois = fit(d)
    mse1[d] = mseos
    mse2[d] = mseois
fig, ax1 = plt.subplots()
ax1.set_xlabel('Polynomial Degree')
ax1.set_ylabel('log10(Test MSE)', color='blue')
ln1 = ax1.plot(range(1, nd), np.log10(mse1[1:]), color='blue', label='out-of-sample')
ax1.tick_params(axis='y', labelcolor='blue')

ax2 = ax1.twinx()
ax2.set_ylabel('log10(Train MSE)', color='red')
ln2 = ax2.plot(range(1, nd), np.log10(mse2[1:]), color='red', linestyle='--', label='in-sample')
ax2.tick_params(axis='y', labelcolor='red')

# Combined legend with no box
lns = ln1 + ln2
labs = [l.get_label() for l in lns]
ax1.legend(lns, labs, loc='upper right', frameon=False)

# Remove the box (spines)
ax1.spines['top'].set_visible(False)
ax2.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax2.spines['left'].set_visible(False)

plt.tight_layout()
