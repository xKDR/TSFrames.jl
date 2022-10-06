Tables.istable(::Type{TS}) = true

Tables.rowaccess(::Type{TS}) = true
Tables.rows(ts::TS) = DataFrames.eachrow(ts.coredata)

Tables.columnaccess(::Type{TS}) = true
Tables.columns(ts::TS) = DataFrames.eachcol(ts.coredata)

Tables.rowtable(ts::TS) = Tables.rowtable(ts.coredata)
Tables.columntable(ts::TS) = Tables.columntable(ts.coredata)

Tables.namedtupleiterator(ts::TS) = Tables.namedtupleiterator(ts.coredata)

Tables.columnindex(ts::TS, idx::Symbol) = Tables.columnindex(ts.coredata, idx)
Tables.columnindex(ts::TS, idx::String) = Tables.columnindex(ts.coredata, Symbol(idx))

Tables.schema(ts::TS) = Tables.schema(ts.coredata)

Tables.materializer(::Type{<:TS}) = TS

Tables.getcolumn(ts::TS, i::Int) = Tables.getcolumn(ts.coredata, i)
Tables.getcolumn(ts::TS, nm::Symbol) = Tables.getcolumn(ts.coredata, nm)
