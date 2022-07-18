DATA_SIZE_1 = 360
data_vector_1 = randn(DATA_SIZE_1)
index_timetype_1 = Date(2007, 1,1) + Day.(0:(DATA_SIZE_1 - 1))

df_timetype_index_1 = DataFrame(Index = index_timetype_1, data = data_vector_1)
ts_daily_1 = TS(df_timetype_index_1, 1)
ts_daily_matrix_1 = TS(DataFrames.innerjoin(df_timetype_index_1, df_timetype_index_1, on=:Index, makeunique=true))

DATA_SIZE_2 = 86400
data_vector_2 = randn(DATA_SIZE_2)
index_timetype_2 = DateTime(2000, 1, 1, 0, 0, 0) + Second.(0:(DATA_SIZE_2 - 1))

df_timetype_index_2 = DataFrame(Index = index_timetype_2, data = data_vector_2)
ts_intraday_2 = TS(df_timetype_index_2)
ts_daily_matrix_2 = TS(DataFrames.innerjoin(df_timetype_index_2, df_timetype_index_2, on=:Index, makeunique=true))


# function apply(ts::TS, period::Union{T,Type{T}}, fun::V, index_at::Function=first) where {T<:Union{DatePeriod,TimePeriod}, V<:Function}

# Resampling

# Daily -> Monthly
ts_monthly = apply(ts_daily_1, Dates.Month, first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12 # 360 days

ts_monthly = apply(ts_daily_1, Dates.Month, last)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12

ts_monthly = apply(ts_daily_1, Dates.Month(1), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12

ts_monthly = apply(ts_daily_1, Dates.Month(2), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 6

ts_monthly = apply(ts_daily_1, Dates.Month(12), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1

ts_monthly = apply(ts_daily_1, Dates.Month(100), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1

ts_monthly = apply(ts_daily_1, Dates.Month, Statistics.mean)
t = ts_daily_1[:, "data"]
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12
@test typeof(ts_monthly[:, "data_mean"]) == Vector{Float64}
@test ts_monthly[1, "data_mean"] == Statistics.mean(t[1:31])

ts_monthly = apply(ts_daily_1, Dates.Month, sum)
t = ts_daily_1[:, "data"]
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12
@test typeof(ts_monthly[:, "data_sum"]) == Vector{Float64}
@test ts_monthly[1, "data_sum"] == sum(t[1:31])

ts_monthly = apply(ts_daily_1, Dates.Month, sum, last)
t = ts_daily_1[:, "data"]
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12
@test typeof(ts_monthly[:, "data_sum"]) == Vector{Float64}
@test ts_monthly["2007-01-31"][1,1] == sum(t[1:31])

# Daily -> Yearly
ts_yearly = apply(ts_daily_1, Dates.Year, first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_daily_1, Dates.Year, last)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_daily_1, Dates.Year(1), first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_daily_1, Dates.Year(2), first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_daily_1, Dates.Year(100), first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_daily_1, Dates.Year, Statistics.mean)
t = ts_daily_1[:, "data"]
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1
@test typeof(ts_yearly[:, "data_mean"]) == Vector{Float64}
@test ts_yearly[1, "data_mean"] ≈ Statistics.mean(t)

ts_yearly = apply(ts_daily_1, Dates.Year, sum)
t = ts_daily_1[:, "data"]
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1
@test typeof(ts_yearly[:, "data_sum"]) == Vector{Float64}
@test ts_yearly[1, "data_sum"] ≈ sum(t)

ts_yearly = apply(ts_daily_1, Dates.Year, sum, last)
t = ts_daily_1[:, "data"]
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1
@test typeof(ts_yearly[:, "data_sum"]) == Vector{Float64}
@test ts_yearly[1, "data_sum"] ≈ sum(t)
@test ts_yearly["2007-12-26"][1,1] ≈ sum(t)

# Daily -> Weekly
ts_weekly = apply(ts_daily_1, Dates.Week, first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 52

ts_weekly = apply(ts_daily_1, Dates.Week, last)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 52

ts_weekly = apply(ts_daily_1, Dates.Week(1), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 52

ts_weekly = apply(ts_daily_1, Dates.Week(2), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 26

ts_weekly = apply(ts_daily_1, Dates.Week(52), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test_broken DataFrames.nrow(ts_weekly.coredata) == 1

ts_weekly = apply(ts_daily_1, Dates.Week(100), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

# Daily -> Quarterly
ts_quarterly = apply(ts_daily_1, Dates.Quarter, first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4

ts_quarterly = apply(ts_daily_1, Dates.Quarter, last)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4

ts_quarterly = apply(ts_daily_1, Dates.Quarter(1), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4

ts_quarterly = apply(ts_daily_1, Dates.Quarter(2), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 2

ts_quarterly = apply(ts_daily_1, Dates.Quarter(4), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1

ts_quarterly = apply(ts_daily_1, Dates.Quarter(100), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1

ts_quarterly = apply(ts_daily_1, Dates.Quarter, Statistics.mean)
t = ts_daily_1[:, "data"]
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4
@test typeof(ts_quarterly[:, "data_mean"]) == Vector{Float64}
@test ts_quarterly[1, "data_mean"] ≈ Statistics.mean(t[1:90])

ts_quarterly = apply(ts_daily_1, Dates.Quarter, sum)
t = ts_daily_1[:, "data"]
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4
@test typeof(ts_quarterly[:, "data_sum"]) == Vector{Float64}
@test ts_quarterly[1, "data_sum"] ≈ sum(t[1:90])

ts_quarterly = apply(ts_daily_1, Dates.Quarter, sum, last)
t = ts_daily_1[:, "data"]
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4
@test typeof(ts_quarterly[:, "data_sum"]) == Vector{Float64}
@test ts_quarterly[1, "data_sum"] ≈ sum(t[1:90])
@test ts_quarterly["2007-03-31"][1,1] ≈ sum(t[1:90])


# Daily -> Daily
ts_test_daily = apply(ts_daily_1, Dates.Day, first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360

ts_test_daily = apply(ts_daily_1, Dates.Day, last)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360

ts_test_daily = apply(ts_daily_1, Dates.Day(1), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360

ts_test_daily = apply(ts_daily_1, Dates.Day(2), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 180

ts_test_daily = apply(ts_daily_1, Dates.Day(3), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 121

ts_test_daily = apply(ts_daily_1, Dates.Day(180), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test_broken DataFrames.nrow(ts_test_daily.coredata) == 2

ts_test_daily = apply(ts_daily_1, Dates.Day(360), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test_broken DataFrames.nrow(ts_test_daily.coredata) == 1

ts_test_daily = apply(ts_daily_1, Dates.Day(1000), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1


# Secondly -> Yearly
ts_yearly = apply(ts_intraday_2, Dates.Year, first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_intraday_2, Dates.Year, last)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_intraday_2, Dates.Year(1), first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_intraday_2, Dates.Year(100), first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1


# Secondly -> Monthly
ts_monthly = apply(ts_intraday_2, Dates.Month, first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1

ts_monthly = apply(ts_intraday_2, Dates.Month, last)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1

ts_monthly = apply(ts_intraday_2, Dates.Month(1), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1

ts_monthly = apply(ts_intraday_2, Dates.Month(100), first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 1


# Secondly -> Weekly
ts_weekly = apply(ts_intraday_2, Dates.Week, first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

ts_weekly = apply(ts_intraday_2, Dates.Week, last)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

ts_weekly = apply(ts_intraday_2, Dates.Week(1), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

ts_weekly = apply(ts_intraday_2, Dates.Week(100), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1


# Secondly -> Quarterly
ts_quarterly = apply(ts_intraday_2, Dates.Quarter, first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1

ts_quarterly = apply(ts_intraday_2, Dates.Quarter, last)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1

ts_quarterly = apply(ts_intraday_2, Dates.Quarter(1), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1

ts_quarterly = apply(ts_intraday_2, Dates.Quarter(100), first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 1


# Secondly -> Daily
ts_test_daily = apply(ts_intraday_2, Dates.Day, first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1

ts_test_daily = apply(ts_intraday_2, Dates.Day, last)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1

ts_test_daily = apply(ts_intraday_2, Dates.Day(1), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1

ts_test_daily = apply(ts_intraday_2, Dates.Day(100), first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1


# Secondly -> Hourly
ts_hourly = apply(ts_intraday_2, Dates.Hour, first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24

ts_hourly = apply(ts_intraday_2, Dates.Hour, last)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24

ts_hourly = apply(ts_intraday_2, Dates.Hour(1), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24

ts_hourly = apply(ts_intraday_2, Dates.Hour(2), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 12

ts_hourly = apply(ts_intraday_2, Dates.Hour(3), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 8

ts_hourly = apply(ts_intraday_2, Dates.Hour(12), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 2

ts_hourly = apply(ts_intraday_2, Dates.Hour(24), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 1

ts_hourly = apply(ts_intraday_2, Dates.Hour(100), first)
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 1

ts_hourly = apply(ts_intraday_2, Dates.Hour, Statistics.mean)
t = ts_intraday_2[:, "data"]
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24
@test typeof(ts_hourly[:, "data_mean"]) == Vector{Float64}
@test ts_hourly[1, "data_mean"] ≈ Statistics.mean(t[1:3600])

ts_hourly = apply(ts_intraday_2, Dates.Hour, sum)
t = ts_intraday_2[:, "data"]
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24
@test typeof(ts_hourly[:, "data_sum"]) == Vector{Float64}
@test ts_hourly[1, "data_sum"] ≈ sum(t[1:3600])

ts_hourly = apply(ts_intraday_2, Dates.Hour, sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 24
@test typeof(ts_hourly[:, "data_sum"]) == Vector{Float64}
@test ts_hourly[1, "data_sum"] ≈ sum(t[1:3600])
@test ts_hourly[DateTime(2000, 1, 1, 0, 59, 59)][1,1] ≈ sum(t[1:3600])

ts_hourly = apply(ts_intraday_2, Dates.Hour(2), sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_hourly) == TSx.TS
@test typeof(ts_hourly.coredata) == DataFrame
@test DataFrames.nrow(ts_hourly.coredata) == 12
@test typeof(ts_hourly[:, "data_sum"]) == Vector{Float64}
@test ts_hourly[1, "data_sum"] ≈ sum(t[1:7200])
@test ts_hourly[DateTime(2000, 1, 1, 1, 59, 59)][1,1] ≈ sum(t[1:7200])

# Secondly -> Minutely
ts_minutely = apply(ts_intraday_2, Dates.Minute, first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440

ts_minutely = apply(ts_intraday_2, Dates.Minute, last)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440

ts_minutely = apply(ts_intraday_2, Dates.Minute(1), first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440

ts_minutely = apply(ts_intraday_2, Dates.Minute(2), first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 720

ts_minutely = apply(ts_intraday_2, Dates.Minute(720), first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 2

ts_minutely = apply(ts_intraday_2, Dates.Minute(1440), first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1

ts_minutely = apply(ts_intraday_2, Dates.Minute(100000), first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1

ts_minutely = apply(ts_intraday_2, Dates.Minute, Statistics.mean)
t = ts_intraday_2[:, "data"]
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440
@test typeof(ts_minutely[:, "data_mean"]) == Vector{Float64}
@test ts_minutely[1, "data_mean"] ≈ Statistics.mean(t[1:60])

ts_minutely = apply(ts_intraday_2, Dates.Minute, sum)
t = ts_intraday_2[:, "data"]
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440
@test typeof(ts_minutely[:, "data_sum"]) == Vector{Float64}
@test ts_minutely[1, "data_sum"] ≈ sum(t[1:60])

ts_minutely = apply(ts_intraday_2, Dates.Minute, sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440
@test typeof(ts_minutely[:, "data_sum"]) == Vector{Float64}
@test ts_minutely[1, "data_sum"] ≈ sum(t[1:60])
@test ts_minutely[DateTime(2000, 1, 1, 0, 0, 59)][1,1] ≈ sum(t[1:60])

ts_minutely = apply(ts_intraday_2, Dates.Minute(2), sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 720
@test typeof(ts_minutely[:, "data_sum"]) == Vector{Float64}
@test ts_minutely[1, "data_sum"] ≈ sum(t[1:120])
@test ts_minutely[DateTime(2000, 1, 1, 0, 1, 59)][1,1] ≈ sum(t[1:120])


# Secondly -> Secondly
ts_secondly = apply(ts_intraday_2, Dates.Second, first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400

ts_secondly = apply(ts_intraday_2, Dates.Second, last)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400

ts_secondly = apply(ts_intraday_2, Dates.Second(1), first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400
@test ts_secondly[:, "data_first"] == ts_intraday_2[:, "data"]

ts_secondly = apply(ts_intraday_2, Dates.Second(2), first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 43200

ts_secondly = apply(ts_intraday_2, Dates.Second(43200), first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 2

ts_secondly = apply(ts_intraday_2, Dates.Second(86400), first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 1

ts_secondly = apply(ts_intraday_2, Dates.Second(100000), first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 1

ts_secondly = apply(ts_intraday_2, Dates.Second, Statistics.mean)
t = ts_intraday_2[:, "data"]
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400
@test typeof(ts_secondly[:, "data_mean"]) == Vector{Float64}
@test ts_secondly[1, "data_mean"] ≈ Statistics.mean(t[1])

ts_secondly = apply(ts_intraday_2, Dates.Second, sum)
t = ts_intraday_2[:, "data"]
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400
@test typeof(ts_secondly[:, "data_sum"]) == Vector{Float64}
@test ts_secondly[1, "data_sum"] ≈ sum(t[1])

ts_secondly = apply(ts_intraday_2, Dates.Second, sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400
@test typeof(ts_secondly[:, "data_sum"]) == Vector{Float64}
@test ts_secondly[1, "data_sum"] ≈ sum(t[1])
@test ts_secondly[DateTime(2000, 1, 1, 0, 0, 0)][1,1] ≈ sum(t[1])

ts_secondly = apply(ts_intraday_2, Dates.Second(2), sum, last)
t = ts_intraday_2[:, "data"]
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 43200
@test typeof(ts_secondly[:, "data_sum"]) == Vector{Float64}
@test ts_secondly[1, "data_sum"] ≈ sum(t[1:2])
@test ts_secondly[DateTime(2000, 1, 1, 0, 0, 1)][1,1] ≈ sum(t[1:2])