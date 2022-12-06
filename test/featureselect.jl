using DataFrames


@testset "featureselectbyheadkey" begin
    df = DataFrame(
        :air_temperature => randn(10),
        :precipitation => randn(10),
        :humidity => randn(10),
        :soil_water_content => randn(10),
        :pressure => randn(10),
        :hour => rand(collect(0:23), 10)
    )

    feat0 = ["hour", "pressure", "precipitation"]

    (X0,) = series2supervised(df => [-1,-2,-3])
    ans1 = featureselectbyheadkey(X0, feat0)
    ans2 = featureselectbyheadkey(X0, [feat0]) |> first
    ans0 = SWCForecast._featureselectbyheadkey_test(X0, [feat0]) |> first
    ans00 = [
        Symbol("hour_t-1"),
        Symbol("hour_t-2"),
        Symbol("hour_t-3"),
        Symbol("pressure_t-1"),
        Symbol("pressure_t-2"),
        Symbol("pressure_t-3"),
        Symbol("precipitation_t-1"),
        Symbol("precipitation_t-2"),
        Symbol("precipitation_t-3"),
    ]
    @test isequal(ans1, ans2)
    @test isequal(ans1, ans0)
    @test isequal(ans00, ans0)
end

@testset "iseithertpast" begin
    tpast = [1,2,-1,-12,0]
    @test iseithertpast("hour_t0", tpast)
    @test !iseithertpast("pressure_t-3", tpast)
    @test iseithertpast("precipitation_t-1", tpast)

    tpast = rand(-20:3:20, 10)
    for tp in tpast
        tr = rand(-20:20, 1) |> only
        str = "hello_world_t$tr"
        ans = in.(tr, tpast) |> any
        @test iseithertpast(str, tpast) == ans
    end
end

@testset "test selector" begin
    nr = 250
    df = DataFrame(
        :air_temperature => randn(nr),
        :precipitation => randn(nr),
        :humidity => randn(nr),
        :soil_water_content => randn(nr),
        :pressure => randn(nr),
        :hour => rand(collect(0:23), nr)
    )

    feat0 = ["hour", "pressure", "precipitation"]

    tpasts = [2, 0, -1,-5,-3]
    (Xs,) = series2supervised(df => tpasts)
    (X0,) = series2supervised(df => collect(range(extrema(tpasts)..., step=1)))

    Xss = tpastfeatsele(X0, tpasts)

    @test isequal(sort(names(Xss)), sort(names(Xs)))
    @test isequal(Xss[!, "hour_t2"], Xs[!, "hour_t2"])
    @test isequal(X0[!, "hour_t2"], Xs[!, "hour_t2"])
    @test isequal(X0[!, "pressure_t-5"], Xs[!,  "pressure_t-5"])
    @test isequal(X0[!, "pressure_t-5"], Xss[!, "pressure_t-5"])
end
