using Dates
using DataFrames

# constants
const DATA_SIZE = 400

# global variables
const data_vector = randn(DATA_SIZE)
const data_array = Array([data_vector data_vector])

const index_range = 1:DATA_SIZE
const index_integer = collect(index_range)
const index_timetype = collect(Date(2007, 1, 1):Day(1):Date(2008, 2, 4))

const df_vector = DataFrame([data_vector], ["data"])
const df_integer_index = DataFrame(Index = index_integer, data = data_vector)
const df_timetype_index = DataFrame(Index = index_timetype, data = data_vector)

function test_df_index_integer()
    ts = TS(df_integer_index, 1)
    @test typeof(ts) == TSx.TS
    @test ts.coredata == df_integer_index
end

function test_df_index_symbol()
    ts = TS(df_integer_index, :Index)
    @test typeof(ts) == TSx.TS
    @test ts.coredata == df_integer_index
end

function test_df_index_string()
    ts = TS(df_integer_index, "Index")
    @test typeof(ts) == TSx.TS
    @test ts.coredata == df_integer_index
end

function test_df_index_range()
    ts = TS(df_vector, index_range)
    @test typeof(ts) == TSx.TS
    @test ts.coredata[!, :data] == df_vector[!, :data]
end

function test_vector_index_vector()
    ts = TS(data_vector, index_integer)
    @test typeof(ts) == TSx.TS
    @test ts.coredata[!, :Index] == index_integer
    @test ts.coredata[!, 2] == data_vector
end

function test_vector()
    ts = TS(data_vector)
    @test typeof(ts) == TSx.TS
    @test ts.coredata[!, :Index] == collect(1:length(data_vector))
    @test ts.coredata[!, 2] == data_vector
end

function test_array()
    ts = TS(data_array)
    @test typeof(ts) == TSx.TS
    @test typeof(ts.coredata) == DataFrames.DataFrame
    @test ts.coredata[!, :Index] == collect(1:size(data_vector)[1])
    @test Matrix(ts.coredata[!, Not(:Index)]) == data_array
end

test_df_index_integer()
test_df_index_symbol()
test_df_index_string()
test_df_index_range()
test_vector_index_vector()
test_vector()
test_array()
