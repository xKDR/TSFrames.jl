"""
Methods for using Indicators.jl functions on TSFrame objects from TSFrames.jl package.
See respective documentation on Indicators.jl for full description of the methods
"""
module IndicatorsExt

using TSFrames, Indicators

"""
Abstracted function for Indicators.jl methods that take a single input, such as SMA, EMA, etc.
"""
function apply_func(X::TSFrame, f::Function, input_flds::Symbol, rename_flds::Vector{Symbol}; kwargs...)
    return TSFrames.rename!(TSFrame(f(X[:, input_flds]; kwargs...), index(X)), rename_flds)
end

"""
Abstracted function for Indicators.jl methods that take multiple input columns as Matrix, such as VWMA, VWAP, etc.
"""
function apply_func(X::TSFrame, f::Function, input_flds::Vector{Symbol}, rename_flds::Vector{Symbol}; kwargs...)
    return TSFrames.rename!(TSFrame(f(Matrix(X[:, input_flds]); kwargs...), index(X)), rename_flds)
end

##########################################################################################
### Dispatches to allow user to specify Symbol or Vector{Symbol} for input arguments

# Indicators.jl/src/ma.jl
Indicators.runmean(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.runmean, x, [:RUNMEAN]; kwargs...)
Indicators.sma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.sma, x, [:SMA]; kwargs...)
Indicators.trima(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.trima, x, [:TRIMA]; kwargs...)
Indicators.wma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.wma, x, [:WMA]; kwargs...)
Indicators.ema(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.ema, x, [:EMA]; kwargs...)
Indicators.mma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mma, x, [:MMA]; kwargs...)
Indicators.dema(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.dema, x, [:DEMA]; kwargs...)
Indicators.tema(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.tema, x, [:TEMA]; kwargs...)
Indicators.mama(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mama, x, [:MAMA, :FAMA]; kwargs...)
Indicators.hma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.hma, x, [:HMA]; kwargs...)
Indicators.swma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.swma, x, [:SWMA]; kwargs...)
Indicators.kama(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.kama, x, [:KAMA]; kwargs...)
Indicators.alma(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.alma, x, [:ALMA]; kwargs...)
Indicators.zlema(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.zlema, x, [:ZLEMA]; kwargs...)
Indicators.hama(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.hama, x, [:HammingMA]; kwargs...)
Indicators.vwma(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.vwma, x, [:VWMA]; kwargs...)
Indicators.vwap(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.vwap, x, [:VWAP]; kwargs...)

# Indicators.jl/src/reg.jl
Indicators.mlr_beta(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_beta, x, [:Intercept, :Slope]; kwargs...)
Indicators.mlr_slope(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_slope, x, [:Slope]; kwargs...)
Indicators.mlr_intercept(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_intercept, x, [:Intercept]; kwargs...)
Indicators.mlr(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr, x, [:MLR]; kwargs...)
Indicators.mlr_se(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_se, x, [:StdErr]; kwargs...)
Indicators.mlr_ub(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_ub, x, [:MLRUB]; kwargs...)
Indicators.mlr_lb(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_lb, x, [:MLRLB]; kwargs...)'
Indicators.mlr_bands(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_bands, x, [:MLRLB, :MLR, :MLRUB]; kwargs...)
Indicators.mlr_rsq(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.mlr_rsq, x, [:RSquared]; kwargs...)

# Indicators.jl/src/mom.jl
Indicators.aroon(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.aroon, x, [:AroonUp, :AroonDn, :AroonOsc]; kwargs...)
Indicators.donch(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.donch, x, [:Low, :Mid, :High]; kwargs...)
Indicators.ichimoku(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.ichimoku, x, [:Tenkan, :Kijun, :SenkouA, :SenkouB, :Chikou]; kwargs...)
Indicators.momentum(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.momentum, x, [:Momentum]; kwargs...)
Indicators.roc(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.roc, x, [:ROC]; kwargs...)
Indicators.macd(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.macd, x, [:MACD, :Signal, :Histogram]; kwargs...)
Indicators.rsi(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.rsi, x, [:RSI]; kwargs...)
Indicators.adx(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.adx, x, [:DiPlus, :DiMinus, :ADX]; kwargs...)
Indicators.heikinashi(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.heikinashi, x, [:Open, :High, :Low, :Close]; kwargs...)
Indicators.psar(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.psar, x, [:PSAR]; kwargs...)
Indicators.kst(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.kst, x, [:KST]; kwargs...)
Indicators.wpr(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.wpr, x, [:WPR]; kwargs...)
Indicators.cci(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.cci, x, [:CCI]; kwargs...)
Indicators.stoch(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.stoch, x, [:Stochastic, :Signal]; kwargs...)
Indicators.smi(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.smi, x, [:SMI, :Signal]; kwargs...)

# Indicators.jl/src/vol.jl
Indicators.bbands(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.bbands, x, [:LB, :MA, :UB]; kwargs...)
Indicators.tr(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.tr, x, [:TR]; kwargs...)
Indicators.atr(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.atr, x, [:ATR]; kwargs...)
Indicators.keltner(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.keltner, x, [:KeltnerLower, :KeltnerMiddle, :KeltnerUpper]; kwargs...)

#Indicators.jl/src/trendy.jl
Indicators.maxima(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.maxima, x, [:Maxima]; kwargs...)
Indicators.minima(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.minima, x, [:Minima]; kwargs...)
Indicators.support(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.support, x, [:Support]; kwargs...)
Indicators.resistance(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.resistance, x, [:Resistance]; kwargs...)

# Indicators.jl/src/utils.jl
## Assumes both x and y are in same TSFrame object
Indicators.crossover(X::TSFrame, x::Symbol, y::Symbol) = apply_func(X, Indicators.crossover, [x, y], [:CrossOver])
Indicators.crossunder(X::TSFrame, x::Symbol, y::Symbol) = apply_func(X, Indicators.crossunder, [x, y], [:CrossUnder])

# Indicators.jl/src/chaos.jl
Indicators.hurst(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.hurst, x, [:Hurst]; kwargs...)
Indicators.rsrange(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.rsrange, x, [:RS]; kwargs...)

##########################################################################################
### Multiple dispatches for "default" column labels, e.g. :Close, :High, :Low, :Open, :Volume
close = :Close
high = :High
low = :Low
open = :Open
volume = :Volume

has_close(X::TSFrame)::Bool = :Close in propertynames(X.coredata)
close_error = error("Argument must have Close field")
has_close_volume(X::TSFrame)::Bool = all(fld -> fld in propertynames(X.coredata), [:Close, :Volume])
close_vol_error = error("Argument must have Close and Volume field")

# Indicators.jl/src/ma.jl
Indicators.runmean(X::TSFrame; kwargs...) = has_close(X) ? Indicators.runmean(X, close; kwargs...) : close_error
Indicators.sma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.sma(X, close; kwargs...) : close_error
Indicators.trima(X::TSFrame; kwargs...) = has_close(X) ? Indicators.trima(X, close; kwargs...) : close_error
Indicators.wma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.wma(X, close; kwargs...) : close_error
Indicators.ema(X::TSFrame; kwargs...) = has_close(X) ? Indicators.ema(X, close; kwargs...) : close_error
Indicators.mma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mma(X, close; kwargs...) : close_error
Indicators.dema(X::TSFrame; kwargs...) = has_close(X) ? Indicators.dema(X, close; kwargs...) : close_error
Indicators.tema(X::TSFrame; kwargs...) = has_close(X) ? Indicators.tema(X, close; kwargs...) : close_error
Indicators.mama(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mama(X, close; kwargs...) : close_error
Indicators.hma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.hma(X, close; kwargs...) : close_error
Indicators.swma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.swma(X, close; kwargs...) : close_error
Indicators.kama(X::TSFrame; kwargs...) = has_close(X) ? Indicators.kama(X, close; kwargs...) : close_error
Indicators.alma(X::TSFrame; kwargs...) = has_close(X) ? Indicators.alma(X, close; kwargs...) : close_error
Indicators.zlema(X::TSFrame; kwargs...) = has_close(X) ? Indicators.zlema(X, close; kwargs...) : close_error
Indicators.hama(X::TSFrame; kwargs...) = has_close(X) ? Indicators.hama(X, close; kwargs...) : close_error
Indicators.vwma(X::TSFrame; kwargs...) = has_close_volume(X) ? Indicators.vwma(X, [close, volume]; kwargs...) : close_vol_error
Indicators.vwap(X::TSFrame; kwargs...) = has_close_volume(X) ? Indicators.vwap(X, [close, volume]; kwargs...) : close_vol_error

# Indicators.jl/src/reg.jl
Indicators.mlr_beta(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_beta(X, close; kwargs...) : close_error
Indicators.mlr_slope(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_slope(X, close; kwargs...) : close_error
Indicators.mlr_intercept(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_intercept(X, close; kwargs...) : close_error
Indicators.mlr(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr(X, close; kwargs...) : close_error
Indicators.mlr_se(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_se(X, close; kwargs...) : close_error
Indicators.mlr_ub(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_ub(X, close; kwargs...) : close_error
Indicators.mlr_lb(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_lb(X, close; kwargs...) : close_error
Indicators.mlr_bands(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_bands(X, close; kwargs...) : close_error
Indicators.mlr_rsq(X::TSFrame; kwargs...) = has_close(X) ? Indicators.mlr_rsq(X, close; kwargs...) : close_error

# Indicators.jl/src/mom.jl
Indicators.aroon(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.aroon, x, [:AroonUp, :AroonDn, :AroonOsc]; kwargs...)
Indicators.donch(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.donch, x, [:Low, :Mid, :High]; kwargs...)
Indicators.ichimoku(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.ichimoku, x, [:Tenkan, :Kijun, :SenkouA, :SenkouB, :Chikou]; kwargs...)
Indicators.momentum(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.momentum, x, [:Momentum]; kwargs...)
Indicators.roc(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.roc, x, [:ROC]; kwargs...)
Indicators.macd(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.macd, x, [:MACD, :Signal, :Histogram]; kwargs...)
Indicators.rsi(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.rsi, x, [:RSI]; kwargs...)
Indicators.adx(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.adx, x, [:DiPlus, :DiMinus, :ADX]; kwargs...)
Indicators.heikinashi(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.heikinashi, x, [:Open, :High, :Low, :Close]; kwargs...)
Indicators.psar(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.psar, x, [:PSAR]; kwargs...)
Indicators.kst(X::TSFrame, x::Symbol; kwargs...) = apply_func(X, Indicators.kst, x, [:KST]; kwargs...)
Indicators.wpr(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.wpr, x, [:WPR]; kwargs...)
Indicators.cci(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.cci, x, [:CCI]; kwargs...)
Indicators.stoch(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.stoch, x, [:Stochastic, :Signal]; kwargs...)
Indicators.smi(X::TSFrame, x::Vector{Symbol}; kwargs...) = apply_func(X, Indicators.smi, x, [:SMI, :Signal]; kwargs...)



end

