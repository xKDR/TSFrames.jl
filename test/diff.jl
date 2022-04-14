DATA_SIZE = 360
index_timetype = Date(2000, 1,1) + Day.(0:(DATA_SIZE - 1))
vec1 = randn(DATA_SIZE)
vec2 = randn(DATA_SIZE)
vec3 = randn(DATA_SIZE)
df = DataFrame(Index = index_timetype,vec1 = vec1,vec2 =  vec2,vec3 =  vec3)
ts = TS(df, 1)

