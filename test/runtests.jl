using ControlRL
using Test
using Plots

@testset "ControlRL.jl" begin
    x0 = make_x0()
    x = [x0]
    for i in 1:100
        push!(x, sim(x[end], true))
    end
    # Equivalent to `@test isapprox(x[end], zeros(size(x[end])), atol=1e-5)`
    @test x[end] ≈ zeros(size(x[end])) atol=1e-5
    
    x_inplace = copy(x0)
    for i in 1:100
        sim!(x_inplace, true)
    end

    @test x_inplace == x[end]
end
