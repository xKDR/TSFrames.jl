# Basic demo of TSx using financial data

### Read daily prices of IBM and AAPL stocks

As a first step, we read stock data of IBM and Apple for the past one
year as a [DataFrame](https://github.com/JuliaData/DataFrames.jl/)
then we will convert them to TS objects. The stock data files are
bundled with the TSx package so there is no need to download them.


```@example e1
using CSV, DataFrames, Dates, Plots, Statistics, TSx

filename_ibm = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "IBM.csv")
filename_aapl = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "AAPL.csv")

ibm_df = CSV.read(filename_ibm, DataFrame);
aapl_df = CSV.read(filename_aapl, DataFrame);
nothing; # hide
```

### Create a TS object for IBM historical data

Here, we convert the data frames into TS objects so that later we can
use timeseries specific functions on them.

```@example e1
ibm_ts = TS(ibm_df, :Date)
show(ibm_ts)
```

### Create TS object for AAPL

```@example e1
aapl_ts = TS(aapl_df, :Date)
show(aapl_ts)
```

### Create a 6-month subset of stock data

We would like to compare the stock returns for both the stocks for 6
months starting from June 1, 2021 till December 31, 2021. We use
`TSx.subset` method to create new objects which contain the specified
duration of data.

```@example e1
date_from = Date(2021, 06, 01);
date_to = Date(2021, 12, 31);

ibm = TSx.subset(ibm_ts, date_from, date_to)
show(ibm)
```

```@example e1
aapl = TSx.subset(aapl_ts, date_from, date_to)
show(aapl)
```

### Combine adjusted closing prices of both stocks into one object

We now join (cbind) both the stocks' data into a single object for
further analysis. We use `TSx.join` to create two columns containing
adjusted closing prices of both the stocks. The join happens by
comparing the `Index` values (dates) of the two objects. The resulting
object contains two columns with exactly the same dates for which both
the objects have data, all the other rows are omitted from the
result.

```@example e1
ibm_aapl = TSx.join(ibm[:, ["Adj Close"]], aapl[:, ["Adj Close"]], JoinBoth)
    # rename the columns using DataFrame API (making sure `Index` is the first col)
rename!(ibm_aapl.coredata, [:Index, :IBM, :AAPL])
show(ibm_aapl)
```

After the `join` operation the column names are modified because we
merged two same-named columns (`Adj Close`) so we use
`DataFrames.rename!()` method to rename the columns to easily
remembered stock names. This is made possible because
`ibm_appl.coredata` is a `DataFrame` object internally.

### Convert data into weekly frequency using last values

Here, we convert daily stock data into weekly frequency by taking the
value with which the trading closed on the last day of the week as the
week's price.

```@example e1
ibm_aapl_weekly = apply(ibm_aapl, Week, last, last)
show(ibm_aapl_weekly)
```

### Compute weekly returns using the familiar `log` and `diff` functions

TSx has specialised functions for computing rolling differences and
log of timeseries data. We use both of these to compute weekly log
returns of both the stocks.

```@example e1
ibm_aapl_weekly_returns = diff(log(ibm_aapl_weekly))
rename!(ibm_aapl_weekly_returns.coredata, [:Index, :IBM, :AAPL])
show(ibm_aapl_weekly_returns)
```

### Compute standard deviation of weekly returns

Computing standard deviation is done using the
[`std`](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.std)
function from `Statistics` package. The `skipmissing` is used to skip
missing values which may have been generated while computing log
returns or were already present in the data.

```@example e1
ibm_std = std(skipmissing(ibm_aapl_weekly_returns[:, :IBM]))
println("Weekly standard deviation of IBM: ", ibm_std)
```

```@example e1
aapl_std = std(skipmissing(ibm_aapl_weekly_returns[:, :AAPL]))
println("Weekly standard deviation of AAPL: ", aapl_std)
```

### Scatter plot of AAPL and IBM

Here, we use the [Plots](https://docs.juliaplots.org/latest/tutorial/)
package to create a scatter plot with IBM weekly returns on the x-axis
and Apple weekly returns on the y-axis.

```@example e1
ENV["GKSwstype"] = "100" # hide
plot(ibm_aapl_weekly_returns[:, :AAPL],
    ibm_aapl_weekly_returns[:, :IBM],
    seriestype = :scatter;
    xlabel = "AAPL",
    ylabel = "IBM",
    legend = false)
savefig("ts-plot.svg"); nothing # hide
```

![](ts-plot.svg)
