dates = Date(2022, 1, 1):Day(1):Date(2022, 1, 15)
ts = TS(DataFrame(Index=dates), 1:15)

# testing Tables.rows
for row in Tables.rows(ts)
    @test day(row[:Index] == row[:x1])
end

# testing Tables.columns
for col in Tables.columns(ts)
    @test length(col) == 15
end
