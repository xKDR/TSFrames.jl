using TimeFrames

ts = TimeFrame(DataFrame(a=["a", "b", "c"], b=[1,2, missing]), [1, 2, 3]) ;

###
# describe()
dd = TimeFrames.describe(ts) ;
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

dd = TimeFrames.describe(ts, :mean) ;
@test "mean" in names(dd) ;
@test !("median" in names(dd)) ;
@test dd[3, :mean] == 1.5 ;

dd = TimeFrames.describe(ts, :mean, cols=:b) ;
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
@test TimeFrames._check_consistency(ts) == true
@test TimeFrames._check_consistency(TimeFrame([:a, :b], [2,1])) == true;

ts = TimeFrame(data_vector, 1:length(data_vector));
ts.coredata.Index = sample(index_integer, length(data_vector), replace=true);
@test TimeFrames._check_consistency(ts) == false;
###
