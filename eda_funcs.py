import numpy as np
import matplotlib.pyplot as plt
from matplotlib.pyplot import cm
from matplotlib.patches import Patch


def hist_plot(df, title="Trip Duration minus Walk Duration",
              x_lab="Difference in Time", y_lab="Count",
              color=None):

    binwidth = 2
    plt.hist(df['time_diff'], bins=np.arange(
        min(df['time_diff']), max(df['time_diff']) + binwidth, binwidth),
        alpha=0.75, edgecolor='black', color=color)
    plt.xlim([-30, 30])
    plt.title(title)
    plt.xlabel(x_lab)
    plt.ylabel(y_lab)


def pie_chart(df):

    labels = ['Walk', 'Take a cab']
    sizes = [sum(df['walk_ind']), len(
        list(filter(lambda x: x == 0, sub_data['walk_ind'])))]
    colors = ['lightcoral', 'lightskyblue']
    explode = [0.1, 0]  # explode 1st slice

    # Plot
    plt.pie(sizes, explode=explode, labels=labels,
            colors=colors, wedgeprops={'alpha': 0.75})
    l = plt.legend(loc='best')
    plt.setp(l.get_texts(), color='black')
    plt.axis('equal')
    plt.xlabel('To Walk Or Not To Walk?')


def time_hist_gen(time_dfs, lowers, uppers):

    for color, lower, upper, df in zip(cm.rainbow(np.linspace(0, 1, len(time_dfs))),
                                       lowers, uppers,
                                       time_dfs.values()):
        sub_df = df.loc[df.time_diff <= 60]
        hist_plot(df=sub_df, title="Trip Duration minus Walk Duration",
                  x_lab="Difference in Time ({}:00 {} to {}:00 {})".format(
                        lower[0], lower[1], upper[0], upper[1]),
                  y_lab="Count", color=color)
        plt.show()


def walk_analysis(sub_data, names):
    for name in names:
        crit1 = sub_data[name] == 1
        crit2 = sub_data['walk_ind'] == 1
        print('\n\n' + "Percentage of Walkers for '{}':".format(name), str(round(len(
            sub_data.loc[crit1 & crit2])/len(sub_data.loc[crit1]), 4)*100)[:5] + '%')
        print(sub_data[name].describe())


def walk_plot(walk_records):

    adj_reg_names = []
    for region, color in zip(set(walk_records.region), cm.rainbow(np.linspace(0, 1, len(set(walk_records.region))))):
        df = walk_records.loc[walk_records.region ==
                              region].reset_index(drop=True)
        if region[:3] == 'upp':
            region_adj = 'Upper ' + region[3:].capitalize()
        elif region[:3] == 'low':
            region_adj = region.capitalize() + ' Manhattan'
        else:
            region_adj = region.capitalize()
        plt.plot(df.index, df.walk_percs, c=color, label=region_adj)
        adj_reg_names.append(region_adj)
        l = plt.legend()
        plt.setp(l.get_texts(), color='black')
        locs, labels = plt.xticks()
        labels = ['', 'Wee Hours', 'Early Morning', 'Morning',
                  'Early Afternoon', 'Rush Hour', 'Evening']
        plt.xticks(locs, labels, rotation=-45)

    return sorted(adj_reg_names)


def moments_plot(desc_stats, adj_reg_names):

    N = len(desc_stats)
    walk_std = desc_stats.walk_std
    walk_avg = desc_stats.walk_avg
    areas = desc_stats.region
    ind = np.arange(N)  # the x locations for the groups
    width = 1.0       # the width of the bars

    fig = plt.figure()
    ax = fig.add_subplot(111)
    rects1 = ax.bar(ind, walk_std, width, edgecolor='black')
    [rects1[ind].set_color(col) for ind, col in enumerate(
        cm.rainbow(np.linspace(0, 1, N)))]
    rects2 = ax.bar(ind+width*6, walk_avg, width,
                    edgecolor='black')
    [rects2[ind].set_color(col) for ind, col in enumerate(
        cm.rainbow(np.linspace(0, 1, N)))]
    l = ax.legend([Patch(facecolor=col, label='Color Patch')
                   for col in cm.rainbow(np.linspace(0, 1, N))],
                  [x + ' Moments' for x in adj_reg_names], loc=9)
    plt.setp(l.get_texts(), color='black')
    plt.ylim([0, 0.15])
    # Hacky way of doing it, but hey, it works
    ax.set_xticklabels(('', '', 'Standard Deviations', '', '', 'Averages'))

    plt.show()
