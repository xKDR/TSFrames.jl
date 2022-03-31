import TSx
using DataFrames, Statistics

export describe, abs, cor

function describe(ts:: TS)
    describe(ts.coredata)
end

function abs(ts:: TS)
    abs.(dropmissing(ts.coredata))
end

function cor(ts:: TS)
    Statistics.cor(Matrix(dropmissing(ts.coredata)))
    
end

    

