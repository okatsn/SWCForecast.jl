using DataFrames
using SWCForecast
using MLJ
using Random
@testset "Test `getindex(LC::LearningCurves)`" begin
    function fstree()
        selector = FeatureSelector()

        treemodel = (@load "DecisionTreeRegressor" pkg = "DecisionTree" verbosity = 0)() # regressor type

        mypipe = Pipeline(
            selector = selector,
            tree = treemodel
        )

        return mypipe
    end
    resampler = CV(;nfolds=3);
    rangex = 1:9
    rangey = 1:3
    ynames = ["y$i" for i in rangey]
    nr = maximum(rangey) # number of rows
    nc = maximum(rangex) #           columns
    X0 = DataFrame(randn(1000, nc), :auto)
    y0 = DataFrame(randn(1000, nr), ynames)
    fullxkeys = names(X0) .|> Symbol
    model =  fstree()
    tag_featsets = ["no $xk" => fullxkeys[.!isequal.(xk, fullxkeys)] for xk in fullxkeys]
    ftags = first.(tag_featsets)
    featsets = last.(tag_featsets)
    tag_machines = [tag_mach => machine(model, X0, yi) for (tag_mach, yi) in pairs(eachcol(y0))]
    targetnames = first.(tag_machines)
    machines = last.(tag_machines)

    LC = learningcurves(tag_machines, ftags; resampling = resampler,
        range= range(model, :(selector.features), values = featsets), measure=mae,
        rngs = 1,
        rng_name = :(tree.rng)
        )

    curves = LC.curves
    rangeft = eachindex(ftags)
    for id2mach in rangey
        for id2grid in rangeft
            @test LC[id2mach, id2grid] == curves[id2mach].measurements[id2grid]
        end
    end
    getm(curve, i) = curve.measurements[i]
    for id2grid in rangeft
        @test LC[:, id2grid] == getm.(curves, id2grid)
    end

    for id2mach in rangey
        @test LC[id2mach, :] == curves[id2mach].measurements
    end
    M = Array{Any, 2}(undef, nr, nc)
    [setindex!(M, curves[i].measurements[j], i, j) for i in rangey for j in rangex];
    @test LC[:, :] == M

    for id2mach in rand(eachindex(machines), 2)
        for id2fset in rand(eachindex(featsets),2)
            id2fset = rand(eachindex(featsets)) |> only

            # Load learning curve model
            mach_l = machines[id2mach]
            curve = curves[id2mach]
            mae_l = curve.measurements[id2fset]

            # Testing model
            model.selector.features = featsets[id2fset]
            mach = machine(model, X0, y0[!, targetnames[id2mach]])
            Random.seed!(1) # You should also set `rng` in `learning_curve.(machines, ...)`
            ev = evaluate!(mach; resampling = resampler, measure=mae)
            mae_t = ev.measurement |> only
            @test isapprox(mae_l, mae_t; atol=0.01)# test if the two mae are similar. They won't be identical since Random is applied in each training.
        end
    end
end
