# Methods for porting Indicators.jl functions to TSFrame objects from TSFrames.jl package
# See their respective documentation on Indicators.jl
Indicators.runmean(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.runmean(X[:,x]; kwargs...))
Indicators.sma(X::TSFrame, x::Symbol; kwargs...) = TSFrame(Indicators.sma(X[:,x]; kwargs...))