# TSx Benchmarks

```
import .TSx
using DataFrames, Dates, BenchmarkTools, MarketData
BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
df = DataFrame(ohlc)
```

## Creating TSx object from DataFrame
```
@benchmark TSx.TS(data) setup=(data = df)
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
@benchmark TSx.apply(data, Month, mean) setup=(data=ts)
```

```
 Range (min … max):  194.800 μs … 394.900 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     206.100 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   232.200 μs ±  60.704 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

```
@benchmark TSx.apply(data, Month, mean,[:Open, :Close]) setup=(data=ts)
```
```
 Range (min … max):  279.600 μs … 508.600 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     307.800 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   328.220 μs ±  66.705 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

## Lag & Diff & pctchange

### Lag
```
 @benchmark TSx.lag(data,2) setup=(data = ts)
```
```
 Range (min … max):  47.400 μs … 117.900 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     54.050 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   60.240 μs ±  20.791 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```
### Diff

```

```
