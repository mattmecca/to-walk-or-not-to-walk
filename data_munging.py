import pandas as pd
import numpy as np

def date_convert(sub_data):

    for col in ['tpep_pickup_datetime', 'tpep_dropoff_datetime']:
        sub_data[col] = pd.to_datetime(sub_data[col])

    return sub_data


def var_creation(sub_data):

    sub_data['walk_duration'] = sub_data.trip_distance*19.354
    sub_data['walk_duration_secs'] = sub_data.walk_duration*60
    sub_data['trip_duration'] = sub_data.tpep_dropoff_datetime - \
        sub_data.tpep_pickup_datetime

    # We estimate that it takes on average (w/o adjusting for time of day) three minutes to hail a cab

    sub_data['trip_duration_mins'] = sub_data['trip_duration'].dt.seconds/60 + 3

    sub_data['time_diff'] = sub_data.trip_duration_mins - \
        sub_data.walk_duration
    # Ride takes longer ==> 1; walk takes longer ==> 0
    sub_data['cab_indicator'] = sub_data.time_diff.apply(
        lambda x: 1 if x < 0 else 0)
    sub_data['walk_ind'] = sub_data.time_diff.apply(
        lambda x: 1 if x > 0 else 0)

    return sub_data


def data_filter(sub_data):
    """Filters as descibed in PowerPoint"""

    crit1 = sub_data.trip_distance <= 1.5
    # Limiting to rides no longer than 150 minutes
    crit2 = sub_data.trip_duration_mins <= 150
    crit3 = sub_data.pickup_longitude <= 0
    crit4 = sub_data.pickup_latitude >= 0
    crit5 = sub_data.dropoff_longitude <= 0
    crit6 = sub_data.dropoff_latitude >= 0

    sub_data = sub_data.loc[crit1 & crit2 & crit3 &
                            crit4 & crit5 & crit6].reset_index(drop=True)

    return sub_data


def carto_subset(df):

    df['pu_hour'] = df.tpep_pickup_datetime.dt.hour
    df['do_hour'] = df.tpep_dropoff_datetime.dt.hour

    ## Subsetting dataset further for geographical analysis (i.e., Carto) ##

    sub_carto = df.sample(
        frac=0.05, replace=False).reset_index(drop=True)
    sub_carto = df.loc[df.walk_ind == 1]

    print('CARTO DATA:' + '\n\n', sub_carto.describe())
    sub_carto.to_csv('sub_carto.csv')

    return df


def time_df_gen(sub_data):

    time_dfs = {}
    cols = ['twel_4am', 'four_8am', 'eight_12pm',
            'twel_4pm', 'four_8pm', 'eight_12am']
    for x, y, col in zip(range(0, 24, 4), range(4, 28, 4), cols):

        crit1 = sub_data.pu_hour > x
        crit2 = sub_data.pu_hour < y
        sub_data[col] = 0
        sub_data.loc[crit1 & crit2, col] = 1
        time_dfs[col + '_df'] = sub_data.loc[sub_data[col] == 1]

    return time_dfs


def walk_by_terr(sub_data, names):

    times = [['twel_4am', 'weehours'], ['four_8am', 'earlymorn'],
             ['eight_12pm', 'morning'], ['twel_4pm', 'earlyaft'],
             ['four_8pm', 'rushhour'], ['eight_12am', 'evening']]

    walk_records = {}

    for name in names:
        for time in times:
            col_name = name.split('_')[0] + '_' + time[1]
            crit1 = sub_data[name] == 1
            crit2 = sub_data[time[0]] == 1
            crit3 = sub_data['walk_ind'] == 1
            try:
                walk_records[col_name] = len(
                    sub_data.loc[crit1 & crit2 & crit3])/len(sub_data.loc[crit1 & crit2])
            except ZeroDivisionError:
                walk_records[col_name] = 0

    regions = list(map(lambda x: x.split('_')[0], walk_records.keys()))
    times = list(map(lambda x: x.split('_')[1], walk_records.keys()))

    walk_records = pd.DataFrame([list(walk_records.keys()), regions, times,
                                 list(walk_records.values())], index=['region_time', 'region', 'time', 'walk_percs']).T

    return walk_records


def desc_stats_gen(walk_records, adj_reg_names):
    desc_stats = walk_records.groupby('region').std().rename(
        columns={'walk_percs': 'walk_std'}).reset_index()

    # Not sure why, but groupby.mean() is not working
    avg_list = []
    for region in sorted(set(walk_records.region)):
        avg_list.append(np.mean(
            walk_records.loc[walk_records.region == region, 'walk_percs']))
    desc_stats['walk_avg'] = pd.Series(avg_list)

    return desc_stats
