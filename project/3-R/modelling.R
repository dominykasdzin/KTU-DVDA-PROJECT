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


### ID, Y

h2o.saveModel(model, "../4-model/", filename = "my_model1")

model <- h2o.loadModel("../4-model/my_model1")
h2o.varimp_plot(model)

### deeplearning

dl_model <- h2o.deeplearning(x,
                             y,
                             )

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


### ID, Y

h2o.saveModel(model2, "../4-model/", filename = "my_model2")
