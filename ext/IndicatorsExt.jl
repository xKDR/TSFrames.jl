module IndicatorsExt

using TSFrames, Indicators

# Methods for porting Indicators.jl functions to TSFrame objects from TSFrames.jl package
# See their respective documentation on Indicators.jl
Indicators.runmean(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.runmean(X[:, x]; kwargs...), X[:, :Index])
Indicators.sma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.sma(X[:, x]; kwargs...), X[:, :Index])
Indicators.trima(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.trima(X[:, x]; kwargs...), X[:, :Index])
Indicators.wma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.wma(X[:, x]; kwargs...), X[:, :Index])
Indicators.ema(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.ema(X[:, x]; kwargs...), X[:, :Index])
Indicators.mma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.mma(X[:, x]; kwargs...), X[:, :Index])
Indicators.dema(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.dema(X[:, x]; kwargs...), X[:, :Index])
Indicators.tema(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.tema(X[:, x]; kwargs...), X[:, :Index])
Indicators.mama(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.dema(X[:, x]; kwargs...), X[:, :Index])
Indicators.hma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.hma(X[:, x]; kwargs...), X[:, :Index])
Indicators.swma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.swma(X[:, x]; kwargs...), X[:, :Index])
Indicators.kama(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.kama(X[:, x]; kwargs...), X[:, :Index])
Indicators.alma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.alma(X[:, x]; kwargs...), X[:, :Index])
Indicators.zlema(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.zlema(X[:, x]; kwargs...), X[:, :Index])
# VWMA is defined on Matrix, not Array
# VWAP is defined on Matrix, not Array
Indicators.hama(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.hama(X[:, x]; kwargs...), X[:, :Index])


end