Tables.istable(::Type{TimeFrame}) = true

Tables.rowaccess(::Type{TimeFrame}) = true
Tables.rows(ts::TimeFrame) = DataFrames.eachrow(ts.coredata)

Tables.columnaccess(::Type{TimeFrame}) = true
Tables.columns(ts::TimeFrame) = DataFrames.eachcol(ts.coredata)

Tables.rowtable(ts::TimeFrame) = Tables.rowtable(ts.coredata)
Tables.columntable(ts::TimeFrame) = Tables.columntable(ts.coredata)

Tables.namedtupleiterator(ts::TimeFrame) = Tables.namedtupleiterator(ts.coredata)

Tables.schema(ts::TimeFrame) = Tables.schema(ts.coredata)

Tables.materializer(::Type{<:TimeFrame}) = TimeFrame
