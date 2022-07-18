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

ts_weekly = apply(ts_daily_1, Dates.Week(12), first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

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


# Daily -> Daily
ts_test_daily = apply(ts_daily_1, Dates.Day, first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360

ts_test_daily = apply(ts_daily_1, Dates.Day, last)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360


# Secondly -> Yearly
ts_yearly = apply(ts_intraday_2, Dates.Year, first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

ts_yearly = apply(ts_intraday_2, Dates.Year, last)
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


# Secondly -> Weekly
ts_weekly = apply(ts_intraday_2, Dates.Week, first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 1

ts_weekly = apply(ts_intraday_2, Dates.Week, last)
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


# Secondly -> Daily
ts_test_daily = apply(ts_intraday_2, Dates.Day, first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 1

ts_test_daily = apply(ts_intraday_2, Dates.Day, last)
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


# Secondly -> Minutely
ts_minutely = apply(ts_intraday_2, Dates.Minute, first)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440

ts_minutely = apply(ts_intraday_2, Dates.Minute, last)
@test typeof(ts_minutely) == TSx.TS
@test typeof(ts_minutely.coredata) == DataFrame
@test DataFrames.nrow(ts_minutely.coredata) == 1440


# Secondly -> Secondly
ts_secondly = apply(ts_intraday_2, Dates.Second, first)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400

ts_secondly = apply(ts_intraday_2, Dates.Second, last)
@test typeof(ts_secondly) == TSx.TS
@test typeof(ts_secondly.coredata) == DataFrame
@test DataFrames.nrow(ts_secondly.coredata) == 86400
