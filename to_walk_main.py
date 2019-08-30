from eda_funcs import *
from data_munging import *
from geo_funcs import *

plt.style.use('ggplot')
plt.figure(figsize=(30, 15))

yellowtaxi_df = pd.read_csv(
    r"/Users/MattMecca/Documents/Github/to-walk-or-not-to-walk-master/2016_Yellow_Taxi_Trip_Data.csv")

#### Data Project -- 03/16/2018 ####
yellowtaxi_df.describe()

## Taking a subset of our population data ##

sub_data = yellowtaxi_df.sample(
    n=35000, replace=False).reset_index(drop=True)
sub_data.describe()

sub_data = date_convert(sub_data)
    
sub_data = var_creation(sub_data)

sub_data = data_filter(sub_data)

## Histogram of project's population dataset (with time difference being the variable of interest) ##

# Crazy to see the CLT in action ==> distribution is almost perfectly normal (or Poisson) (adding constant of
# 3 to walking duration merely shifts the dist., affecting the mean but not the variance)

hist_plot(df = sub_data, title="Trip Duration minus Walk Duration",
          x_lab="Difference in Time", y_lab="Count")


## Pie Chart ##

# Data to plot

pie_chart(df = sub_data)


## Splitting Times into different classes (using dummies) ##

# Reports PU time in hour of day

sub_data = carto_subset(df = sub_data)
## Histogram of a subset of the sample dataset (with time difference being the variable of interest) ##

hist_df1 = sub_data.loc[sub_data.time_diff <= 60]

hist_plot(df=hist_df1, title="Trip Duration minus Walk Duration",
          x_lab="Difference in Time", y_lab="Count")


## Time Dummies ##

time_dfs = time_df_gen(sub_data)


## Analysis for each time period ##

# A lot of hardcoding here -- must be a better way of doing this
lowers = [[12, 'AM'], [4, 'AM'], [8, 'AM'], [12, 'PM'], [4, 'PM'], [8, 'PM']]
uppers = [[4, 'AM'], [8, 'AM'], [12, 'PM'], [4, 'PM'], [8, 'PM'], [12, 'AM']]

time_hist_gen(time_dfs, lowers, uppers)


## Region Dummies ##

# Hard coding regions areas

names = ['midtown_ind', 'lower_man_ind', 'uppeast_ind', 'uppwest_ind']

sub_data = boundary_draw(sub_data=sub_data, names=names)


## Analysis for each zone/region, irrespective of time ##

# Probability of walking in a given zone #

walk_analysis(sub_data, names)


## Midtown and Lower Manhattan the most probable places to WALK ##

walk_records = walk_by_terr(sub_data, names)

adj_reg_names = walk_plot(walk_records)

desc_stats = desc_stats_gen(walk_records, adj_reg_names)

moments_plot(desc_stats, adj_reg_names)
