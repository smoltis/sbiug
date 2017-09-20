#Demo 3. Debugging
#################################################
#install.packages("dplyr")
library(dplyr)

select_data <- function(dt) {
    dt %>%
    filter(cyl >= 6) %>%
    select(cyl, mpg)
}
select_data(mtcars)