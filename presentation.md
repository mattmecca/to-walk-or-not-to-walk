# Question

In this project I try and answer the following question: which pickup locations in New York City have the highest percentage of trips where walking is faster than taking a taxi?


# Assumptions

* We assumed that, on average, people walk about 3.10 MPH
  * That would translate to taking approximately 19.354 minutes in order to walk one mile.
    * I.e., 60 / 3.10 = 19.354 minutes
  * Thus, in order to calculate estimated walk duration, we multiply 19.354 by the recorded trip distance
* We also assumed people would not, even if it made sense time-wise, walk more than 1.5 miles
  * And so we removed from the population all observations for which the trip distance exceeded 1.5 miles before generating our random sample

* We assume that there being more walkers will not slow average walking speed (and, conversely, that there being fewer walkers will not quicken average walking speed)
  * A rather unrealistic assumption
  * Controlling for it would most likely make future analysis more reliable
* Also we assumed that, on average, it took about three minutes for an individual to first hail, then initialize, and finally complete the transaction necessary when taking a cab.
  * Because of this we chose to add three minutes to the trip duration of each individual observation

# Initial Population Data

***Note***: There were outliers that we felt were not representative of the general population (a 1442.73 minute taxi ride, e.g.); we assumed this data was inputted incorrectly and thus chose to remove it outright


# Population Data

* We used New York City’s Yellow taxi data from May of 2016
  * I felt that, historically, May is a mild enough month that people will, all other things equal, be indifferent towards walking
    * Google has the average temperatures of NYC in May as 72º/54º
  * This was important, as it avoided a potential sample bias
    * E.g., in a colder month (January, say), rather than walk, would-be pedestrians might be more inclined to take a cab, which presumably would make the roads more congested than they otherwise would have been in a fairer weather month 
    * The idea was that this congestion might increase trip duration in some months more than others
    * May was thought to be neutral in this regard

* We take our project’s population data to be the original data collected by Yellow Taxi (or whomever) after applying our project’s conditions to it (and thus not the same as “initial” population data)
  * I.e., taking out trips that spanned more than a mile and a half and trips without recorded x and y pickup coordinates, adding three minutes to each trip’s duration, etc.
 
<img src="/files_for_md/pop_data.png" />

***Note*** the smaller standard deviations after both paring down and removing the outliers


## Exploratory Analysis –– Population Data
<img src="/files_for_md/pop_hist.png" />

* I generated a “Time Difference” variable here
  * Time_Difference ≡ Trip_Duration – Walk_Duration

* As we can see, there are far more trips that took less time than walking would have
  * It seems that only the right tail of our distribution is positive

* ***Interesting tidbit***: after adjusting our initial population dataset to be in line with our project’s assumptions, we find that the Time Difference variable’s distribution is almost perfectly normal (or, perhaps because our random variable is discrete, we might say perfectly Poisson with mean |𝝀| = |𝝁| and variance |𝝀 |= 𝝈2)

  * This is in line with the basic premise of the Central Limit Theorem, and something that I found to be pretty cool

<img src="/files_for_md/pop_pie.png" />

* As you can see to the left, not controlling for time of day, pickup location, etc., walking is quicker than taking a cab roughly 4.85% of the time

  * ***Note***: Pie charts aren’t great representations of data normally, but I figured that, before really going into detail (controlling for region, time, etc.), it would give us a good idea of what our baseline is

# Sample Data

* To be able to work with the data –– which spanned over a million observations –– we had to take a random subset of the project population. Our resulting sample dataset consisted of 8% of the project population, or approximately 34,460 observations. 

<img src="/files_for_md/samp_data.png" />

## Exploratory Analysis –– Sample Data

* Note that, save the number of observations, our Time Difference variable’s distribution and the percentage of time we ought to walk is roughly the same
  * This serves as verification that our random subsampling was indeed random (and thus a success)

<img src="/files_for_md/samp_hist.png" />
<img src="/files_for_md/samp_pie.png" />

## Subset of Sample Data (for CARTO)

* In order to illustrate the data (in CARTO), we had to pare down our sample dataset even further
  * This meant randomly selecting a subset that was 2.5% of the sample (and thus 0.20% of the project population), or approximately 861 observations.
 
<img src="/files_for_md/CARTO_data.png" />


## Exploratory Analysis –– CARTO Data

* Note that, again, save the number of observations, our Time Difference variable’s distribution and the percentage of time we ought to walk is roughly the same as our other two datasets

<img src="/files_for_md/carto_hist.png" />

# Methodology

* Idea was that whenever our walk duration was less than our (adjusted) trip duration, walking was thought to be quicker than taking a cab
  * Later on I might mention that our “walk indicator” was set off X times (or sometimes X percentage of the time). This simply means that our Walk Indicator dummy (i.e., when walking was quicker than taking a cab) had a value of one X times (in that regard it’s referred to as a sum, though other times it will be referred to as a proportion)
* We look to see how much our “walk indicator” varies with both the region and time in which someone starts their trip/walk
* Explore which areas warrant the most walking using a visual guide
  * For this I first used ArcMap to create a zip file that mapped the trips from a to b, and then I used CARTO to make an interactive interface
    * Again, the data that we used in CARTO was a subset of our sample data
* Conduct a statistical analysis of those areas using R 
  * Use dummies to classify both region and time
  * Answer the question “which pickup locations have the highest percent of trips where walking is faster than taking a cab”?
 
# Time Zones

* Time of day was classified as follows:
  * 12:00 to 4:00 AM, “Wee Hours”;
  * 4:00 to 8:00 AM, “Early Morning”;
  * 8:00 AM to 12:00 PM, “Morning”;
  * 12:00 to 4:00 PM, “Early Afternoon”;
  * 4:00 to 8:00 PM, “Rush Hour”; and
  * 8:00 PM to 12:00 AM, “Evening”

# Exploring our Map –– when to walk?

<img src="/files_for_md/carto_map.png" />

* One thing that we get from this CARTO map (other than a headache) is that Yellow Taxi operates  primarily (and almost exclusively) in Manhattan

* Another thing worth mentioning is that it’s during the afternoon (or during rush hour and the evening, to be more specific) when Yellow Taxi is busiest

* ***Note***: To play around with the map yourself, you can do so using the following link:

 https://nyu.carto.com/u/mmm1017/builder/9291437a-36ea-496c-ab66-de86ff55cfe5

* ***Further Note***: CARTO failed to pick up some of the observations that I’d inputted. I suspect it has something to do with the way it read the ZIP file that I’d imported from ArcMap, though I can’t be sure. I’ve been working on solving the issue, but I was unable to do so before submission. Regardless, it does not seem to have much of an effect on our final results/conclusions. It was a rather small error.

* Using this (perhaps too) limited dataset, we see that the walking indicator typically goes off in the Midtown/Lower Manhattan regions between 4:00 PM and 12:00 AM (or “Rush” through the “Evening” hours)
    * It seems (as you might expect) that the walking indicator goes off more often almost everywhere during those hours
* Another thing worth noting is that north of South Harlem there were no cases where walking was quicker than taking a cab
* Before conducting a statistical analysis based on region, we make notes of the above 

    * ***Note***: the long red line from Midtown to Long Island City is an input error

# Exploring Time Differences by Time of Day

* Before considering our sample data on a region-by-region basis, we can first use it to further examine the “Generally speaking, walking is most likely to be the quicker option between 4:00 PM and 12:00 AM” observation we had when looking at the previous slides’ maps. To do this, we first examine the time difference histograms for the different morning and Early Afternoon time periods:

<img src="/files_for_md/12am_4.png" />
<img src="/files_for_md/4am_8.png" />
<img src="/files_for_md/8am_12pm.png" />
<img src="/files_for_md/12pm_4.png" />

### Now we take a look at the time difference histograms for the Rush Hour and Evening time periods:

<img src="/files_for_md/4pm_8.png" />
<img src="/files_for_md/8pm_12am.png" />

* We see that differences between the two groups does seem to warrant our notice, and so we will keep that thought in mind when moving forward.

# Regions

* We chose to divide Manhattan into four sections: the Upper East Side, the Upper West Side, Midtown, and Lower Manhattan
  * We did not consider observations recorded north of Central Park (as there did not seem to be much cab activity there in our exploratory analysis)
* Manhattan’s Regions were classified by the following intervals in which the observation’s  pickup coordinates landed. They can be described as:
  * 40.7396835 < y-coord. < 40.765891 and -73.9906902 < x-coord. < -73.9734576, Midtown;
  * 40.7046437 < y-coord. < 40.739684 and -74.0191965 < x-coord. < -74.0112105, Lower Manhattan;
  * 40.7557326 < y-coord. < 40.784954 and -73.9664882 < x-coord. < -73.9535211, Upper East Side; and
  * 40.7658910 < y-coord. < 40.793772 and -74.0317422 < x-coord. < -73.9725753, Upper West Side


# What did we find?

<img src="/files_for_md/late_probs.png" />

* First off, if you find yourself leaving Lower Manhattan between the hours of 8:00 PM to 12:00 AM, there is a 14% chance that you will arrive at your destination (assuming our project assumptions are not violated) quicker than you would have had you taken a cab
  * Contrary to this, it is also in Lower Manhattan that you are least likely to outwalk your cabbie –– that, though, is between the hours of 12:00 and 8:00 AM 
    * One has to wonder what Lower Manhattan’s 8:00 to 10:00 PM slot would look like
    * The sudden drop-off in activity after 12:00 AM is curious

* ***Also of note***: the times in which you are most likely better off walking in the Upper West and East sides is in the Wee and Early Morning hours, respectively
  * This might be explained by commuters leaving their uptown homes early in the morning in order to travel downtown for work (thus causing traffic congestion)

* Lastly, we ought to also note that Midtown appears to be the most consistently congested region, and thus sets off our walking indicator most often

<img src="/files_for_md/sd_bars.png" />

* Here we see that Midtown, on average, is where walking is most likely going to be quicker than taking a cab
  * Also, its standard deviation (of probabilities across time) is in rough proportion to that of the Upper East and West sides’ (i.e., about half of each ones’ respective mean)
    * This suggests that the likelihood of you being better off walking is consistent in these regions

* Lower Manhattan has the second highest average walk probability, but also the largest standard deviation across time
  * This can be explained by the possibility of the Lower Manhattanite being both best off (from 8:00 PM to 12:00 AM) as well as worst off (from 12:00 AM to 8:00 AM) when opting to walk

* Lastly, we ought to note the low averages of both the Upper East and Upper West Sides
  * Given our exploratory analysis using CARTO, this makes sense
  * The East and West sides seemed the least active, Lower Manhattan seemed to be the second least (or second most), and Midtown seemed to be the most
    * It’s good to see that this is further substantiated when testing on our larger (and thus more reliable) sample dataset
   
# Conclusions

* Whether walking is likely to be quicker than taking a cab largely depends on where you’re being picked up
  * It was in Midtown where walking was most likely to be the quickest way of getting from a to b
  * Lower Manhattan was a close second, with their not being all that much a difference in the averages
    * In Lower Manhattan, though, whether walking was the quicker option would vary wildly based on time of day
  
* Time of day really was important when trying to answer whether walking was quicker than taking a cab
 * Walking is most likely to be the quicker option during the afternoon, generally speaking
  * Unless you’re in the Upper East or West Sides, of course
   * This is only relevant if you’re an early morning walker, and I can’t imagine most people are







