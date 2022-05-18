"""
# Subsetting based on Index

```julia
subset(ts::TS, from::T, to::T) where {T<:Union{Int, TimeType}}
```

Create a subset of `ts` based on the `Index` starting `from`
(inclusive) till `to` (inclusive).

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = Date("2022-02-01"):Week(1):Date("2022-02-01")+Month(9);
julia> ts = TS(random(length(dates)), dates)
julia> show(ts)
(40 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2022-02-01  0.768448
 2022-02-08  0.940515
 2022-02-15  0.673959
 2022-02-22  0.395453
 2022-03-01  0.313244
 2022-03-08  0.662555
 2022-03-15  0.586022
 2022-03-22  0.0521332
 2022-03-29  0.26864
 2022-04-05  0.108871
 2022-04-12  0.163666
 2022-04-19  0.473017
 2022-04-26  0.865412
 2022-05-03  0.617492
 2022-05-10  0.285698
 2022-05-17  0.463847
 2022-05-24  0.275819
 2022-05-31  0.446568
 2022-06-07  0.582318
 2022-06-14  0.255981
 2022-06-21  0.70586
 2022-06-28  0.291978
 2022-07-05  0.281066
 2022-07-12  0.792931
 2022-07-19  0.20923
 2022-07-26  0.918165
 2022-08-02  0.614255
 2022-08-09  0.802665
 2022-08-16  0.555668
 2022-08-23  0.940782
 2022-08-30  0.48
 2022-09-06  0.790201
 2022-09-13  0.356221
 2022-09-20  0.900925
 2022-09-27  0.529253
 2022-10-04  0.031831
 2022-10-11  0.900681
 2022-10-18  0.940299
 2022-10-25  0.621379
 2022-11-01  0.348173

julia> subset(ts, Date(2022, 03), Date(2022, 07))
(18 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2022-03-01  0.313244
 2022-03-08  0.662555
 2022-03-15  0.586022
 2022-03-22  0.0521332
 2022-03-29  0.26864
 2022-04-05  0.108871
 2022-04-12  0.163666
 2022-04-19  0.473017
 2022-04-26  0.865412
 2022-05-03  0.617492
 2022-05-10  0.285698
 2022-05-17  0.463847
 2022-05-24  0.275819
 2022-05-31  0.446568
 2022-06-07  0.582318
 2022-06-14  0.255981
 2022-06-21  0.70586
 2022-06-28  0.291978

julia> subset(TS(1:20, -9:10), -4, 5)
(10 x 1) TS with Int64 Index

 Index  x1
 Int64  Int64
──────────────
    -4      6
    -3      7
    -2      8
    -1      9
     0     10
     1     11
     2     12
     3     13
     4     14
     5     15

julia> subset(ts,:,Date("2022-04-12"))
(11 x 1) TS with Date Index

 Index       x1        
 Date        Float64   
───────────────────────
 2022-02-01  0.768448
 2022-02-08  0.940515
 2022-02-15  0.673959
 2022-02-22  0.395453
 2022-03-01  0.313244
 2022-03-08  0.662555
 2022-03-15  0.586022
 2022-03-22  0.0521332
 2022-03-29  0.26864
 2022-04-05  0.108871
 2022-04-12  0.163666

julia> subset(ts,Date("2022-9-27"),:)
(6 x 1) TS with Date Index

 Index       x1       
 Date        Float64  
──────────────────────
 2022-09-27  0.529253
 2022-10-04  0.031831
 2022-10-11  0.900681
 2022-10-18  0.940299
 2022-10-25  0.621379
 2022-11-01  0.348173


```

"""
function subset(ts::TS, from::T, to::T) where {T<:Union{Int, TimeType}}
    TS(DataFrames.subset(ts.coredata, :Index => x -> x .>= from .&& x .<= to))
end

function subset(ts::TS, ::Colon, to::T) where {T<:Union{Int, TimeType}}
    TS(DataFrames.subset(ts.coredata, :Index => x -> x .<= to))
end

function subset(ts::TS, from::T, ::Colon,) where {T<:Union{Int, TimeType}}
    TS(DataFrames.subset(ts.coredata, :Index => x -> x .>= from))
end
