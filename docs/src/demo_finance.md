# Basic demo of TimeFrames using financial data

## Create a TimeFrame object for IBM historical data

To load the IBM historical data, we will use the `MarketData.yahoo` function from [MarketData.jl](https://github.com/JuliaQuant/MarketData.jl), which returns the data in the form of a `TimeArray`. We just simply pass this on to the `TimeFrame` constructor.

```@repl e1
using TimeFrames, MarketData, DataFrames, Dates, Plots, Statistics
ibm_ts = TimeFrame(MarketData.yahoo(:IBM))
```

## Create TimeFrame object for AAPL

Similarly, we can create a `TimeFrame` object for the AAPL data.

```@repl e1
aapl_ts = TimeFrame(MarketData.yahoo(:AAPL))
```

## Create a 6-month subset of stock data

We would like to compare the stock returns for both the stocks for 6
months starting from June 1, 2021 till December 31, 2021. We use
`TimeFrames.subset` method to create new objects which contain the specified
duration of data.

```@repl e1
date_from = Date(2021, 06, 01);
date_to = Date(2021, 12, 31);

ibm = TimeFrames.subset(ibm_ts, date_from, date_to)
```

```@repl e1
aapl = TimeFrames.subset(aapl_ts, date_from, date_to)
```

## Combine adjusted closing prices of both stocks into one object

We now join (cbind) both the stocks' data into a single object for
further analysis. We use `TimeFrames.join` to create two columns containing
adjusted closing prices of both the stocks. The join happens by
comparing the `Index` values (dates) of the two objects. The resulting
object contains two columns with exactly the same dates for which both
the objects have data, all the other rows are omitted from the
result.

```@repl e1
ibm_aapl = TimeFrames.join(ibm[:, ["AdjClose"]], aapl[:, ["AdjClose"]], JoinBoth)
TimeFrames.rename!(ibm_aapl, [:IBM, :AAPL])
```

After the `join` operation the column names are modified because we
merged two same-named columns (`AdjClose`) so we use
`TimeFrames.rename!()` method to rename the columns to easily
remembered stock names.

## Convert data into weekly frequency using last values

Here, we convert daily stock data into weekly frequency by taking the
value with which the trading closed on the last day of the week as the
week's price.

```@repl e1
ep = endpoints(ibm_aapl, Week(1));
ibm_aapl_weekly = ibm_aapl[ep]
```

## Compute weekly returns using the familiar `log` and `diff` functions

```@repl e1
ibm_aapl_weekly_returns = diff(log.(ibm_aapl_weekly))
TimeFrames.rename!(ibm_aapl_weekly_returns, [:IBM, :AAPL])
```

## Compute standard deviation of weekly returns

Computing standard deviation is done using the
[`std`](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.std)
function from `Statistics` package. The `skipmissing` is used to skip
missing values which may have been generated while computing log
returns or were already present in the data.

```@repl e1
ibm_std = std(skipmissing(ibm_aapl_weekly_returns[:, :IBM]))
```

```@repl e1
aapl_std = std(skipmissing(ibm_aapl_weekly_returns[:, :AAPL]))
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
