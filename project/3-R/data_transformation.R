if(!require("tidyverse")) install.packages("tidyverse"); library("tidyverse")

data_sample <- read_csv("../1-data/1-sample_data.csv")
data_additional <- read_csv("../1-data/3-additional_features.csv")
data_sample2 <- read_csv("../1-data/2-additional_data.csv")

partial_joined <- full_join(data_sample, data_sample2)
joined_data <- inner_join(partial_joined, data_additional, by = "id")
### save combined file into 1-data directory

write_csv(joined_data, "../1-data/train_data.csv")

