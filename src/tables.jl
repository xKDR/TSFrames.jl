Tables.istable(::Type{TSFrame}) = true

Tables.rowaccess(::Type{TSFrame}) = true
Tables.rows(ts::TSFrame) = DataFrames.eachrow(ts.coredata)
Tables.rowcount(ts::TSFrame) = TSFrames.nrow(ts)

Tables.columnaccess(::Type{TSFrame}) = true
Tables.columns(ts::TSFrame) = DataFrames.eachcol(ts.coredata)

Tables.rowtable(ts::TSFrame) = Tables.rowtable(ts.coredata)
Tables.columntable(ts::TSFrame) = Tables.columntable(ts.coredata)

Tables.namedtupleiterator(ts::TSFrame) = Tables.namedtupleiterator(ts.coredata)

Tables.schema(ts::TSFrame) = Tables.schema(ts.coredata)

Tables.materializer(::Type{<:TSFrame}) = TSFrame
