function test_df_index_integer()
    df = DataFrame(A=["a", "b"], B=[1, 2])
    @test_throws ArgumentError TSFrame(df)
    df = DataFrame(A=[:a, :b], B=[1, 2])
    @test_throws ArgumentError TSFrame(df)

    ts = TSFrame(df_integer_index, 1)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_timetype()
    ts = TSFrame(df_timetype_index, 1)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata == df_timetype_index
end

function test_df_index_symbol()
    ts = TSFrame(df_integer_index, :Index)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_string()
    ts = TSFrame(df_integer_index, "Index")
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_range()
    ts = TSFrame(df_vector, index_range)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata[!, :data] == df_vector[!, :data]
end

function test_vector_index_vector_integer()
    ts = TSFrame(data_vector, index_integer)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata[!, :Index] == index_integer
    @test ts.coredata[!, 2] == data_vector
end

function test_vector_index_vector_timetype()
    ts = TSFrame(data_vector, index_timetype)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata[!, :Index] == index_timetype
    @test ts.coredata[!, 2] == data_vector
end

function test_vector()
    ts = TSFrame(data_vector)
    @test typeof(ts) == TimeFrames.TSFrame
    @test ts.coredata[!, :Index] == collect(1:length(data_vector))
    @test ts.coredata[!, 2] == data_vector
end

function test_array()
    ts = TSFrame(data_array)
    @test typeof(ts) == TimeFrames.TSFrame
    @test typeof(ts.coredata) == DataFrames.DataFrame
    @test ts.coredata[!, :Index] == collect(1:size(data_vector)[1])
    @test Matrix(ts.coredata[!, Not(:Index)]) == data_array
end

function test_colnames()
    random(x) = rand(MersenneTwister(123), x)
    dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))

    ts = TSFrame(random(10), colnames=[:A])
    @test names(ts.coredata) == ["Index", "A"]

    ts = TSFrame(random(10), dates, colnames=[:A])
    @test names(ts.coredata) == ["Index", "A"]

    ts = TSFrame([random(10) random(10)], colnames=[:A, :B])
    @test names(ts.coredata) == ["Index", "A", "B"]

    ts = TSFrame([random(10) random(10)], dates, colnames=[:A, :B])
    @test names(ts.coredata) == ["Index", "A", "B"]
end

# Run each test
# NOTE: Do not forget to add any new test-function created above
# otherwise that test won't run.
test_df_index_integer()
test_df_index_timetype()
test_df_index_symbol()
test_df_index_string()
test_df_index_range()
test_vector_index_vector_integer()
test_vector_index_vector_timetype()
test_vector()
test_array()
test_colnames()
