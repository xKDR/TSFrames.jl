###
# Test _check_consistency()
###
ts = TS(data_vector, 1:length(data_vector));
@test TSx._check_consistency(ts) == true

ts.coredata.Index = sample(index_integer, length(data_vector), replace=true);
@test TSx._check_consistency(ts) == false
####
