DATA_SIZE = 360
index_timetype = Date(2000, 1, 1) + Day.(0:(DATA_SIZE-1))
vec1 = randn(DATA_SIZE)
vec2 = randn(DATA_SIZE)
vec3 = randn(DATA_SIZE)
df = DataFrame(Index=index_timetype, vec1=vec1, vec2=vec2, vec3=vec3)
ts = TSx.TS(df, 1)

functions = [mean, median, sum, minimum, maximum, std]
cols = [2, 3, :vec1, :vec3]          # col 1 is index
windowsize = [1, 5, 100, DATA_SIZE]

@test typeof(TSx.rollapply(mean, ts, 2, 5)) == TSx.TS

for fun in functions
    res = @test TSx.rollapply(fun, ts, 1, 5).coredata[!, 2] == RollingFunctions.rolling(fun, df[!, 2], 5)
end

for fun in functions
    colname = "vec1_rolling_$(fun)"
    res = @test TSx.rollapply(fun, ts, :vec1, 5).coredata[!, colname] == RollingFunctions.rolling(fun, df[!, :vec1], 5)

end

for fun in functions
    colname = "vec3_rolling_$(fun)"
    res = @test TSx.rollapply(fun, ts, :vec3, 100).coredata[!, colname] == RollingFunctions.rolling(fun, df[!, :vec3], 100)
end

for fun in functions
    colname = "vec3_rolling_$(fun)"
    res = @test TSx.rollapply(fun, ts, :vec3, DATA_SIZE).coredata[!, colname] == RollingFunctions.rolling(fun, df[!, :vec3], DATA_SIZE)
end

for fun in functions
    res = @test_throws ErrorException TSx.rollapply(fun, ts, 2, 10000)
end
