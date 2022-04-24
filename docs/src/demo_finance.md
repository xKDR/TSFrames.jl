# Basic demo of TSx using financial data

1. Read daily prices of IBM and AAPL stocks

```@example e1
using CSV, DataFrames, Dates, Plots, Statistics, TSx

filename_ibm = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "IBM.csv")
filename_aapl = joinpath(dirname(pathof(TSx)),
               "..", "docs", "src", "assets", "AAPL.csv")

ibm_df = CSV.read(filename_ibm, DataFrame);
aapl_df = CSV.read(filename_aapl, DataFrame);
```

2. Now, create a TS object for IBM historical data.

```@example e1
ibm_ts = TS(ibm_df, :Date)
show(ibm_ts)
```

3. Create TS object for AAPL.

```@example e1
aapl_ts = TS(aapl_df, :Date)
show(aapl_ts)
```

4. Create a 6-month subset of stock data

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

5. Combine adjusted closing prices of both stocks into one object.

```@example e1
ibm_aapl = TSx.join(ibm[:, ["Adj Close"]], aapl[:, ["Adj Close"]], JoinAll)
    # rename the columns using DataFrame API (making sure `Index` is the first col)
rename!(ibm_aapl.coredata, [:Index, :IBM, :AAPL])
show(ibm_aapl)
```

6. Compute weekly returns using the familiar `log` and `diff` functions.

```@example e1
ibm_aapl_weekly = apply(ibm_aapl, Week, last, last)
show(ibm_aapl_weekly)
```

```@example e1
ibm_aapl_weekly_returns = diff(log(ibm_aapl_weekly))
rename!(ibm_aapl_weekly_returns, [:Index, :IBM, :AAPL])
show(ibm_aapl_weekly_returns)
```

7. Compute standard deviation of weekly returns.

```@example e1
ibm_std = std(skipmissing(ibm_aapl_weekly_returns[:, :IBM]))
aapl_std = std(skipmissing(ibm_aapl_weekly_returns[:, :AAPL]))

println("Weekly standard deviation of IBM: ", ibm_std)
```

```@example e1
println("Weekly standard deviation of AAPL: ", aapl_std)
```

8. Scatter plot of AAPL and IBM

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
