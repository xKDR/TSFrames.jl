# Constants
YEAR = 2022
MONTH = 1
DAYS = 15

dates = Date(YEAR, MONTH, 1):Day(1):Date(YEAR, MONTH, DAYS)
ts = TS(DataFrame(Index=dates, x1=1:DAYS))

@test Tables.istable(ts)

# testing Tables.rows
@test Tables.rowaccess(ts)
dayValue = 1
for row in Tables.rows(ts)
    date = row[:Index]
    @test year(date) == YEAR
    @test month(date) == MONTH
    @test day(date) == dayValue
    @test row[:x1] == dayValue

    dayValue = dayValue + 1
end

# testing Tables.columns
for col in Tables.columns(ts)
    @test day.(col) == 1:DAYS

    if (typeof(col) == Vector{Date})
        @test year.(col) == fill(YEAR, DAYS)
        @test month.(col) == fill(MONTH, DAYS)
    end
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

# testing Tables.namedtupleiterator
for namedtuple in Tables.namedtupleiterator(ts)
    @test day(namedtuple[:Index]) == namedtuple[:x1]
end

# testing columnindex
@test Tables.columnindex(ts, :Index) == 1
@test Tables.columnindex(ts, "Index") == 1
@test Tables.columnindex(ts, :x1) == 2
@test Tables.columnindex(ts, "x1") == 2

# testing Tables.schema
@test Tables.schema(ts).names == (:Index, :x1)
@test Tables.schema(ts).types == (Date, Int64)

# testing Tables.getcolumn
indexCol = Tables.getcolumn(ts, :Index)
x1Col = Tables.getcolumn(ts, :x1)
@test indexCol == Tables.getcolumn(ts, 1)
@test x1Col == Tables.getcolumn(ts, 2)
for i in 1:15
    @test year(indexCol[i]) == 2022
    @test month(indexCol[i]) == 1
    @test day(indexCol[i]) == i

    @test day(indexCol[i]) == x1Col[i]
end
