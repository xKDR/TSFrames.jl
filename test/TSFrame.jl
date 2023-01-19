function test_df_index_integer()
    df = DataFrame(A=["a", "b"], B=[1, 2])
    @test_throws ArgumentError TSFrame(df)
    df = DataFrame(A=[:a, :b], B=[1, 2])
    @test_throws ArgumentError TSFrame(df)

    ts = TSFrame(df_integer_index, 1)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_timetype()
    ts = TSFrame(df_timetype_index, 1)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata == df_timetype_index
end

function test_df_index_symbol()
    ts = TSFrame(df_integer_index, :Index)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_string()
    ts = TSFrame(df_integer_index, "Index")
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata == df_integer_index
end

function test_df_index_range()
    ts = TSFrame(df_vector, index_range)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata[!, :data] == df_vector[!, :data]
end

function test_vector_index_vector_integer()
    ts = TSFrame(data_vector, index_integer)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata[!, :Index] == index_integer
    @test ts.coredata[!, 2] == data_vector
end

function test_vector_index_vector_timetype()
    ts = TSFrame(data_vector, index_timetype)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata[!, :Index] == index_timetype
    @test ts.coredata[!, 2] == data_vector
end

function test_vector()
    ts = TSFrame(data_vector)
    @test typeof(ts) == TSFrames.TSFrame
    @test ts.coredata[!, :Index] == collect(1:length(data_vector))
    @test ts.coredata[!, 2] == data_vector
end

function test_array()
    ts = TSFrame(data_array)
    @test typeof(ts) == TSFrames.TSFrame
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

function test_empty_timeframe_cons() 
    #test for int type
    tfi1 = TSFrame(Int, n=1)
    tfi2 = TSFrame(Int, n=2)

    @test size(tfi1)==(0, 1)
    @test size(tfi2)==(0, 2)

    @test TSFrames.nrow(tfi1)==0
    @test TSFrames.nrow(tfi2)==0

    @test TSFrames.ncol(tfi1)==1
    @test TSFrames.ncol(tfi2)==2

    @test eltype(index(tfi1))==Int
    @test eltype(index(tfi2))==Int

    #test for date type
    tfd1 = TSFrame(Date, n=1)
    tfd2 = TSFrame(Date, n=2)

    @test size(tfd1)==(0, 1)
    @test size(tfd2)==(0, 2)

    @test TSFrames.nrow(tfd1)==0
    @test TSFrames.nrow(tfd2)==0

    @test TSFrames.ncol(tfd1)==1
    @test TSFrames.ncol(tfd2)==2

    @test eltype(index(tfd1))==Date
    @test eltype(index(tfd2))==Date

    #test for errors
    @test_throws DomainError TSFrame(Int, n=-1)
    @test_throws DomainError TSFrame(Int, n=0)
    @test_throws DomainError TSFrame(Date, n=-1)
    @test_throws DomainError TSFrame(Date, n=0)

    # testing empty constructor for specific column names and types
    ts_empty_int = TSFrame(Int, [(Int, :col1), (Float64, :col2), (String, :col3)])
    ts_empty_date = TSFrame(Date, [(Int, :col1), (Float64, :col2), (String, :col3)])

    @test size(ts_empty_int)==(0, 3)
    @test size(ts_empty_date)==(0, 3)

    @test TSFrames.nrow(ts_empty_int)==0
    @test TSFrames.nrow(ts_empty_date)==0

    @test TSFrames.ncol(ts_empty_int)==3
    @test TSFrames.ncol(ts_empty_date)==3

    @test propertynames(ts_empty_int.coredata) == [:Index, :col1, :col2, :col3]
    @test propertynames(ts_empty_date.coredata) == [:Index, :col1, :col2, :col3]

    @test eltype(index(ts_empty_int))==Int
    @test eltype(index(ts_empty_date))==Date

    @test eltype(ts_empty_int[:, :col1])==Int
    @test eltype(ts_empty_date[:, :col1])==Int

    @test eltype(ts_empty_int[:, :col2])==Float64
    @test eltype(ts_empty_date[:, :col2])==Float64

    @test eltype(ts_empty_int[:, :col3])==String
    @test eltype(ts_empty_date[:, :col3])==String
end

@testset "issorted in constructor" begin
    unsorted = randperm(1000)
    unsorted_frame = TSFrame(1:1000, unsorted; issorted = true)
    @test !(issorted(unsorted_frame.coredata[!, :Index]))
    sorted_frame = TSFrame(1:1000, unsorted; issorted = false)
    @test issorted(sorted_frame.coredata[!, :Index])
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
test_empty_timeframe_cons()
