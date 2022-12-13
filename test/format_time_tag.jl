@testset "format_time_tag.jl" begin
    @test format_time_tag(["t-1,t-2,t-3"]) == "t_i, i=-1"
    @test format_time_tag(["t-1","t-2","t-3"]) == "t_i, i=-3,...,-1"
    @test format_time_tag(["t-1","t-2"]) == "t_i, i=-2,-1"
    @test format_time_tag(["t+1","t+2"]) == "t_i, i=1,2"
    @test format_time_tag(["t1","t2"]) == "t_i, i=1,2"
    @test format_time_tag(["t+1"]) == "t_i, i=1"
    @test format_time_tag(["t1"]) == "t_i, i=1"
    @test format_time_tag(["t-1", "t-2", "t-3", "t-4"]) == "t_i, i=-4,-3,...,-1"

    @test parselag("hello_t01_whatever_t-2") == -2
    @test parselag("hello_t01_whatever_t209") == 209
    @test_throws ErrorException parselag("hello_t01_whatever")
    @test_throws ErrorException parselag("hello_t-1_whatever")
end
