ts = TS(df_timetype_index)

function test_types(obj::TS)
    @test typeof(obj.coredata) == DataFrame
end

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
t = ts[i, [j]]
test_types(t)
@test DataFrames.nrow(t.coredata) == length(i)
@test DataFrames.ncol(t.coredata) == length(j)+1 # Index + Ncols
@test t.coredata[!, :Index] == df_timetype_index[i, :Index]
@test t.coredata[!, :data] == df_timetype_index[i, :data]

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
