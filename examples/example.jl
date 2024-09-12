### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 04f3e318-6489-11ef-1ccc-89d0ed2d1029
begin
	import Pkg
	Pkg.activate(".")
	Pkg.instantiate()
	push!(LOAD_PATH, "$(@__DIR__)/../src")
	using ControlRL
	using Plots
	using LinearAlgebra
	using PlutoUI

	TableOfContents()
end

# ╔═╡ abb82687-12f0-4754-b3dd-49c03f3c9ad1
md"""
## Setting up Packages
"""

# ╔═╡ 5ff9a070-12a3-45fd-a1b4-b619998e468a
md"""
## Deadline hit/miss patterns

Ideal actions are all deadline hits:
"""

# ╔═╡ 2fd32b80-1d52-4a97-8dab-46f1278ebc58
ideal_actions = ones(Bool, 100)

# ╔═╡ 05117c1b-a715-44f4-9f98-c7fbca48ce30
md"""
**You only need to change the section below.**
Choose one of the strategies, or define your own strategy here.
"""

# ╔═╡ fac6522b-c189-4b7c-be35-11d038a854bc
## Some pre-defined strategies
# actions = ones(Bool, 100) 				# All deadlines are **met**
# actions = zeros(Bool, 100)				# All deadlines are **missed**
actions = repeat([false, false, true], 33) 	# Deadlines are met every third period

## Or define your own strategy below


# ╔═╡ c57331ac-ea8e-44b9-9213-9cad71788244
md"""
## Outputs

Defining the initial state
"""

# ╔═╡ 4f63bf67-8208-4742-8dee-aa3186c8d658
x0 = make_x0()

# ╔═╡ d9b853f3-4f79-487e-98ef-2f1b321b9d69
md"""
Trajectory of the system dynamics following the defined actions
"""

# ╔═╡ eb39929a-46b6-4d53-a3e9-30af17500b54
md"""
Trajectory of the system dynamics following the ideal actions.
"""

# ╔═╡ ad589207-0f42-446a-b3d6-167a54c02950
md"""
The devition between defined actions and ideal actions
"""

# ╔═╡ e705f0df-bdcc-4673-976f-5d096c6a2abc
md"""
## Bootstrapping

The rest of the notebook is bootstrapping the simulation of the plant's dynamics.
"""

# ╔═╡ 2ae91dac-85c2-4fb1-9a08-251dc16f55ca
"""
	simH(x0, action)

Simulate the system dynamics over time horizon H, starting from the initial
state `x0`. `actions` is assumed to have length H.
"""
function simH(x0::Vector{Float64}, actions::Vector{Bool})
	x = [x0]
	for σ ∈ actions
		push!(x, sim(x[end], σ))
	end
	x
end

# ╔═╡ d08f8523-1c9e-4508-8ba6-b3c0165384a7
"""
	devH(x0, actions; ideal_actions)

Compute the deviations between the system dynamics following the defined actions
and the ideal actions. Default for the optional argument `ideal_actions` is all 
deadline hits.
"""
function devH(
		x0::Vector{Float64}, 
		actions::Vector{Bool}; 
		ideal_actions=ones(Bool, length(actions)))
	x = simH(x0, actions)
	ideal_x = simH(x0, ideal_actions)

	# Take the difference per point between two trajectories, then take the norm
	# of the difference over all dimensions.
	(x .- ideal_x) .|> norm
end

# ╔═╡ 5402045e-83ef-4b90-9f14-1796fdadacc0
"""
	plotH(x)

Plot the system dynamics as recorded in state vector `x`.
"""
function plotH(x::Vector{Vector{Float64}})
	plot(0:length(x)-1, stack(x)')
end

# ╔═╡ 599e9ada-5464-46ee-9736-6ee4ee895f36
function plotH(x::Vector{Float64})
	plot(0:length(x)-1, x)
end

# ╔═╡ 19634c38-ec2c-45a0-862a-3f92beecb5a1
simH(x0, actions) |> plotH

# ╔═╡ 66fbe369-33e7-409f-ae66-29c1984518b3
simH(x0, ideal_actions) |> plotH

# ╔═╡ ca73918e-8c00-49d8-a895-70174bfbebe9
devH(x0, actions) |> plotH

# ╔═╡ Cell order:
# ╟─abb82687-12f0-4754-b3dd-49c03f3c9ad1
# ╠═04f3e318-6489-11ef-1ccc-89d0ed2d1029
# ╟─5ff9a070-12a3-45fd-a1b4-b619998e468a
# ╠═2fd32b80-1d52-4a97-8dab-46f1278ebc58
# ╟─05117c1b-a715-44f4-9f98-c7fbca48ce30
# ╠═fac6522b-c189-4b7c-be35-11d038a854bc
# ╟─c57331ac-ea8e-44b9-9213-9cad71788244
# ╠═4f63bf67-8208-4742-8dee-aa3186c8d658
# ╟─d9b853f3-4f79-487e-98ef-2f1b321b9d69
# ╠═19634c38-ec2c-45a0-862a-3f92beecb5a1
# ╟─eb39929a-46b6-4d53-a3e9-30af17500b54
# ╠═66fbe369-33e7-409f-ae66-29c1984518b3
# ╟─ad589207-0f42-446a-b3d6-167a54c02950
# ╠═ca73918e-8c00-49d8-a895-70174bfbebe9
# ╟─e705f0df-bdcc-4673-976f-5d096c6a2abc
# ╠═2ae91dac-85c2-4fb1-9a08-251dc16f55ca
# ╟─d08f8523-1c9e-4508-8ba6-b3c0165384a7
# ╠═5402045e-83ef-4b90-9f14-1796fdadacc0
# ╠═599e9ada-5464-46ee-9736-6ee4ee895f36
