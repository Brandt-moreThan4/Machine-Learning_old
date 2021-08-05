library(readr)
library(dplyr)
library(tidyverse)

greenbuildings <- read_csv("greenbuildings.csv")

# par(mfrow=c(1,1))

# Green do have a higher mean and median 

greenbuildings %>% group_by(green_rating) %>% summarise(avg_rent = mean(Rent),
                                                        median_rent = median(Rent))


"Does the scrubbing make sense?:
I'm not really sure. I lean towards yes because I think it is probably a data entry error, but a counterpoint
is the other values associated with this points seems to be valid still.

It doesn't really affect results much so I guess removing should be fine? Just make careful note of it.
Maybe only delete the ones that are 0?
"
# How many would that remove?
sum(greenbuildings$leasing_rate < 10) # 215. Not terrible

# Clean it
scrubbed_buildings = greenbuildings[greenbuildings$leasing_rate >= 10,]

# Same median as before? That seems weird right?
scrubbed_buildings %>% group_by(green_rating) %>% summarise(avg_rent = mean(Rent),
                                                        median_rent = median(Rent))


# Using median seems fair. Especially when considering the healthy chunk of data points beyond the upper fence
ggplot(scrubbed_buildings, mapping = aes(y=Rent)) + geom_boxplot()
ggplot(scrubbed_buildings, mapping = aes(x=Rent)) + geom_histogram() # Again, slight left skew


# hard to see any difference here
ggplot(scrubbed_buildings, mapping = aes(x=as.factor(green_rating),y=Rent)) + geom_boxplot()
ggplot(scrubbed_buildings, mapping = aes(x=as.factor(renovated),y=Rent)) + geom_boxplot()
ggplot(scrubbed_buildings, mapping = aes(x=as.factor(amenities),y=Rent)) + geom_boxplot() + facet_wrap(~renovated)

# Maybe upward trend in rent for size?
ggplot(scrubbed_buildings, mapping = aes(log(size),y=Rent)) + geom_point() 



greenbuildings = greenbuildings[,-c(1,2)]


# USe a regression to figure out whats important?
lm_model = lm(Rent~.,greenbuildings)
summary(lm_model)


