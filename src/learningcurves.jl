"""
Learning Curve Object `LC = LearningCurves(tag2machs, tag2grid, curves, parameter_values)`.
It supports `getindex` of the following to obtain element(s) of `curve.measurements` for `curve` in `curves`; where `curves = MLJ.learning_curve.(machines)`, `LC.parameter_values = curves[1].parameter_values` (`curves[i].parameter_values == curves[j].parameter_values` should hold for any `i`, `j` in `eachindex(curves)`).

Use `learningcurves` only to create `LearningCurves` objects.

In indexing `LC`, the first dimension is indexed to the `curve` of a certain machine, whereas the second dimension is indexed to the output grid of `MLJ.learning_curve` (the grid is determined by both `range =...` and `resolution=...` keyword arguments).
That is, `LC[id2mach, id2grid] == curves[id2mach].measurements[id2grid]` where `machines[id2mach]` matches `LC.tag2machs[id2mach]` and `LC.parameter_values[id2grid]` matches `LC.tag2grid[id2grid]`. See also `learningcurves`.

# Currently supported indexing method:
- `LC[:,:]`
- `LC[1,:]`
- `LC[:,1]`
- `LC[:, "pressure"]`
- `LC["10cm", :]`
> Indexing to multiple rows/columns is not supported yet.
"""
struct LearningCurves
    tag2machs
    tag2grid
    curves
    parameter_values
end




"""
`learningcurves(tag_machines::Vector{<:Pair}, tags4grid::Vector; kwargs...)` accepts keyword arguments `kwargs` as `MLJ.learning_curve`; it returns a `LearningCurves` object instead of `curves = MLJ.learning_curve.(machines)`.
In `learningcurves` there is a testset for checking whether `tags4grid` fits in length of every output `curve.parameter_values`.

# Example
```julia
name_mach = [(tnm => machine(model, X0, y_i)) for (tnm, y_i) in pairs(eachcol(y0))]
rangef = range(model, :(selector.features), values = featsets)
ftags = ["feature_set #1", "feature_set #2"]

LC = learningcurves(name_mach,ftags; range = rangef,
            resampling =  CV(nfolds=5),
            measure = mae,
            rngs = 1,
            rng_name = :(tree.rng)
            )
```
In this case, the output `parameter_values` for each machine must match `ftags` in length; otherwise, error will occurred.

"""
function learningcurves(tag_machines::Vector{<:Pair}, tags4grid::Vector{<:Union{String,Symbol}}; kwargs...)
    machtags = first.(tag_machines)
    machines = last.(tag_machines)
    curves = MLJ.learning_curve.(machines; kwargs...)
    pvs = [c.parameter_values for c in curves]
    pvs1st = first(pvs)
    @testset "Check if all parameter_values are identical" begin
        @test isequal.([pvs1st], pvs) |> all
        @test length(pvs1st) == length(tags4grid)
    end
    LC = LearningCurves(machtags, tags4grid, curves,pvs1st)
    return LC
end

"""
If `tags4grid` is a vector of vector(s), `TunedModel` is applied instead since `MLJ.learning_curve` does not
support a vector of range.
"""
function learningcurves(tag_machines::Vector{<:Pair}, tags4grid::Vector{<:Vector};
                        # kwargs_learning_curve..., # To be replaced
                        kwargs...) # e.g., kwargs_TunedModel

    # Hello, this section the code is copied from `MLJ.learning_curve`
    if rngs != nothing
        rng_name == nothing &&
            error("Having specified `rngs=...`, you must specify "*
                  "`rng_name=...` also. ")
        if rngs isa Integer
            rngs = MersenneTwister.(1:rngs)
        elseif rngs isa AbstractRNG
            rngs = [rngs, ]
        elseif !(rngs isa AbstractVector{<:AbstractRNG})
            error("`rng` must have type `Integer` , `AbstractRNG` or "*
                  "`AbstractVector{<:AbstractRNG}`. ")
        end
    end

    return nothing
end

function SWCForecast.getindex(LC::LearningCurves, id2mach::Int, id2grid::Union{Int,Colon})
    return LC.curves[id2mach].measurements[id2grid]
end

function SWCForecast.getindex(LC::LearningCurves, id2mach::Colon, id2grid::Colon)
    meas = [cv.measurements[:] for cv in LC.curves]
    M = hcat(meas...)'
    return M
end

function SWCForecast.getindex(LC::LearningCurves, id2mach::Colon, id2grid::Int)
    getmae(curve,i) = curve.measurements[i]
    return getmae.(LC.curves, id2grid)
end

function SWCForecast.getindex(LC::LearningCurves, id2mach::Colon, str2grid::Union{String, Symbol})
    idg = occursin.(str2grid, string.(LC.tag2grid)) |> findall |> only
    return LC[:, idg]
end

function SWCForecast.getindex(LC::LearningCurves, str2mach::Union{String, Symbol}, id2grid::Colon)
    idm = occursin.(str2mach, string.(LC.tag2machs)) |> findall |> only
    return LC[idm, :]
end
