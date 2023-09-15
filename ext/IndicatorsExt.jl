module IndicatorsExt

using TSFrames, Indicators

# Methods for using Indicators.jl functions on TSFrame objects from TSFrames.jl package
# See respective documentation on Indicators.jl for full description of the methods

function uni_func(X::TSFrame, f::Function, input_flds::Symbol, rename_flds::Vector{Symbol}; kwargs...)
    return TSFrames.rename!(TSFrame(f(X[:, input_flds]; kwargs...), index(X)), rename_flds)
end

function multi_func(X::TSFrame, f::Function, input_flds::Vector{Symbol}, rename_flds::Vector{Symbol}; kwargs...)
    return TSFrames.rename!(TSFrame(f(Matrix(X[:, input_flds]); kwargs...), index(X)), rename_flds)
end

# Indicators.jl/src/ma.jl
Indicators.runmean(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.runmean, x, [:runmean], kwargs...)
Indicators.sma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.sma, x, [:sma], kwargs...)
Indicators.trima(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.trima, x, [:trima], kwargs...)
Indicators.wma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.wma, x, [:wma], kwargs...)
Indicators.ema(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.ema, x, [:ema], kwargs...)
Indicators.mma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.mma, x, [:mma], kwargs...)
Indicators.dema(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.dema, x, [:dema], kwargs...)
Indicators.tema(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.tema, x, [:tema], kwargs...)
Indicators.mama(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.mama, x, [:mama, :fama], kwargs...)
Indicators.hma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.hma, x, [:hma], kwargs...)
Indicators.swma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.swma, x, [:swma], kwargs...)
Indicators.kama(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.kama, x, [:kama], kwargs...)
Indicators.alma(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.alma, x, [:alma], kwargs...)
Indicators.zlema(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.zlema, x, [:zlema], kwargs...)
Indicators.hama(X::TSFrame, x::Symbol; kwargs...) = uni_func(X, Indicators.hama, x, [:hama], kwargs...)
# ## VWMA, VWAP are defined on Matrix, not Array
Indicators.vwma(X::TSFrame, x::Vector{Symbol}; kwargs...) = multi_func(X, Indicators.vwma, x, [:vwma], kwargs...)
Indicators.vwap(X::TSFrame, x::Vector{Symbol}; kwargs...) = multi_func(X, Indicators.vwap, x, [:vwma], kwargs...)

# Indicators.jl/src/ma.jl

## aroon Matrix
## donch Matrix
## Ichimoku
Indicators.momentum(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.momentum(X[:, x]; kwargs...), index(X))
Indicators.roc(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.roc(X[:, x]; kwargs...), index(X))
Indicators.macd(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.macd(X[:, x]; kwargs...), index(X))
Indicators.rsi(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.rsi(X[:, x]; kwargs...), index(X))
Indicators.adx(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.adx(X[:, x]; kwargs...), index(X))
## Heikin Ashi
Indicators.kst(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.kst(X[:, x]; kwargs...), index(X))
## wpr
## cci
## stoch
## smi
smi

# Indicators.jl/src/ma.jl
Indicators.bbands(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.bbands(X[:, x]; kwargs...), index(X))
## tr
## atr
## keltner


end