# Methods for porting Indicators.jl functions to TSFrame objects from TSFrames.jl package
# See their respective documentation on Indicators.jl
runmean(X::TSFrame, x::Symbol; args...) = TSFrame(Indicators.runmean(X[:,x]; args...))
sma(X::TSFrame, x::Symbol; args...) = TSFrame(Indicators.sma(X[:,x]; args...))