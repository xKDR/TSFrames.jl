# TSFrames Benchmarks

```
import .TSFrames
using DataFrames, Dates, BenchmarkTools, MarketData
BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
df = DataFrame(ohlc)
describe(df)

5×7 DataFrame
 Row │ variable   mean     min         median  max         nmissing  eltype   
     │ Symbol     Union…   Any         Union…  Any         Int64     DataType
─────┼────────────────────────────────────────────────────────────────────────
   1 │ timestamp           2000-01-03          2001-12-31         0  Date
   2 │ Open       46.2213  13.78       22.19   142.44             0  Float64
   3 │ High       47.6926  14.62       22.95   150.38             0  Float64
   4 │ Low        44.816   13.62       21.39   140.0              0  Float64
   5 │ Close      46.1905  14.0        22.12   144.19             0  Float64
```

df is a dataframe made from the ohlc data available in MarketData. 

It is an OHLC financial data

Rows: 500

Columns: timestamp, Open, High, Low, Close

## Creating a TSFrame object from DataFrame
```
@benchmark TSFrames.TSFrame(data) setup=(data = df)
```
```
 Range (min … max):  20.400 μs … 59.300 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     22.050 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   26.760 μs ± 11.856 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

## Subsetting

### subsetting 100 rows
```
@benchmark data[1:100] setup=(data=ts)
```
```
 Range (min … max):  22.767 μs … 26.633 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     24.067 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   24.177 μs ±  1.078 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
### Subsetting using date

```
@benchmark data["2000-04-10"] setup=(data=ts)

```
```
BenchmarkTools.Trial: 10 samples with 1 evaluation.
 Range (min … max):  784.500 μs … 890.800 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     816.300 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   819.990 μs ±  27.194 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

## Apply methods

```
@benchmark TSFrames.apply(data, Month, mean,[:Open, :Close]) setup=(data=ts)
```

```
 Range (min … max):  194.800 μs … 394.900 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     206.100 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   232.200 μs ±  60.704 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

```
@benchmark TSFrames.apply(data, Year, sum,[:Low, :Close]) setup=(data=ts)
```
```
 Range (min … max):  279.600 μs … 508.600 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     307.800 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   328.220 μs ±  66.705 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

## Lag & Diff & pctchange

### Lag
```
 @benchmark TSFrames.lag(data,2) setup=(data = ts)
```
```
 Range (min … max):  47.400 μs … 117.900 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     54.050 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   60.240 μs ±  20.791 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
### Diff

```
 @benchmark TSFrames.diff(data,1) setup=(data = ts)
```
```
Range (min … max):  155.300 μs … 257.700 μs  ┊ GC (min … max): 0.00% … 0.00%        
 Time  (median):     181.300 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   196.510 μs ±  34.641 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
### pctchange

```
@benchmark TSFrames.pctchange(data,1) setup=(data = ts)
```
```
 Range (min … max):  161.300 μs … 263.900 μs  ┊ GC (min … max): 0.00% … 0.00%       
 Time  (median):     175.650 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   192.780 μs ±  40.118 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

## Log returns

```
@benchmark TSFrames.computelogreturns(data[1:500,2]) setup = (data = ts)
```
```
Range (min … max):   86.000 μs … 199.600 μs  ┊ GC (min … max): 0.00% … 0.00%
Time  (median):      92.900 μs               ┊ GC (median):    0.00%
Time  (mean ± σ):   104.520 μs ±  34.220 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%  
```

```
@benchmark TSFrames.rollapply(mean, data, 3, 5) setup = (data = ts)
```
```
 Range (min … max):  29.600 μs … 82.700 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     30.350 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   36.320 μs ± 16.465 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
## Joins and Concatenation

```
v = [i for i in 1:2:500]
df2 = df[v,[:timestamp,:Open,:High,:Low,:Close]]
rename!(df2, :Open => :open1, :High => :high1, :Low => :low1, :Close => :close1)
ts2 = TSFrames.TSFrame(df2)
```
### Left Join

```
@benchmark TSFrames.leftjoin(ts,ts2)
```
```
 Range (min … max):  107.100 μs … 220.100 μs  ┊ GC (min … max): 0.00% … 0.00%       
 Time  (median):     113.800 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   126.260 μs ±  33.537 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%  
```

### Right Join

```
@benchmark TSFrames.rightjoin(ts,ts2)
```
```
 Range (min … max):   96.700 μs … 206.400 μs  ┊ GC (min … max): 0.00% … 0.00%       
 Time  (median):     108.850 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   117.420 μs ±  32.178 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

### Inner Join

```
@benchmark TSFrames.innerjoin(ts,ts2)
```
```
 Range (min … max):  71.800 μs … 180.400 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     83.900 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   92.870 μs ±  32.003 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

### Outer Join

```
 @benchmark TSFrames.outerjoin(ts,ts2)
```
```
 Range (min … max):  114.300 μs … 228.800 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     123.700 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   134.950 μs ±  34.190 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

### vcat

```
df3 = df[1:300,[:timestamp,:Open,:High,:Low,:Close]]
df4 = df[300:end,[:timestamp,:Open,:High,:Low,:Close]]
ts3 = TSFrames.TSFrame(df3)
ts4 = TSFrames.TSFrame(df4)
```

```
@benchmark vcat(ts3,ts4)
```
```
 Range (min … max):  89.004 ns … 100.104 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     92.168 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   93.237 ns ±   3.751 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
