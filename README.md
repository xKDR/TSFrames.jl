# TSFrames.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://xKDR.github.io/TSFrames.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://xKDR.github.io/TSFrames.jl/dev)
![Build Status](https://github.com/xKDR/TSFrames.jl/actions/workflows/documentation.yml/badge.svg)
[![codecov](https://codecov.io/gh/xKDR/TSFrames.jl/branch/main/graph/badge.svg?token=9qkJUtdgrz)](https://codecov.io/gh/xKDR/TSFrames.jl)

TSFrames is a Julia package to handle timeseries data. It provides a
convenient interface for the commonly used timeseries data
manipulations. TSFrames is built on top of the powerful and mature
[DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) making
use of the many capabilities of the `DataFrame` type and being easily
extensible at the same time.

## Installing TSFrames

```julia
julia> using Pkg
julia> Pkg.add("TSFrames")
```

## Basic usage

### Creating TSFrame objects
TSFrames is a [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible package. This helps in easy conversion between `TSFrame` objects and other [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible types. For example, to load a `CSV` into a `TSFrame` object, we do the following.

```julia
julia> using CSV, Dates, DataFrames, TSFrames

julia> ts = CSV.read("IBM.csv", TSFrame)
252x6 TSFrame with Date Index

 Index       Open     High     Low      Close    Adj Close  Volume
 Date        Float64  Float64  Float64  Float64  Float64    Int64
─────────────────────────────────────────────────────────────────────
 2021-04-26  136.157  137.314  135.258  135.344    129.028   4927497
 2021-04-27  135.459  136.291  134.56   135.765    129.429   4062664
 2021-04-28  136.635  137.094  135.851  136.711    130.332   3941433
 2021-04-29  137.792  142.199  136.692  137.897    131.462   4554179
 2021-04-30  137.38   137.505  134.369  135.641    129.311   9280321
 2021-05-03  137.486  139.34   137.237  138.384    131.927   5997241
 2021-05-04  138.059  140.143  137.983  139.34     132.838   6642623
 2021-05-05  139.522  139.522  138.595  138.834    132.355   5229895
 2021-05-06  138.872  141.979  138.795  141.893    135.272   7848661
 2021-05-07  139.503  139.713  138.212  139.063    134.055   7325661
     ⋮          ⋮        ⋮        ⋮        ⋮         ⋮         ⋮
 2022-04-11  127.95   128.18   126.18   126.37     126.37    3202500
 2022-04-12  126.42   127.34   125.58   125.98     125.98    2691000
 2022-04-13  125.64   126.67   124.91   126.14     126.14    3064900
 2022-04-14  128.93   130.58   126.38   126.56     126.56    6382800
 2022-04-18  126.6    127.39   125.53   126.17     126.17    4884200
 2022-04-19  126.08   129.4    126.0    129.15     129.15    7971400
 2022-04-20  135.0    139.56   133.38   138.32     138.32   17859200
 2022-04-21  138.23   141.88   137.35   139.85     139.85    9922300
 2022-04-22  139.7    140.44   137.35   138.25     138.25    6505500
                                                     233 rows omitted
```

As another example of this, consider the following code, which converts a `TimeArray` object to a `TSFrame` object. For this, we use the `MarketData.yahoo` function from the [MarketData.jl](https://juliaquant.github.io/MarketData.jl/stable/) package, which returns a `TimeArray` object.

```julia
julia> using TSFrames, MarketData;

julia> TSFrame(MarketData.yahoo(:AAPL); issorted = true)
10550×6 TSFrame with Date Index
 Index       Open        High        Low         Close       AdjClose    Volume
 Date        Float64     Float64     Float64     Float64     Float64     Float64
───────────────────────────────────────────────────────────────────────────────────
 1980-12-12    0.128348    0.128906    0.128348    0.128348    0.100039  4.69034e8
 1980-12-15    0.12221     0.12221     0.121652    0.121652    0.09482   1.75885e8
 1980-12-16    0.113281    0.113281    0.112723    0.112723    0.087861  1.05728e8
 1980-12-17    0.115513    0.116071    0.115513    0.115513    0.090035  8.64416e7
 1980-12-18    0.118862    0.11942     0.118862    0.118862    0.092646  7.34496e7
 1980-12-19    0.126116    0.126674    0.126116    0.126116    0.0983    4.86304e7
 1980-12-22    0.132254    0.132813    0.132254    0.132254    0.103084  3.73632e7
 1980-12-23    0.137835    0.138393    0.137835    0.137835    0.107434  4.69504e7
 1980-12-24    0.145089    0.145647    0.145089    0.145089    0.113088  4.80032e7
 1980-12-26    0.158482    0.15904     0.158482    0.158482    0.123527  5.55744e7
 1980-12-29    0.160714    0.161272    0.160714    0.160714    0.125267  9.31616e7
 1980-12-30    0.157366    0.157366    0.156808    0.156808    0.122222  6.888e7
 1980-12-31    0.152902    0.152902    0.152344    0.152344    0.118743  3.57504e7
 1981-01-02    0.154018    0.155134    0.154018    0.154018    0.120048  2.16608e7
     ⋮           ⋮           ⋮           ⋮           ⋮           ⋮           ⋮
 2022-09-27  152.74      154.72      149.95      151.76      151.76      8.44427e7
 2022-09-28  147.64      150.64      144.84      149.84      149.84      1.46691e8
 2022-09-29  146.1       146.72      140.68      142.48      142.48      1.28138e8
 2022-09-30  141.28      143.1       138.0       138.2       138.2       1.24705e8
 2022-10-03  138.21      143.07      137.69      142.45      142.45      1.14312e8
 2022-10-04  145.03      146.22      144.26      146.1       146.1       8.78301e7
 2022-10-05  144.07      147.38      143.01      146.4       146.4       7.9471e7
 2022-10-06  145.81      147.54      145.22      145.43      145.43      6.84022e7
 2022-10-07  142.54      143.1       139.45      140.09      140.09      8.58591e7
 2022-10-10  140.42      141.89      138.57      140.42      140.42      7.4899e7
 2022-10-11  139.9       141.35      138.22      138.98      138.98      7.70337e7
 2022-10-12  139.13      140.36      138.16      138.34      138.34      7.04337e7
 2022-10-13  134.99      143.59      134.37      142.99      142.99      1.13224e8
 2022-10-14  144.31      144.52      138.19      138.38      138.38      8.85123e7
                                                                 10522 rows omitted
```

Since we know that our data is in chronological order, we set the `issorted` keyword argument to the `TSFrame` constructor to `true`, allowing it to skip sorting the input table.

### Indexing
```julia
julia> ts[1:10, [:Close]]
(10 x 1) TSFrame with Dates.Date Index

 Index       Close
 Date        Float64
─────────────────────
 2021-04-26  135.344
 2021-04-27  135.765
 2021-04-28  136.711
 2021-04-29  137.897
 2021-04-30  135.641
 2021-05-03  138.384
 2021-05-04  139.34
 2021-05-05  138.834
 2021-05-06  141.893
 2021-05-07  139.063

```

### Subsetting
```julia
julia> from = Date(2021, 04, 29); to = Date(2021, 06, 02);

julia> TSFrames.subset(ts, from, to)
24x6 TSFrame with Date Index

 Index       Open     High     Low      Close    Adj Close  Volume  
 Date        Float64  Float64  Float64  Float64  Float64    Int64   
────────────────────────────────────────────────────────────────────
 2021-04-29  137.792  142.199  136.692  137.897    131.462  4554179
 2021-04-30  137.38   137.505  134.369  135.641    129.311  9280321
 2021-05-03  137.486  139.34   137.237  138.384    131.927  5997241
 2021-05-04  138.059  140.143  137.983  139.34     132.838  6642623
 2021-05-05  139.522  139.522  138.595  138.834    132.355  5229895
 2021-05-06  138.872  141.979  138.795  141.893    135.272  7848661
 2021-05-07  139.503  139.713  138.212  139.063    134.055  7325661
 2021-05-10  139.388  141.855  139.388  139.742    134.709  7304636
 2021-05-11  138.614  138.805  136.616  137.878    132.912  7454214
 2021-05-12  137.514  137.811  134.933  135.086    130.221  6233742
 2021-05-13  135.229  138.528  135.067  137.83     132.866  4807207
 2021-05-14  138.728  139.283  137.629  138.317    133.336  2873780
 2021-05-17  138.088  139.388  137.983  138.728    133.733  4471755
 2021-05-18  138.413  138.91   136.931  137.581    132.627  4000009
 2021-05-19  136.061  136.902  134.723  136.893    131.963  4498532
 2021-05-20  136.826  138.537  135.908  137.553    132.599  4301675
 2021-05-21  137.935  139.293  137.935  138.375    133.392  4219041
 2021-05-24  138.681  138.996  137.839  138.356    133.373  3449290
 2021-05-25  138.547  138.623  136.902  137.467    132.516  4118311
 2021-05-26  137.189  137.658  136.75   137.075    132.138  3225655
 2021-05-27  137.495  138.403  137.314  137.495    132.544  5889294
 2021-05-28  137.868  137.983  137.18   137.419    132.47   2651192
 2021-06-01  138.623  139.417  137.428  137.849    132.885  2528705
 2021-06-02  138.26   139.34   137.772  139.312    134.295  2915097

```

### Frequency conversion
```julia
julia> ts_weekly = to_weekly(ts)
52x6 TSFrame with Date Index

 Index       Open_last  High_last  Low_last  Close_last  Adj Close_last  Volume_last 
 Date        Float64    Float64    Float64   Float64     Float64         Int64       
─────────────────────────────────────────────────────────────────────────────────────
 2021-04-30    137.38     137.505   134.369     135.641         129.311      9280321
 2021-05-07    139.503    139.713   138.212     139.063         134.055      7325661
 2021-05-14    138.728    139.283   137.629     138.317         133.336      2873780
     ⋮           ⋮          ⋮         ⋮          ⋮             ⋮              ⋮
 2022-04-14    128.93     130.58    126.38      126.56          126.56       6382800
 2022-04-22    139.7      140.44    137.35      138.25          138.25       6505500
                                                                      47 rows omitted
```

### Plotting
```julia
julia> using Plots
julia> plot(ts_weekly[:, [:Close_last]], size = (600, 400))
```

![](./ts-plot.svg)

## Documentation

Head to the TSFrames [user guide](https://xkdr.github.io/TSFrames.jl/dev/user_guide/) for more
examples and functionality. The API reference is available on the
[documentation](https://xkdr.github.io/TSFrames.jl/dev/api/) page.

## Contributions

All or any contributions are welcome, small or large. Please feel free
to fork the repository and submit a Pull Request.

## JuliaCon 

### JuliaCon 2022
[![JuliaCon 2022](https://img.youtube.com/vi/Yp-Eo-f3DEk/hqdefault.jpg)](https://www.youtube.com/embed/Yp-Eo-f3DEk)

### JuliaCon 2023
[![JuliaCon 2023](https://img.youtube.com/vi/2H0Z2gJWO1M/hqdefault.jpg)](https://www.youtube.com/embed/2H0Z2gJWO1M)

## Acknowledgements

We gratefully acknowledge the JuliaLab at MIT for financial support
for this project.

We thank Achim Zeileis, Jeffrey A. Ryan, Joshua M. Ulrich, Ross
Bennett, and Corwin Joy for their remarkable work in the
[zoo](https://cran.r-project.org/web/packages/zoo/index.html) and
[xts](https://cran.r-project.org/web/packages/xts/index.html) packages
in R, which shaped our thinking in this field.

We thank Bogumił Kamiński and the Julia community for the remarkable
[DataFrames.jl](https://github.com/JuliaData/DataFrames.jl/) package
which was the foundation of our work, and for Prof. Kamiński's
continuous peer review and feedback in our work.

We also thank all the code/documentation contributors to this package
as well as the overall Julia community for all the valuable
discussions.
