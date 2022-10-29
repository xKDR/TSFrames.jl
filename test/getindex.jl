ts = TS(df_timetype_index)
ts_long = TS(df_timetype_index_long_columns)
datetimes = collect(DateTime(2007, 1, 2):Hour(1):DateTime(2007, 1, 10));
tsdatetimes = TS(random(length(datetimes)), datetimes);

function test_types(obj::TS)
    @test typeof(obj.coredata) == DataFrame
end

### Row, Column Scalar

# getindex(ts, i::Int, j::Int)
i = 1; j = 1
t = ts[i, j]
@test typeof(t) == eltype(df_timetype_index[:, j+1])
@test t == df_timetype_index[i, j+1]

# getindex(ts::TS, i::Int, j::Symbol)
i = 1; j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j])
@test t == df_timetype_index[i, j]

# getindex(ts::TS, i::Int, j::String)
i = 1; j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j])
@test t == df_timetype_index[i, j]

# getindex(ts::TS, dt::T, j::Int) where {T<:TimeType}
dt = ts.coredata[:, :Index][1]; j = 1;
t = ts[dt ,j]
@test typeof(t) == typeof(df_timetype_index[1, j+1])
@test t == df_timetype_index[1, j+1]

# getindex(ts::TS, dt::T, j::Symbol) where {T<:TimeType}
dt = ts.coredata[:, :Index][1]; j = :data;
t = ts[dt,j]
@test typeof(t) == typeof(df_timetype_index[1, j])
@test t == df_timetype_index[1, j]

# getindex(ts::TS, dt::T, j::String) where {T<:TimeType}
dt = ts.coredata[:, :Index][1]; j = "data";
t = ts[dt,j]
@test typeof(t) == typeof(df_timetype_index[1, j])
@test t == df_timetype_index[1, j]

### Row Scalar, Column Vector

# getindex(ts::TS, i::Int, j::AbstractVector{Int})
i = 1; n = 10; j = collect(1:n)
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 1; n = 1; j = collect(1:n)
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 1; n = 100; j = collect(1:n)
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 1; n = 100; j = [1,100]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, [1,2,101]])

# getindex(ts::TS, i::Int, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
i = 1; n = 10; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 1; n = 1; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 1; n = 100; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 1; n = 100; j = ["data1", "data100"]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

# getindex(ts::TS, dt::T, j::AbstractVector{Int}) where {T<:TimeType}
i = 1; dt = ts.coredata[:, :Index][i]; n = 10; j = collect(1:n)
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 10; dt = ts.coredata[:, :Index][i]; n = 1; j = collect(1:n)
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = collect(1:n)
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = [1,100]
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, [1,2,101]])

# getindex(ts::TS, dt::D, j::AbstractVector{T}) where {D<:TimeType, T<:Union{String, Symbol}}
i = 1; dt = ts.coredata[:, :Index][i]; n = 10; j = ["data$x" for x in 1:n]
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 10; dt = ts.coredata[:, :Index][i]; n = 1; j = ["data$x" for x in 1:n]
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = ["data$x" for x in 1:n]
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = ["data1", "data100"]
t = ts_long[dt, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])


# Row Scalar, Column Unitrange

# getindex(ts::TS, i::Int, j::UnitRange)
i = 1; n = 10; j = 1:n
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 1; n = 1; j = 1:n
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 1; n = 100; j = 1:n
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])


# Row Vector, Column Scalar

# getindex(ts::TS, i::AbstractVector{Int}, j::Int)
n = 10; i = collect(1:n); j = 1
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j+1])
@test t == df_timetype_index[i, j+1]

n = 1; i = collect(1:n); j = 1
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j+1])
@test t == df_timetype_index[i, j+1]

n = 400; i = collect(1:n); j = 1
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j+1])
@test t == df_timetype_index[i, j+1]

i = [1, 400];j = 1
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j+1])
@test t == df_timetype_index[i, j+1]

# getindex(ts::TS, i::AbstractVector{Int}, j::Symbol)
n = 10; i = collect(1:n); j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, :data])
@test t == df_timetype_index[i, :data]

n = 1; i = collect(1:n); j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, :data])
@test t == df_timetype_index[i, :data]

n = 400; i = collect(1:n); j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, :data])
@test t == df_timetype_index[i, :data]

i = [1, 400];j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, :data])
@test t == df_timetype_index[i, :data]

# getindex(ts::TS, i::AbstractVector{Int}, j::String)
n = 10; i = collect(1:n); j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, "data"])
@test t == df_timetype_index[i, "data"]

n = 1; i = collect(1:n); j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, "data"])
@test t == df_timetype_index[i, "data"]

n = 400; i = collect(1:n); j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, "data"])
@test t == df_timetype_index[i, "data"]

i = [1, 400];j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, "data"])
@test t == df_timetype_index[i, "data"]

# getindex(ts::TS, dt::AbstractVector{T}, j::Int) where {T<:TimeType}
dt = Date(2007, 1, 1):Day(1):Date(2007, 1, 15)
t = ts_long[dt, 10]
@test typeof(t) <: Vector
@test t == data_array_long[:, 10][1:15]

# getindex(ts::TS, dt::AbstractVector{T}, j::Union{String, Symbol}) where {T<:TimeType}

# Row Vector, Column Vector

# getindex(ts::TS, i::AbstractVector{Int}, j::AbstractVector{Int})
n = 10; m = 10; i = collect(1:n); j = collect(1:m)
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, collect(1:m+1)])
@test t.coredata == df_timetype_index_long_columns[i, collect(1:m+1)]

n = 1; m = 1; i = collect(1:n); j = collect(1:m)
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, collect(1:m+1)])
@test t.coredata == df_timetype_index_long_columns[i, collect(1:m+1)]

n = 400; m = 100; i = collect(1:n); j = collect(1:m)
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, collect(1:m+1)])
@test t.coredata == df_timetype_index_long_columns[i, collect(1:m+1)]

i = [2*x for x in 1:50]; j = [2*x for x in 1:50]
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, [(2*x+1) for x in 0:50]])
@test t.coredata == df_timetype_index_long_columns[i, [(2*x+1) for x in 0:50]]

# getindex(ts::TS, i::AbstractVector{Int}, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
n = 10; m = 10; i = collect(1:n); j = insert!(["data$x" for x in 1:m], 1, "Index")
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, j])
@test t.coredata == df_timetype_index_long_columns[i, j]

n = 1; m = 1; i = collect(1:n); j = insert!(["data$x" for x in 1:m], 1, "Index")
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, j])
@test t.coredata == df_timetype_index_long_columns[i, j]

n = 400; m = 100; i = collect(1:n); j = insert!(["data$x" for x in 1:m], 1, "Index")
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, j])
@test t.coredata == df_timetype_index_long_columns[i, j]

i = [2*x for x in 1:50]; j = insert!(["data$x" for x in [2*y for y in 1:50]], 1, "Index")
t = ts_long[i, j]
@test typeof(t.coredata) == typeof(df_timetype_index_long_columns[i, j])
@test t.coredata == df_timetype_index_long_columns[i, j]

# getindex(ts::TS, dt::AbstractVector{D}, j::AbstractVector{T}) where {D<:TimeType, T<:Union{String, Symbol}}
dt = Date(2007, 1, 1):Day(1):Date(2007, 1, 15); j = 1:5
t = ts_long[dt, j]
test_types(t)
for i in j
    @test t[:, i] == data_array_long[:, i][1:length(dt)]
end

# Row Indexing

# getindex(ts, i::Int)
ind = 1
test_types(ts[ind])
@test ts[ind].coredata == df_timetype_index[[ind], :]

# getindex(ts, r::UnitRange)
ind = 4:10
test_types(ts[ind])
@test ts[ind].coredata == df_timetype_index[ind, :]

# getindex(ts, a::AbstractVector{Int64})
ind = collect(4:10)
test_types(ts[ind])
@test ts[ind].coredata == df_timetype_index[ind, :]

# getindex(ts, d::Date)
ind = Date(2007, 2, 1)
test_types(ts[ind])
@test TSx.index(ts[ind]) == [ind]

# getindex(ts, y::Year)
ind = Year(2007)
test_types(ts[ind])
@test unique(Dates.year.(TSx.index(ts[ind]))) == [2007]

# getindex(ts, y::Year, m::Month)
y = Year(2007)
m = Month(3)
test_types(ts[y, m])
@test unique(Dates.yearmonth.(TSx.index(ts[y, m]))) == [(2007, 3)]

# getindex(ts, i::String)
ind = "2007-10-01"
d = Date(2007, 10, 1)
test_types(ts[ind])
@test TSx.index(ts[ind]) == [d]

# getindex(ts, i::Int, j::Int)
i = 1; j = 1
t = ts[i, [j]]
test_types(t)
@test t.coredata[!, :Index] == [df_timetype_index[i, 1]]
@test t.coredata[!, :data] == [df_timetype_index[i, j+1]]

# getindex(ts, i::UnitRange, j::Int)
i = 1:10; j = 1
t = ts[i, j]
@test typeof(t) <: Vector
@test t == data_vector[i]

# getindex(ts::TS, i::Int, j::UnitRange)
i = 2; j = 1:1
t = ts[i, j]
test_types(t)
@test DataFrames.nrow(t.coredata) == length(i)
@test DataFrames.ncol(t.coredata) == length(j)+1
@test t.coredata[!, :Index] == [df_timetype_index[i, :Index]]
@test t.coredata[!, :data] == df_timetype_index[[i], :data]

# getindex(ts::TS, i::Int, j::Symbol)
i = 1; j = :data
t = ts[i, [j]]
test_types(t)
@test t.coredata[!, j] == [df_timetype_index[i, j]]

# getindex(ts::TS, i::UnitRange, j::Symbol)
i = 1:10; j = :data
t = ts[i, [j]]
test_types(t)
@test t.coredata[!, j] == df_timetype_index[i, j]

# getindex(ts::TS, i::Int, j::String)
i = 1; j = "data"
t = ts[i, [j]]
test_types(t)
@test t.coredata[!, j] == [df_timetype_index[i, j]]

# getindex(ts::TS, i::UnitRange, j::String)
i = 1:10; j = "data"
t = ts[i, [j]]
test_types(t)
@test t.coredata[!, j] == df_timetype_index[i, j]

# getindex(ts::TS, r::StepRange{T, V}) where {T<:TimeType, V<:Period}
ind = Date(2007, 1, 1):Day(1):Date(2007, 2, 1)
t = ts[ind]
test_types(ts[ind])
@test t.coredata[!, :Index] == collect(ind)

# getindex(ts::TS, y::Year, m::Month, w::Week)
@test index(getindex(ts, Year(2007), Month(1), Week(6))) == []
@test index(getindex(ts, Year(2007), Month(1), Week(0))) == []
@test index(getindex(ts, Year(2007), Month(1), Week(-1))) == []
@test index(getindex(ts, Year(2007), Month(1), Week(2))) == [
    Date(2007, 01, 08), Date(2007, 01, 09), Date(2007, 01, 10),
    Date(2007, 01, 11), Date(2007, 01, 12), Date(2007, 01, 13), Date(2007, 01, 14) ]

# getindex(ts::TS, y::Year, m::Month, d::Day, h::Hour)
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(25))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(-1))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(3))) ==
    [DateTime(2007, 01, 02, 03, 00, 00)]

# getindex(ts::TS, y::Year, m::Month, d::Day, h::Hour, min::Minute)
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(1), Minute(-1))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(-1), Minute(0))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(-1), Minute(61))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(0), Minute(0))) ==
    [DateTime(2007, 01, 02, 0, 0, 0)]

# getindex(ts::TS, y::Year, m::Month, d::Day, h::Hour, min::Minute, sec::Second)
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(1), Minute(0), Second(-1))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(-1), Minute(0), Second(61))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2), Hour(0), Minute(0), Second(0))) ==
    [DateTime(2007, 01, 02, 0, 0, 0)]

# getindex(ts::TS, y::Year, m::Month, d::Day, h::Hour, min::Minute, sec::Second, ms::Millisecond)
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2),
                     Hour(1), Minute(0), Second(0), Millisecond(-1))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2),
                     Hour(-1), Minute(0), Second(0), Millisecond(1001))) == []
@test index(getindex(tsdatetimes, Year(2007), Month(1), Day(2),
                     Hour(0), Minute(0), Second(0), Millisecond(0))) == [DateTime(2007, 01, 02, 0, 0, 0)]

# getindex(ts::TS, y::Year, q::Quarter)
y = Year(2007); q = Quarter(2)
dates = Date(2007, 4, 1):Day(1):Date(2007, 6, 30)
start_index = (Date(2007, 4, 1) - Date(2007, 1, 1)).value + 1
end_index = start_index + length(dates) - 1
t = ts[y, q]
test_types(t)
@test t[:, :Index] == dates
@test t[:, :data] == data_vector[start_index:end_index]

y = Year(2007); q = Quarter(4)
dates = Date(2007, 10, 1):Day(1):Date(2007, 12, 31)
start_index = (Date(2007, 10, 1) - Date(2007, 1, 1)).value + 1
end_index = start_index + length(dates) - 1
t = ts[y, q]
test_types(t)
@test t[:, :Index] == dates
@test t[:, :data] == data_vector[start_index:end_index]

# getindex(ts::TS, y::Year, m::Month, d::Day)
y = Year(2007); m = Month(1); d = Day(1)
t = ts[y, m, d]
test_types(t)
@test t[:, :Index] == [Date(2007, 1, 1)]
@test t[:, :data] == data_vector[1, :]

# getindex(ts::TS, ::Colon, j::Int)
j = 10
t = ts_long[:, j]
@test typeof(t) <: Vector
@test t == data_array_long[:, j]
