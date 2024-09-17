import Base: step
using ControlSystemsBase: lqr, c2d, ss, StateSpace, Discrete
using LinearAlgebra: I, norm

mutable struct Environment
    sys::StateSpace{<:Discrete}
    K::Matrix{Float64}
    state::Vector{Float64}
    state_ideal::Vector{Float64}
end

"""
    Environment(sys)

Constructor for `Environment` with the given system `sys`.
"""
function Environment(sys::StateSpace{<:Discrete})
    return Environment(sys, lqr(Discrete, sys.A, sys.B, I, I), make_x0(sys), make_x0(sys))
end

"""
    step(env, action)

Simulate the plant's dynamics for one step, according to the action `action` (true for hitting the deadline, false for missing it).
"""
function step(env::Environment, action::Bool)
    env.state = if action
        env.sys.A * env.state - env.sys.B * env.K * env.state
    else
        env.sys.A * env.state
    end
    env.state_ideal = env.sys.A * env.state - env.sys.B * env.K * env.state

    return state(env), reward(env)
end

"""
    sim(env, π, H)

Simulate the environment for `H` steps using policy `π`.
Returns two vectors containing the states and rewards for each step.
"""
function sim(env::Environment, π::Function, H::Int)
    states = Vector{Vector{Float64}}(undef, H + 1)
    rewards = Vector{Float64}(undef, H + 1)
    
    states[1] = state(env)
    rewards[1] = reward(env)
    
    for t in 1:H
        action = π(states[t], rewards[t])
        states[t + 1], rewards[t + 1] = step(env, action)
    end
    
    return stack(states), rewards
end

"""
    state(env)

Return the current state of the environment.
"""
function state(env::Environment)
    return env.state
end

"""
    reward(env)

Calculate the reward for the given environment at the current step.
"""
function reward(env::Environment)
    return -norm(env.state - env.state_ideal)
end

"""
    make_x0(sys)

A convenience function that returns an initial state with the correct dimensions for the plant.
"""
function make_x0(sys::StateSpace)::Vector{Float64}
    return repeat([1.], sys.nx)
end
