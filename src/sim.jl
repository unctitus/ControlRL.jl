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
