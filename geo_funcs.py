import pandas as pd
import numpy as np

def boundary_draw(sub_data, names):
    for col, coords in zip(names,
                           [[-73.9906902, -73.9734576, 40.7396835, 40.765891],
                            [-74.0191965, -74.0112105, 40.7046437, 40.7396835],
                               [-73.9664882, -73.9535211, 40.7557326, 40.7849539],
                               [-74.0317422, -73.9725753, 40.765891, 40.7937722]]):

        crit1 = sub_data.pickup_longitude > coords[0]
        crit2 = sub_data.pickup_longitude < coords[1]
        crit3 = sub_data.pickup_latitude > coords[2]
        crit4 = sub_data.pickup_latitude < coords[3]
        sub_data[col] = 0
        sub_data.loc[crit1 & crit2 & crit3 & crit4, col] = 1

    return sub_data
