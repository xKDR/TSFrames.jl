Tables.istable(::Type{TS}) = true

Tables.rowaccess(::Type{TS}) = true
Tables.rows(ts::TS) = DataFrames.eachrow(ts.coredata)

Tables.columnaccess(::Type{TS}) = true
Tables.columns(ts::TS) = DataFrames.eachcol(ts.coredata)

