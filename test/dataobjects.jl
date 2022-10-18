# constants
DATA_SIZE = 400;

# global variables
random(x) = rand(MersenneTwister(123), x);
data_vector = randn(DATA_SIZE);
integer_data_vector = rand(1:100, DATA_SIZE);
data_array = Array([data_vector data_vector]);

index_range = 1:DATA_SIZE;
index_integer = collect(index_range);
index_timetype = Date(2007, 1,1) + Day.(0:(DATA_SIZE - 1));

df_vector = DataFrame([data_vector], ["data"]);
df_integer_index = DataFrame(Index = index_integer, data = data_vector);
df_timetype_index = DataFrame(Index = index_timetype, data = data_vector);
