using ControlSystemsBase: lqr, c2d, Discrete, ss
using LinearAlgebra: I

const P = 0.02
const SYS = let 
    v = 6.5
    L = 0.3302
    d = 1.5
    A = [0 v ; 0 0]
    B = [0; v/L]
    C = [1 0]
    D = 0

    c2d(ss(A, B, C, D), P)
end
const K = lqr(Discrete, SYS.A, SYS.B, I, I)

"""
    sim(x, hit)

Simulate the plant's dynamics for one step, according to whether the deadline is met (`hit=true`) or missed (`hit=false`)
"""
function sim(x::Vector{<:Real}, hit::Bool)::Vector{Float64}
    length(x) == SYS.nx || error("Dimensions of the state `x` must match dimensions of the system")
    if hit
        return SYS.A * x - SYS.B * K * x
    else
        return SYS.A * x
    end
end

"""
    sim!(x, hit)

Simulate the plant's dynamics for one step as in `sim()`, but *updates* the value in `x` in-place.
"""
function sim!(x::Vector{<:Real}, hit::Bool)
    x .= sim(x, hit)
end

"""
    make_x0()

A convenience function that returns an initial state with the correct dimensions for the plant.
"""
function make_x0()
    return repeat([1.], SYS.nx)
end
