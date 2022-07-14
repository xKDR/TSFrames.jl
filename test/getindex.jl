ts = TS(df_timetype_index)
ts_long = TS(df_timetype_index_long_columns)

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
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 10; dt = ts.coredata[:, :Index][i]; n = 1; j = collect(1:n)
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = collect(1:n)
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, collect(1:n+1)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = [1,100]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, [1,2,101]])

# getindex(ts::TS, dt::D, j::AbstractVector{T}) where {D<:TimeType, T<:Union{String, Symbol}}
i = 1; dt = ts.coredata[:, :Index][i]; n = 10; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 10; dt = ts.coredata[:, :Index][i]; n = 1; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = ["data$x" for x in 1:n]
t = ts_long[i, j]
test_types(t)
@test t.coredata == DataFrame(df_timetype_index_long_columns[i, Cols(:Index, j)])

i = 100; dt = ts.coredata[:, :Index][i]; n = 100; j = ["data1", "data100"]
t = ts_long[i, j]
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

# getindex(ts::TS, i::Int, j::AbstractVector{Int})
j = 1; n = 10; i = collect(1:n)
t = ts_long[i, j]
@test typeof(t) == typeof(df_timetype_index_long_columns[i, j+1])
@test t == df_timetype_index_long_columns[i, j+1]

j = 1; n = 1; i = collect(1:n)
t = ts_long[i, j]
@test typeof(t) == typeof(df_timetype_index_long_columns[i, j+1])
@test t == df_timetype_index_long_columns[i, j+1]

j = 1; n = 400; i = collect(1:n)
t = ts_long[i, j]
@test typeof(t) == typeof(df_timetype_index_long_columns[i, j+1])
@test t == df_timetype_index_long_columns[i, j+1]

j = 1; i = [1, 400]
t = ts_long[i, j]
@test typeof(t) == typeof(df_timetype_index_long_columns[i, j+1])
@test t == df_timetype_index_long_columns[i, j+1]


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

# getindex(ts, i::UnitRange, j::Int)
i = 1:10; j = 1
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i, j+1])
@test length(t) == length(i)
@test t == df_timetype_index[i, :data]

# getindex(ts::TS, i::Int, j::UnitRange)
i = 2; j = 1:1
t = ts[i, j]
test_types(t)
@test DataFrames.nrow(t.coredata) == length(i)
@test DataFrames.ncol(t.coredata) == length(j)+1
@test t.coredata[!, :Index] == [df_timetype_index[i, :Index]]
@test t.coredata[!, :data] == [df_timetype_index[i, :data]]

# getindex(ts::TS, i::UnitRange, j::Symbol)
i = 1:10; j = :data
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i,j])
@test t == df_timetype_index[i, j]

# getindex(ts::TS, i::UnitRange, j::String)
i = 1:10; j = "data"
t = ts[i, j]
@test typeof(t) == typeof(df_timetype_index[i,j])
@test t == df_timetype_index[i, j]

# getindex(ts::TS, r::StepRange{T, V}) where {T<:TimeType, V<:Period}
ind = Date(2007, 1, 1):Day(1):Date(2007, 2, 1)
t = ts[ind]
test_types(ts[ind])
@test t.coredata[!, :Index] == collect(ind)
