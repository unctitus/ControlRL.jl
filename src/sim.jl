using ControlBenchmarks: benchmarks
using ControlSystemsBase: lqr, c2d, Discrete
using LinearAlgebra: I

const P = 0.02
const SYS = c2d(benchmarks[:F1], P)
const K = lqr(Discrete, SYS.A, SYS.B, I, I)

function sim(x::Vector{<:Real}, hit::Bool)
    length(x) == SYS.nx || error("Dimensions of the state `x` must match dimensions of the system")
    if hit
        return SYS.A * x - SYS.B * K * x
    else
        return SYS.A * x
    end
end

function sim!(x::Vector{<:Real}, hit::Bool)
    x .= sim(x, hit)
end

function make_x0()
    return repeat([1.], SYS.nx)
end
