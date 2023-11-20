Our fifth visualization uses Maxent climate modeling to predict the distribution hotspot in the past 18 thousand years using the historical climate data and ancient climate data from WorldClim, then projected them on a map with a slider to adjust the time. Users have the option to slide the slider to observe the anticipated distribution corresponding to the specific number of time periods they are interested in. 
We chose to use interactive visualization over static because the distribution change as time lapse is a continuous process, which is difficult to implement using a static graph as we have so many species/graphs in each time period. A slider makes it possible to compare and contrast the distribution across different time points, making it easier to see the trends. The black dots represent their current distribution record, heatmap represents their projected distribution.
A benefit to this visualization is that it is user friendly. The user can use a slider to visualize time change is very easy and intuitive. 2, Easy identify patterns and trends: the sliding process in this visualization is very smooth, it looks like animation. 
Cons: 1, Limited Precision and easily misinterpretable: each point actually represents a time period, not a time point, which is oversimplified from this visualization. For example, the 3 thousands years ago time point actually used the climate modeling of the median of the past 0.3~4 thousand years. 2, Overwhelming: For each time period, there are 15 graphs. It was too big that my window can only show 8 of them. However, due to the difficulty of mapping a raster class called RasterLayer which is the output from package Maxent, letting users to customize the choice of species appear on the screen would take too much memory and will be very slow, so we ended up decide to put all of the species in one graph.