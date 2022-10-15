dates = Date(2022, 1, 1):Day(1):Date(2022, 1, 15)
ts = TS(DataFrame(Index=dates, x1=1:15))

# testing Tables.rows
for row in Tables.rows(ts)
    @test day(row[:Index]) == row[:x1]
end

# testing Tables.columns
for col in Tables.columns(ts)
    @test length(col) == 15
end

# testing Tables.rowtable
rowTable = Tables.rowtable(ts) 
@test typeof(rowTable) == Vector{NamedTuple{(:Index, :x1), Tuple{Date, Int64}}}
for i in 1:15
    date = rowTable[i][:Index]
    @test year(date) == 2022
    @test month(date) == 1
    @test day(date) == i

    @test rowTable[i][:x1] == day(date)
end

# testing Tables.columntable
columnTable = Tables.columntable(ts)
@test typeof(columnTable) == NamedTuple{(:Index, :x1), Tuple{Vector{Date}, Vector{Int64}}}
for i in 1:15
    date = columnTable[:Index][i]
    @test year(date) == 2022
    @test month(date) == 1
    @test day(date) == i

    @test columnTable[:x1][i] == day(date)
end
