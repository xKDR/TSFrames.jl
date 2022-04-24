# Basic demo of TSx using financial data

## Read daily prices of IBM and AAPL stocks

```@example label
using CSV, DataFrames, Dates, Plots, Statistics, TSx

filename_ibm = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "IBM.csv")
filename_aapl = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "AAPL.csv")

ibm_df = CSV.read(filename_ibm, DataFrame);
aapl_df = CSV.read(filename_aapl, DataFrame);
```

## Create TS objects

```julia label
ibm_ts = TS(ibm_df, :Date)
aapl_ts = TS(aapl_df, :Date)
```

## Subset both the stocks for 6 months data

```julia label
date_from = Date(2021, 06, 01);
date_to = Date(2021, 12, 31);

ibm = TSx.subset(ibm_ts, date_from, date_to)
aapl = TSx.subset(aapl_ts, date_from, date_to)
```

## Combine adjusted closing prices into one object

```julia label
ibm_aapl = TSx.join(ibm[:, ["Adj Close"]], aapl[:, ["Adj Close"]], JoinAll)
    # rename the columns using DataFrame API (making sure `Index` is the first col)
rename!(ibm_aapl.coredata, [:Index, :IBM, :AAPL])
```

## Compute weekly returns

```juila label
ibm_aapl_weekly = apply(ibm_aapl, Week, last, last)
ibm_aapl_weekly_returns = diff(log(ibm_aapl_weekly))
rename!(ibm_aapl_weekly_returns, [:Index, :IBM, :AAPL])
```

## Compute standard deviation of weekly returns

```julia label
ibm_std = std(skipmissing(ibm_aapl_weekly_returns[:, :IBM]))
aapl_std = std(skipmissing(ibm_aapl_weekly_returns[:, :AAPL]))

println("Weekly standard deviation of IBM: ", ibm_std)
println("Weekly standard deviation of AAPL: ", aapl_std)
```

## Scatter plot of AAPL and IBM

```julia label
plot(ibm_aapl_weekly_returns[:, :AAPL],
    ibm_aapl_weekly_returns[:, :IBM],
    seriestype = :scatter;
    xlabel = "AAPL",
    ylabel = "IBM",
    legend = false)
```
