module ControlRL

export Environment, step, state, reward, sim
include("sim.jl")

export benchmarks, c2d
include("models.jl")

end
