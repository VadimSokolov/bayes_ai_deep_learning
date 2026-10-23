# library(reticulate)
# use_python("/usr/local/bin/python")
library(kerasR)
mod <- Sequential()
mod$add(Dense(units = 50, input_shape = 13))
mod$add(Activation("relu"))

mod$add(Dense(units = 1))
keras_compile(mod,  loss = 'mse', optimizer = RMSprop())
boston <- load_boston_housing()
X_train <- scale(boston$X_train)
Y_train <- boston$Y_train
X_test <- scale(boston$X_test)
Y_test <- boston$Y_test

keras_fit(mod, X_train, Y_train,
          batch_size = 32, epochs = 200,
          verbose = 1, validation_split = 0.1)

output

pred <- keras_predict(mod, normalize(X_test))
sd(as.numeric(pred) - Y_test) / sd(Y_test)

mean((as.numeric(pred) - Y_test)^2)