# Basic demo of TSFrames using financial data

## Create a TSFrame object for IBM historical data

To load the IBM historical data, we will use the `MarketData.yahoo` function from [MarketData.jl](https://github.com/JuliaQuant/MarketData.jl), which returns the data in the form of a `TimeArray`. We just simply pass this on to the `TSFrame` constructor.

```@repl e1
using TSFrames, MarketData, Plots, Statistics, Impute
ibm_ts = TSFrame(MarketData.yahoo(:IBM))
```

## Create TSFrame object for AAPL

Similarly, we can create a `TSFrame` object for the AAPL data.

```@repl e1
aapl_ts = TSFrame(MarketData.yahoo(:AAPL))
```

## Create a 6-month subset of stock data

We would like to compare the stock returns for both the stocks for 6
months starting from June 1, 2021 till December 31, 2021. We use
`TSFrames.subset` method to create new objects which contain the specified
duration of data.

```@repl e1
date_from = Date(2021, 06, 01);
date_to = Date(2021, 12, 31);

ibm = TSFrames.subset(ibm_ts, date_from, date_to)
```

```@repl e1
aapl = TSFrames.subset(aapl_ts, date_from, date_to)
```

## Combine adjusted closing prices of both stocks into one object

We now join (cbind) both the stocks' data into a single object for
further analysis. We use `TSFrames.join` to create two columns containing
adjusted closing prices of both the stocks. The join happens by
comparing the `Index` values (dates) of the two objects. The resulting
object contains two columns with exactly the same dates for which both
the objects have data, all the other rows are omitted from the
result.

```@repl e1
ibm_aapl = TSFrames.join(ibm[:, ["AdjClose"]], aapl[:, ["AdjClose"]]; jointype=:JoinBoth)
TSFrames.rename!(ibm_aapl, [:IBM, :AAPL])
```

After the `join` operation the column names are modified because we
merged two same-named columns (`AdjClose`) so we use
`TSFrames.rename!()` method to rename the columns to easily
remembered stock names.

## Fill missing values

```@repl e1
ibm_aapl = ibm_aapl |> Impute.locf()
```

## Convert data into weekly frequency using last values

Here, we convert daily stock data into weekly frequency by taking the
value with which the trading closed on the last day of the week as the
week's price.

```@repl e1
ibm_aapl_weekly = to_weekly(ibm_aapl)
```

## Compute weekly returns using the familiar `log` and `diff` functions

```@repl e1
ibm_aapl_weekly_returns = diff(log.(ibm_aapl_weekly))
TSFrames.rename!(ibm_aapl_weekly_returns, [:IBM, :AAPL])
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

## Aggregation and rolling window operations

Here, we compute realised volatility of returns of both IBM and Apple
stock weekly and bi-monthly. Then, we compute daily returns volatility
on a rolling basis with a window size of 10.

```@repl e1
daily_returns = diff(log.(ibm_aapl))
rvol = apply(daily_returns, Week(1), std) # Compute the realised volatility
rvol = apply(daily_returns, Month(2), std) # Every two months
rollapply(daily_returns, std, 10) # Compute rolling vols
```

## Rolling regression with a window of 10

One of the common finance problems is to run a rolling window
regression of firm returns over market returns. For doing this, we
will use the `lm()` function from the `GLM` package. We will create a
separate function `regress()` which would take in the data as an
argument and use pre-defined strings to identify the returns columns,
pass them to `lm()`, and return the results.

We start by downloading the S&P500 daily data from Yahoo Finance, then
performing the same steps as above to come to a joined `TSFrame` object
containing daily returns of S&P500 and IBM stock prices. Then, use
`rollapply()` with `bycolumn=false` to tell `rollapply()` to pass in
the entire `TSFrame` to the function in one go for each iteration
within the window.

```@repl e1
sp500 = TSFrame(MarketData.yahoo("^GSPC"));
sp500_adjclose = TSFrames.subset(sp500, date_from, date_to)[:, ["AdjClose"]]

sp500_ibm = join(sp500_adjclose, ibm_adjclose, jointype=:JoinBoth)
sp500_ibm_returns = diff(log.(sp500_ibm))
TSFrames.rename!(sp500_ibm_returns, ["SP500", "IBM"]);

function regress(data)
    ll = lm(@formula(IBM ~ SP500), data)
    co::Real = coef(ll)[coefnames(ll) .== "IBM"][1]
    sd::Real = Statistics.std(residuals(ll))
    return (co, sd)
end

rollapply(sp500_ibm_returns, regress, 10, bycolumn=false)
```
