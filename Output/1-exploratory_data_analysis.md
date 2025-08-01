# Initial descriptive statistics and visualizations

In this document you will find the steps required to perform an initial exploration analysis of the traffic & climate data combined in [`R/1-import.R`](../R/1-import.R).

## Load packages

To conduct this analysis we need a few packages loaded in the R environment. `pacman` Is used for convenience as it will install (and if required easily update) required packages when not installed. If you prefer you could run `install.packages("packagename")` and `library("packagename")` instead. 

```{r loadpackages, echo=TRUE}
pacman::p_load(tidyverse) 


```

## Including Plots

You can also embed plots, for example:

```{r pressure, echo=FALSE}
plot(pressure)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
