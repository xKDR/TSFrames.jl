Tables.istable(::Type{TS}) = true

Tables.rowaccess(::Type{TS}) = true
Tables.rows(ts::TS) = DataFrames.eachrow(ts.coredata)

Tables.columnaccess(::Type{TS}) = true
Tables.columns(ts::TS) = DataFrames.eachcol(ts.coredata)

Tables.rowtable(ts::TS) = Tables.rowtable(ts.coredata)
Tables.columntable(ts::TS) = Tables.columntable(ts.coredata)

Tables.namedtupleiterator(ts::TS) = Tables.namedtupleiterator(ts.coredata)

Tables.schema(ts::TS) = Tables.schema(ts.coredata)

Tables.materializer(::Type{<:TS}) = TS
