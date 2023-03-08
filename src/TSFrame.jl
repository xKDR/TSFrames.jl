"""
    struct TSFrame <: AbstractDataFrame
      coredata :: DataFrame
    end

`::TSFrame` - A type to hold ordered data with an index.

A TSFrame object is essentially a `DataFrame` with a specific column marked
as an index. The input `DataFrame` is sorted during construction and
is stored under the property `coredata`. The index is stored in the
`Index` column of `coredata`.

Permitted data inputs to the constructors are `DataFrame`, `Vector`,
and 2-dimensional `Array`. If an index is already not present in the
constructor then a sequential integer index is created
automatically.

`TSFrame(coredata::DataFrame)`: Here, the constructor looks for a column
named `Index` in `coredata` as the index column, if this is not found
then the first column of `coredata` is made the index by default. If
`coredata` only has a single column then a new sequential index is
generated.

Since `TSFrame.coredata` is a DataFrame it can be operated upon
independently using methods provided by the DataFrames package
(ex. `transform`, `combine`, etc.).

# Constructors
```julia
TSFrame(coredata::DataFrame, index::Union{String, Symbol, Int}; issorted = false)
TSFrame(coredata::DataFrame, index::AbstractVector{T}; issorted = false) where {T<:Union{Int, TimeType}}
TSFrame(coredata::DataFrame; issorted = false)
TSFrame(coredata::DataFrame, index::UnitRange{Int}; issorted = false)
TSFrame(coredata::AbstractVector{T}, index::AbstractVector{V}; colnames=:auto, issorted = false) where {T, V}
TSFrame(coredata::AbstractVector{T}; colnames=:auto, issorted = false) where {T}
TSFrame(coredata::AbstractArray{T,2}; colnames=:auto, issorted = false) where {T}
TSFrame(coredata::AbstractArray{T,2}, index::AbstractVector{V}; colnames=:auto, issorted = false) where {T, V}
TSFrame(IndexType::DataType; n::Int=1)
TSFrame(IndexType::DataType, cols::Vector{Tuple{DataType, S}}; issorted = false) where S <: Union{Symbol, String}
```

When `issorted` is true, no sort operations are performed on the input.  
This offers some performance benefits, especially when constructing in a loop,
or at scale.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x);

julia> df = DataFrame(x1 = random(10))
10×1 DataFrame
 Row │ x1
     │ Float64
─────┼───────────
   1 │ 0.768448
   2 │ 0.940515
   3 │ 0.673959
   4 │ 0.395453
   5 │ 0.313244
   6 │ 0.662555
   7 │ 0.586022
   8 │ 0.0521332
   9 │ 0.26864
  10 │ 0.108871

julia> ts = TSFrame(df)   # generates index
(10 x 1) TSFrame with Int64 Index

 Index  x1
 Int64  Float64
──────────────────
     1  0.768448
     2  0.940515
     3  0.673959
     4  0.395453
     5  0.313244
     6  0.662555
     7  0.586022
     8  0.0521332
     9  0.26864
    10  0.108871

# ts.coredata is a DataFrame
julia> combine(ts.coredata, :x1 => Statistics.mean, DataFrames.nrow)
1×2 DataFrame
 Row │ x1_mean  nrow
     │ Float64  Int64
─────┼────────────────
   1 │ 0.49898    418

julia> df = DataFrame(ind = [1, 2, 3], x1 = random(3))
3×2 DataFrame
 Row │ ind    x1
     │ Int64  Float64
─────┼─────────────────
   1 │     1  0.768448
   2 │     2  0.940515
   3 │     3  0.673959

julia> ts = TSFrame(df, 1)        # the first column is index
(3 x 1) TSFrame with Int64 Index

 Index  x1
 Int64  Float64
─────────────────
     1  0.768448
     2  0.940515
     3  0.673959

julia> df = DataFrame(x1 = random(3), x2 = random(3), Index = [1, 2, 3]);
3×3 DataFrame
 Row │ x1        x2        Index
     │ Float64   Float64   Int64
─────┼───────────────────────────
   1 │ 0.768448  0.768448      1
   2 │ 0.940515  0.940515      2
   3 │ 0.673959  0.673959      3

julia> ts = TSFrame(df)   # uses existing `Index` column
(3 x 2) TSFrame with Int64 Index

 Index  x1        x2
 Int64  Float64   Float64
───────────────────────────
     1  0.768448  0.768448
     2  0.940515  0.940515
     3  0.673959  0.673959

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> df = DataFrame(dates = dates, x1 = random(10))
10×2 DataFrame
 Row │ dates       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2017-01-01  0.768448
   2 │ 2017-01-02  0.940515
   3 │ 2017-01-03  0.673959
   4 │ 2017-01-04  0.395453
   5 │ 2017-01-05  0.313244
   6 │ 2017-01-06  0.662555
   7 │ 2017-01-07  0.586022
   8 │ 2017-01-08  0.0521332
   9 │ 2017-01-09  0.26864
  10 │ 2017-01-10  0.108871

julia> ts = TSFrame(df, :dates)
(10 x 1) TSFrame with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871

julia> ts = TSFrame(DataFrame(x1=random(10)), dates);

julia> ts = TSFrame(random(10))
(10 x 1) TSFrame with Int64 Index

 Index  x1
 Int64  Float64
──────────────────
     1  0.768448
     2  0.940515
     3  0.673959
     4  0.395453
     5  0.313244
     6  0.662555
     7  0.586022
     8  0.0521332
     9  0.26864
    10  0.108871

julia> ts = TSFrame(random(10), colnames=[:A]) # column is named A
(10 x 1) TSFrame with Int64 Index

 Index  A
 Int64  Float64
──────────────────
     1  0.768448
     2  0.940515
     3  0.673959
     4  0.395453
     5  0.313244
     6  0.662555
     7  0.586022
     8  0.0521332
     9  0.26864
    10  0.108871

julia> ts = TSFrame(random(10), dates)
(10 x 1) TSFrame with Date Index

 Index       x1        
 Date        Float64   
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871

julia> ts = TSFrame(random(10), dates, colnames=[:A]) # column is named A
(10 x 1) TSFrame with Date Index

 Index       A         
 Date        Float64   
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871

julia> ts = TSFrame([random(10) random(10)]) # matrix object
(10 x 2) TSFrame with Int64 Index

 Index  x1         x2        
 Int64  Float64    Float64   
─────────────────────────────
     1  0.768448   0.768448
     2  0.940515   0.940515
     3  0.673959   0.673959
     4  0.395453   0.395453
     5  0.313244   0.313244
     6  0.662555   0.662555
     7  0.586022   0.586022
     8  0.0521332  0.0521332
     9  0.26864    0.26864
    10  0.108871   0.108871

julia> ts = TSFrame([random(10) random(10)], colnames=[:A, :B]) # columns are named A and B
(10 x 2) TSFrame with Int64 Index

 Index  A          B       
 Int64  Float64    Float64   
─────────────────────────────
     1  0.768448   0.768448
     2  0.940515   0.940515
     3  0.673959   0.673959
     4  0.395453   0.395453
     5  0.313244   0.313244
     6  0.662555   0.662555
     7  0.586022   0.586022
     8  0.0521332  0.0521332
     9  0.26864    0.26864
    10  0.108871   0.108871

julia> ts = TSFrame([random(10) random(10)], dates) 
(10 x 2) TSFrame with Date Index

 Index       x1         x2
 Date        Float64    Float64
──────────────────────────────────
 2017-01-01  0.768448   0.768448
 2017-01-02  0.940515   0.940515
 2017-01-03  0.673959   0.673959
 2017-01-04  0.395453   0.395453
 2017-01-05  0.313244   0.313244
 2017-01-06  0.662555   0.662555
 2017-01-07  0.586022   0.586022
 2017-01-08  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864
 2017-01-10  0.108871   0.108871

julia> ts = TSFrame([random(10) random(10)], dates, colnames=[:A, :B]) # columns are named A and B
(10 x 2) TSFrame with Date Index

 Index       A          B         
 Date        Float64    Float64   
──────────────────────────────────
 2017-01-01  0.768448   0.768448
 2017-01-02  0.940515   0.940515
 2017-01-03  0.673959   0.673959
 2017-01-04  0.395453   0.395453
 2017-01-05  0.313244   0.313244
 2017-01-06  0.662555   0.662555
 2017-01-07  0.586022   0.586022
 2017-01-08  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864
 2017-01-10  0.108871   0.108871

julia> ts = TSFrame(Int64; n=5) # empty TSFrame with 5 columns of type Any and with Int64 index type
0×5 TSFrame with Int64 Index

julia> ts = TSFrame(Date, [(Int64, :col1), (String, :col2), (Float64, :col3)]) # empty TSFrame with specific column names and types
0×3 TSFrame with Date Index

julia> ts = TSFrame(Date, [(Int64, "col1"), (String, "col2"), (Float64, "col3")]) # using strings instead of symbols
0×3 TSFrame with Date Index

```
"""
struct TSFrame <: AbstractDataFrame

    coredata :: DataFrame

    # From DataFrame, index number/name/symbol
    function TSFrame(coredata::DataFrame, index::Union{String, Symbol, Int}; issorted = false)
        if ! (eltype(coredata[!, index]) <: Union{Int, TimeType})
            throw(ArgumentError("only Int and TimeType index is supported"))
        end

        if (DataFrames.ncol(coredata) == 1)
            TSFrame(coredata, collect(Base.OneTo(DataFrames.nrow(coredata))); issorted = issorted)
        end

        sorted_cd = issorted ? deepcopy(coredata) : sort(coredata, index)
        index_vals = sorted_cd[!, index]

        cd = sorted_cd[:, Not(index)]
        insertcols!(cd, 1, :Index => index_vals, after=false, copycols=true)

        new(cd)
    end

    # From DataFrame, external index
    function TSFrame(coredata::DataFrame, index::AbstractVector{T}; issorted = false) where {T<:Union{Int, TimeType}}
        sorted_index = issorted ? deepcopy(index) : sort(index)

        cd = copy(coredata)
        insertcols!(cd, 1, :Index => sorted_index, after=false, copycols=true)

        new(cd)
    end

end



####################################
# Constructors
####################################

# For general Tables.jl compatible types
function TSFrame(table; issorted = false)
    coredata = DataFrame(table, copycols=true)

    if "Index" in names(coredata)
        return TSFrame(coredata, :Index; issorted = issorted)
    elseif DataFrames.ncol(coredata) == 1
        return TSFrame(coredata, collect(1:DataFrames.nrow(coredata)); issorted = issorted)
    else
        return TSFrame(coredata, 1; issorted = issorted)
    end
end

# From DataFrame, index range
function TSFrame(coredata::DataFrame, index::UnitRange{Int}; issorted = false)
    index_vals = collect(index)
    cd = copy(coredata)
    insertcols!(cd, 1, :Index => index_vals, after=false, copycols=true)
    TSFrame(cd, :Index; issorted = issorted)
end

# From AbstractVector
function TSFrame(coredata::AbstractVector{T}, index::AbstractVector{V}; colnames=:auto, issorted = false) where {T, V}
    df = DataFrame([coredata], colnames)
    TSFrame(df, index; issorted = issorted)
end

function TSFrame(coredata::AbstractVector{T}; colnames=:auto, issorted = false) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    TSFrame(coredata, index_vals, colnames=colnames, issorted = issorted)
end

# From Matrix and meta
# FIXME: use Metadata.jl
function TSFrame(coredata::AbstractArray{T,2}; colnames=:auto, issorted = false) where {T}
    index_vals = collect(Base.OneTo(size(coredata)[1]))
    df = DataFrame(coredata, colnames, copycols=true)
    TSFrame(df, index_vals; issorted = issorted)
end

function TSFrame(coredata::AbstractArray{T,2}, index::AbstractVector{V}; colnames=:auto, issorted = false) where {T, V}
    df = DataFrame(coredata, colnames, copycols=true)
    TSFrame(df, index; issorted = issorted)
end

function TSFrame(IndexType::DataType; n::Int=1, issorted = false)
    (n>=1) || throw(DomainError(n, "n should be >= 1"))
    df = DataFrame(fill([],n), :auto)
    df.Index = IndexType[]
    TSFrame(df; issorted = issorted)
end

# For empty TSFrames
function TSFrame(IndexType::DataType, cols::Vector{Tuple{DataType, S}}; issorted = false) where S <: Union{Symbol, String}
    df = DataFrame([colname => type[] for (type, colname) in cols])
    insertcols!(df, :Index => IndexType[])
    TSFrame(df; issorted = issorted)
end
