DATA_SIZE_1 = 360
data_vector_1 = randn(DATA_SIZE)
index_timetype_1 = Date(2007, 1,1) + Day.(0:(DATA_SIZE - 1))

df_timetype_index = DataFrame(Index = index_timetype, data = data_vector)
ts_daily_1 = TS(df_timetype_index, 1)
ts_daily_matrix_1 = TS(DataFrames.innerjoin(df_timetype_index, df_timetype_index, on=:Index, makeunique=true))

# function apply(ts::TS, period::Union{T,Type{T}}, fun::V, index_at::Function=first) where {T<:Union{DatePeriod,TimePeriod}, V<:Function}

# Resampling

# Daily -> Monthly
ts_monthly = apply(ts_daily, Dates.Month, first)
@test typeof(ts_monthly) == TSx.TS
@test typeof(ts_monthly.coredata) == DataFrame
@test DataFrames.nrow(ts_monthly.coredata) == 12 # 360 days
@test ts_monthly.coredata[1, :Index] == df_timetype_index[1, :Index]

# Daily -> Yearly
ts_yearly = apply(ts_daily, Dates.Year, first)
@test typeof(ts_yearly) == TSx.TS
@test typeof(ts_yearly.coredata) == DataFrame
@test DataFrames.nrow(ts_yearly.coredata) == 1

# Daily -> Weekly
ts_weekly = apply(ts_daily, Dates.Week, first)
@test typeof(ts_weekly) == TSx.TS
@test typeof(ts_weekly.coredata) == DataFrame
@test DataFrames.nrow(ts_weekly.coredata) == 52

# Daily -> Quarterly
ts_quarterly = apply(ts_daily, Dates.Quarter, first)
@test typeof(ts_quarterly) == TSx.TS
@test typeof(ts_quarterly.coredata) == DataFrame
@test DataFrames.nrow(ts_quarterly.coredata) == 4

# Daily -> Daily
ts_test_daily = apply(ts_daily, Dates.Day, first)
@test typeof(ts_test_daily) == TSx.TS
@test typeof(ts_test_daily.coredata) == DataFrame
@test DataFrames.nrow(ts_test_daily.coredata) == 360
