DATA_SIZE = 360
index_timetype = Date(2000, 1,1) + Day.(0:(DATA_SIZE - 1))
vec1 = randn(DATA_SIZE)
vec2 = randn(DATA_SIZE)
vec3 = randn(DATA_SIZE)
df = DataFrame(Index = index_timetype,vec1 = vec1,vec2 =  vec2,vec3 =  vec3)
ts = TS(df, 1)

functions = [mean, median, sum, minimum, maximum, std]
cols: [1, 3, :vec1, :vec3]
windowsize = [1, 100, DATASIZE]

function ts_test(func, col, windowsize)
    return TSx.rollapply(func, ts, co, windowsize)
end

for fun in functions
    @ts_test(fun, 1, 1).coredata[!, 2] == RollingFunctions.rolling(fun, df[!, 1], 1)
end

for fun in functions
    @ts_test(fun, 3, 100).coredata[!,2] == RollingFunctions.rolling(fun, df[!, 3], 100)
end

for fun in functions
    @ts_test(fun, :vec1, 100).coredata[!,2] == RollingFunctions.rolling(fun, df[!, :vec1], 100)
end

for fun in functions
    @ts_test(fun, :vec3, DATA_SIZE).coredata[!,2] == RollingFunctions.rolling(fun, df[!, :vec3], DATA_SIZE)
end



