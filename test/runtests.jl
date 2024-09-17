using Test
using ControlRL

@testset "ControlRL.jl" begin
    T = 0.1
    sys = c2d(benchmarks[:F1], T)
    env = Environment(sys)

    H = 100
    s, r = state(env), reward(env)
    for t in 1:H
        s, r = step!(env, true)
    end

    # Equivalent to `@test isapprox(state, zeros(size(state)), atol=1e-5)`
    @test s ≈ zeros(size(s)) atol=1e-5
    @test r ≈ 0.0 atol=1e-5

    env2 = Environment(sys)
    states, rewards = sim!(env2, (s, r) -> true, H)

    @test states[:, end] == s
    @test rewards[end] == r
end
