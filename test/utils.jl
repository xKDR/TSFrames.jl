using TSFrames

ts = TSFrame(DataFrame(a=["a", "b", "c"], b=[1,2, missing]), [1, 2, 3]) ;
NUM_COLUMNS = 5

###
# describe()
dd = TSFrames.describe(ts) ;
@test names(dd) == [ "variable", "mean", "min", "median", "max", "nmissing", "eltype" ] ;
@test dd[1, :variable] == :Index ;
@test dd[1, :min] == 1 ;
@test dd[1, :max] == 3 ;
@test dd[1, :nmissing] == 0 ;
@test dd[1, :eltype] == Int64 ;

@test dd[3, :variable] == :b ;
@test dd[3, :mean] == 1.5 ;
@test dd[3, :min] == 1 ;
@test dd[3, :median] == 1.5 ;
@test dd[3, :max] == 2 ;
@test dd[3, :nmissing] == 1 ;
@test dd[3, :eltype] == Union{Missing, Int64} ;

dd = TSFrames.describe(ts, :mean) ;
@test "mean" in names(dd) ;
@test !("median" in names(dd)) ;
@test dd[3, :mean] == 1.5 ;

dd = TSFrames.describe(ts, :mean, cols=:b) ;
@test DataFrames.nrow(dd) == 1 ;
@test DataFrames.ncol(dd) == 2 ;
@test dd[1, :variable] == :b ;
@test !("a" in dd[!, :variable]) ;
@test dd[1, :mean] == 1.5 ;
###

###
# lastindex()
@test lastindex(ts) == length(ts.coredata[!, :Index]);
###

###
# length()
@test length(ts) == length(ts.coredata[!, :Index]);
###

###
# size()
@test size(ts) == (length(ts.coredata[!, :Index]), length(ts.coredata[1, :]) - 1);
###

###
# names()
@test ["Index", names(ts)...] == names(ts.coredata);
###

###
# first()
@test first(ts).coredata == ts.coredata[[1], :] ;
###

###
# head()
@test head(ts, 2).coredata == ts.coredata[[1, 2], :];
###

###
# tail()
@test tail(ts, 2).coredata.Index == last(ts.coredata, 2).Index;
@test tail(ts, 2).coredata.a == last(ts.coredata, 2).a;
###

###
# _check_consistency()
@test TSFrames._check_consistency(ts) == true
@test TSFrames._check_consistency(TSFrame([:a, :b], [2,1])) == true;

ts = TSFrame(data_vector, 1:length(data_vector));
ts.coredata.Index = sample(index_integer, length(data_vector), replace=true);
@test TSFrames._check_consistency(ts) == false;
###

### TSFrames.rename!
old_names = ["x" * string(i) for i in 1:NUM_COLUMNS]
new_names = ["X" * string(i) for i in 1:NUM_COLUMNS]
duplicate_names = ["x1" for i in 1:NUM_COLUMNS]

# Index column not allowed
ts = TSFrame(Date; n = NUM_COLUMNS)
rand_index = random(1:NUM_COLUMNS)
new_names[rand_index] = "Index"
@test_throws ArgumentError TSFrames.rename!(ts, new_names)
@test_throws ArgumentError TSFrames.rename!(ts, Symbol.(new_names))
new_names[rand_index] = "X" * string(rand_index)

# rename!(ts::TSFrame, colnames::AbstractVector{String}; makeunique=false)
TSFrames.rename!(ts, new_names)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.(new_names)))

# rename!(ts::TSFrame, colnames::AbstractVector{Symbol}; makeunique=false)
TSFrames.rename!(ts, Symbol.(old_names))
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.(old_names)))

# rename!(ts::TSFrame, colnames::AbstractVector{String}; makeunique=true)
TSFrames.rename!(ts, duplicate_names, makeunique=true)
@test isequal(propertynames(ts.coredata), vcat([:Index], [:x1], Symbol.(["x1_" * string(i) for i in 1:NUM_COLUMNS - 1])))

# rename!(ts::TSFrame, colnames::AbstractVector{Symbol}; makeunique=true)
TSFrames.rename!(ts, Symbol.(duplicate_names), makeunique=true)
@test isequal(propertynames(ts.coredata), vcat([:Index], [:x1], Symbol.(["x1_" * string(i) for i in 1:NUM_COLUMNS - 1])))

# rename!(ts::TSFrame, d::AbstractVector{<:Pair})
pairs_sym_sym = [Symbol("x" * string(i)) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS]
pairs_sym_string = [Symbol("x" * string(i)) => "X" * string(i) for i in 1:NUM_COLUMNS]
pairs_string_sym = ["x" * string(i) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS]
pairs_string_string = ["x" * string(i) => "X" * string(i) for i in 1:NUM_COLUMNS]
rand_index = random(1:NUM_COLUMNS)

## Symbol => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_sym_sym)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## Symbol => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_sym_string)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_string_sym)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_string_string)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## cannot map Index to any other name or map any other column to Index
@test_throws ArgumentError TSFrames.rename!(ts, vcat([:Index => :nonIndex], pairs_sym_sym))
@test_throws ArgumentError TSFrames.rename!(ts, vcat([:Index => "nonIndex"], pairs_sym_string))
@test_throws ArgumentError TSFrames.rename!(ts, vcat(["Index" => :nonIndex], pairs_string_sym))
@test_throws ArgumentError TSFrames.rename!(ts, vcat(["nonIndex" => "nonIndex"], pairs_string_string))

pairs_sym_sym[rand_index] = Symbol("x" * string(rand_index)) => :Index
pairs_sym_string[rand_index] = Symbol("x" * string(rand_index)) => "Index"
pairs_string_sym[rand_index] = "x" * string(rand_index) => :Index
pairs_string_string[rand_index] = "x" * string(rand_index) => "Index"
@test_throws ArgumentError TSFrames.rename!(ts, pairs_sym_sym)
@test_throws ArgumentError TSFrames.rename!(ts, pairs_sym_string)
@test_throws ArgumentError TSFrames.rename!(ts, pairs_string_sym)
@test_throws ArgumentError TSFrames.rename!(ts, pairs_string_string)

# rename!(ts::TSFrame, d::AbstractDict)
dict_sym_sym = Dict([Symbol("x" * string(i)) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS])
dict_sym_string = Dict([Symbol("x" * string(i)) => "X" * string(i) for i in 1:NUM_COLUMNS])
dict_string_sym = Dict(["x" * string(i) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS])
dict_string_string = Dict(["x" * string(i) => "X" * string(i) for i in 1:NUM_COLUMNS])

## Symbol => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, dict_sym_sym)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## Symbol => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, dict_sym_string)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, dict_string_sym)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, dict_string_string)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

# rename!(ts::TSFrame, (from => to)::Pair...)
pairs_sym_sym = [Symbol("x" * string(i)) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS]
pairs_sym_string = [Symbol("x" * string(i)) => "X" * string(i) for i in 1:NUM_COLUMNS]
pairs_string_sym = ["x" * string(i) => Symbol("X" * string(i)) for i in 1:NUM_COLUMNS]
pairs_string_string = ["x" * string(i) => "X" * string(i) for i in 1:NUM_COLUMNS]

## Symbol => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_sym_sym...)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## Symbol => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_sym_string...)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => Symbol
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_string_sym...)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))

## String => String
ts = TSFrame(Date; n=NUM_COLUMNS)
TSFrames.rename!(ts, pairs_string_string...)
@test isequal(propertynames(ts.coredata), vcat([:Index], Symbol.("X" * string(i) for i in 1:NUM_COLUMNS)))
