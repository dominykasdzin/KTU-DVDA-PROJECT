if(!require("h2o")) install.packages("h2o"); library("h2o")
if(!require("tidyverse")) install.packages("tidyverse"); library("tidyverse")
h2o.init(max_mem_size = "12g")

df <- h2o.importFile("../1-data/train_data.csv")
test_data <- h2o.importFile("../1-data/test_data.csv")
class(df)
summary(df)

y <- "y"
x <- setdiff(names(df), c(y, "id"))
df$y <- as.factor(df$y)
summary(df)

splits <- h2o.splitFrame(df, c(0.6, 0.2), seed = 123)
train <- h2o.assign(splits[[1]], "train")
valid <- h2o.assign(splits[[2]], "valid")
test <- h2o.assign(splits[[3]], "test")

aml <- h2o.automl(x = x,
                  y = y,
                  training_frame = train,
                  validation_frame = valid,
                  max_runtime_secs = 3600)
aml@leaderboard

model <- h2o.getModel("GBM_1_AutoML_1_20231125_132407")

h2o.performance(model, train = T)
h2o.performance(model, valid = T)
perf <- h2o.performance(model, newdata = test)

h2o.auc(perf)
plot(perf, type = "roc")

predictions <- h2o.predict(model, test_data)
predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions1.csv")


h2o.saveModel(model, "../4-model/", filename = "my_model1")

model <- h2o.loadModel("../4-model/my_model1")
h2o.varimp_plot(model)

model2 <- h2o.getModel("GBM_1_AutoML_1_20231207_222655")

h2o.performance(model2, train = T)
h2o.performance(model2, valid = T)
perf <- h2o.performance(model2, newdata = test)

h2o.auc(perf)
plot(perf, type = "roc")

predictions <- h2o.predict(model2, test_data)
predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions2.csv")

### deeplearning

dl_model <- h2o.deeplearning(
  model_id="dl_model",
  activation =  "Tanh",
  training_frame=train, 
  validation_frame=valid, 
  x=x, 
  y=y, 
  overwrite_with_best_model=F,    ## Return the final model after 10 epochs, even if not the best
  hidden=c(20,10,20),           ## more hidden layers -> more complex interactions
  epochs=20,                      ## to keep it short enough
  score_validation_samples=1000000, ## down sample validation set for faster scoring
  score_duty_cycle=0.025,         ## don't score more than 2.5% of the wall time
  adaptive_rate=F,                ## manually tuned learning rate
  rate=0.01, 
  rate_annealing=2e-6,            
  momentum_start=0.2,             ## manually tuned momentum
  momentum_stable=0.4, 
  momentum_ramp=1e6, 
  l1=1e-5,                        ## add some L1/L2 regularization
  l2=1e-5,
  seed = 1234
) 

# model performance
summary(dl_model)
h2o.auc(dl_model)
h2o.auc(h2o.performance(dl_model, valid = TRUE))
h2o.auc(h2o.performance(dl_model, newdata = test))

dl_params <- list(hidden = list(c(30,30,30), c(40,40,40), c(30,40,50), c(50,40,30), c(40,50,40)))

dl_grid <- h2o.grid(algorithm = "deeplearning",
                    grid_id = "ktu_grid",
                    x,
                    y,
                    training_frame = train,
                    validation_frame = valid,
                    epochs = 1,
                    stopping_metric = "AUC",
                    hyper_params = dl_params)


h2o.getGrid(dl_grid@grid_id, sort_by = "auc")

best_grid <- h2o.getModel(dl_grid@model_ids[[3]])

###2023.11.10
rf_model <- h2o.randomForest(x,
                             y,
                             training_frame = train,
                             validation_frame = valid,
                             ntrees = 50,
                             max_depth = 10,
                             stopping_metric = "AUC",
                             seed = 1234)
rf_model
h2o.auc(rf_model)
h2o.auc(h2o.performance(rf_model, valid = T))
h2o.auc(h2o.performance(rf_model, newdata = test))

gbm_model1 <- h2o.gbm(x,
                     y,
                     training_frame = train,
                     validation_frame = valid,
                     ntrees = 46,
                     max_depth = 17,
                     stopping_metric = "AUC",
                     seed = 1234)
h2o.auc(gbm_model1)
h2o.auc(h2o.performance(gbm_model1, valid = TRUE))
h2o.auc(h2o.performance(gbm_model1, newdata = test))
#su 30 ir 20 geras, ~0.85 ir 0.91
#su 32 ir 22 0.855, 0.936
#su 35 ir 22 0.856, bet 0.941
#su 35 ir 20 0.854 ir 0.92
#su 23 ir 20 0.844 ir 0.897
#su 40 ir 20 0.862 ir 0.935
#su 45 ir 15 0.835 ir 0.858
#su 45 ir 17 0.852 ir 0.894 46 ir 17 irgi geras

predictions <- h2o.predict(gbm_model1, test_data)
predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions2.csv")

gbm_model2 <- h2o.gbm(x,
                      y,
                      training_frame = train,
                      validation_frame = valid,
                      ntrees = 45,
                      max_depth = 17,
                      stopping_metric = "AUC",
                      seed = 1234)
h2o.auc(gbm_model2)
h2o.auc(h2o.performance(gbm_model2, valid = TRUE))
h2o.auc(h2o.performance(gbm_model2, newdata = test))
predictions <- h2o.predict(gbm_model2, test_data)
predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions3.csv")
