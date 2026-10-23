import numpy as np
def gaussian_kernel_smoothing(X1, X2, x1_train, x2_train, y_train, bandwidth=0.1):
    """
    Perform Gaussian kernel smoothing to predict values at grid points (X1, X2).
    
    Parameters:
    - X1, X2: meshgrid arrays representing test points
    - x1_train, x2_train: training input coordinates
    - y_train: training target values
    - bandwidth: bandwidth parameter for the Gaussian kernel (sigma)
    
    Returns:
    - y_pred: predicted values at grid points with same shape as X1, X2
    """
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

