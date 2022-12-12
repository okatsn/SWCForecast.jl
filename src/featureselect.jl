# Feature selections
function excludekey!(expr::Regex,inputfeaturenames::Vector)
    deleteat!(inputfeaturenames, occursin.(expr, string.(inputfeaturenames)))
end

function excludekey!(expr::AbstractString,inputfeaturenames::Vector)
    excludekey!(Regex(expr),inputfeaturenames)
end





"""
# NOT EXPORTED YET

Given a vector of strings, `selectbytimeshift(namesX, tpast)` returns a vector of `Bool` indicating the elements in `namesX` matching either `["t\$t" for t in tpast]` (e.g., `["t-1", "t-5", ....]`).


"""
function selectbytimeshift(namesX, tpast)
    broadoccur(t,fset) = occursin.(Regex("t$t"), fset)
    # [ for (idtpast, bitv) in enumerate()]
    bitvs = broadoccur.(tpast, [namesX])
    [any(getindex.(bitvs, i)) for i in eachindex(first(bitvs))]
end

fmttsuffix(t) = Regex("t$t\\Z")

"""
Given a vector `tpast` of integers, `iseithertpast(featname, tpast)` returns `true` if the string matches either `["t\$t" for t in tpast]` (e.g., `["t-1", "t-5", ....]`).
"""
iseithertpast(featname, tpast::Vector{<:Integer}) = any(occursin.(fmttsuffix.(tpast), string(featname)))

"""
` tpast::OrdinalRange` is OK.
"""
iseithertpast(featname, tpast::OrdinalRange) = iseithertpast(featname, collect(tpast))

"""
Given a vector `tpast` of integers, `tpastfeatsele(tpast)` returns a `FeatureSelector` that keep columns where `iseithertpast(columnname, tpast)` returns `true`.
"""
tpastfeatsele(tpast) = FeatureSelector(features = str -> iseithertpast(str, tpast))



"""
`featselemach(fullX::DataFrame, selector::FeatureSelector)`
returns a machine `mss` ready to be applied as `Xs = MLJ.transform(mss, X0)`
"""
function featselemach(fullX::DataFrame, selector::FeatureSelector)
    mss = machine(selector, fullX)
    fit!(mss)
    return mss
end

"""
`featselemach(fullX::DataFrame, tpast::Vector{<:Integer})`
"""
function featselemach(fullX::DataFrame, tpast)
    selector = tpastfeatsele(tpast)
    mss = featselemach(fullX, selector)
    return mss
end

"""
`tpastfeatsele(fullX::DataFrame, tpast::Vector{<:Integer})` returns the `DataFrame` selected by machine with `tpastfeatsele(tpast)` selector.
"""
function tpastfeatsele(fullX, tpast)
    mss = featselemach(fullX, tpast)
    return MLJ.transform(mss, fullX)
end








"""
Given feature names of the original table (before time shifted), `featureselectbyheadkey(Xtrain, featsets0)` returns the table where only variables with column name matches `headkey_set` in `featsets0` are preserved.
Noted that `headkey` in `headkey_set` must be the first keyword of the column name.

# Example
```julia
Xtrain = DataFrame(
    "tmp" => randn(10),
    "tmp_t0" => randn(10),
    "tmp_t-1" => randn(10),
    "humidity" => randn(10),
    "humidity_t0" => randn(10),
    "pressure_t0" => randn(10),
    "pressure_t1" => randn(10),
)

featsets0 = [
    [:tmp, :humidity],
    [:tmp, :pressure],
    # comma is required even when there is only one union
]
```
and

```julia-repl
julia> featureselectbyheadkey(Xtrain, featsets0)
2-element Vector{Vector{Symbol}}:
 [:tmp, :tmp_t0, Symbol("tmp_t-1"), :humidity, :humidity_t0]
 [:tmp, :tmp_t0, Symbol("tmp_t-1"), :pressure_t0, :pressure_t1]
```

"""
function featureselectbyheadkey(Xtrain, featsets0::Vector{Vector{T}}) where T <: AbstractString
    featsets = Vector{Symbol}[]
    for featset in featsets0
        push!(featsets, featureselectbyheadkey(Xtrain, featset))
    end
    return featsets
end

function featureselectbyheadkey(Xtrain, featset::Vector{<:AbstractString})
    subfeatset_tshift = Symbol[]
    for feat in featset
        targetfeats_j = names(Xtrain, Regex(join(["^",feat]))) .|> Symbol
        push!(subfeatset_tshift, targetfeats_j...)
    end
    return union(subfeatset_tshift)
end


function _featureselectbyheadkey_test(Xtrain, featsets0::Vector{Vector{T}}) where T <: AbstractString
    featsets = Vector{Symbol}[]
    for featset in featsets0
        subfeatset_tshift = Symbol[]
        for feat in featset
            targetfeats_j = names(Xtrain, Regex(join(["^",feat]))) .|> Symbol
            push!(subfeatset_tshift, targetfeats_j...)
        end
        push!(featsets, union(subfeatset_tshift))
    end
    return featsets
end
