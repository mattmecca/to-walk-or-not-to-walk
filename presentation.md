# Question

In this project I try and answer the following question: which pickup locations in New York City have the highest percentage of trips where walking is faster than taking a taxi?


# Assumptions

* We assumed that, on average, people walk about 3.10 MPH
  * That would translate to taking approximately 19.354 minutes in order to walk one mile.
    * I.e., _60_3.10_=19.354 minutes
  * Thus, in order to calculate estimated walk duration, we multiply 19.354 by the recorded trip distance
* We also assumed people would not, even if it made sense time-wise, walk more than 1.5 miles
  * And so we removed from the population all observations for which the trip distance exceeded 1.5 miles before generating our random sample
