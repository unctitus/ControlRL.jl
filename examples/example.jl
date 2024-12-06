### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 04f3e318-6489-11ef-1ccc-89d0ed2d1029
begin
	import Pkg
	Pkg.activate(".")
	Pkg.instantiate()
	using Revise
	using Plots
	plotlyjs()
	using LinearAlgebra
	using PlutoUI
	push!(LOAD_PATH, "$(@__DIR__)/../src")
	using ControlRL
	TableOfContents()
	Pkg.add("PlotlyJS")
end

# ╔═╡ abb82687-12f0-4754-b3dd-49c03f3c9ad1
md"""
## Setting up Packages
"""

# ╔═╡ 5ff9a070-12a3-45fd-a1b4-b619998e468a
md"""
## Defining the policy π

The reference policy π₀ is defined as meeting all deadlines:
"""

# ╔═╡ 2fd32b80-1d52-4a97-8dab-46f1278ebc58
π₀(actions::Vector{Bool}, states::Vector{Vector{Float64}}, rewards::Vector{Float64}) = true

# ╔═╡ 2423d6a3-bc61-4659-b9d0-023f2685bff8
const safety_margin = 100

# ╔═╡ 0fb1d484-3b49-4af5-8edb-e7c9214ac951
global util_history = [] 

# ╔═╡ 05117c1b-a715-44f4-9f98-c7fbca48ce30
md"""
**You only need to change the section below.**

Define your own policy here.
The reward is currently defined as the negation of distance between current
state and the state obtained by following the reference policy π₀.

Several example policies are provided. Feel free to experiment with one of them,
combine two or more of them, or experiment with your own policies!
"""

# ╔═╡ 8015eee9-cfe9-4890-a3a5-e3f97517d1d2
md"""
!!! note

	Some of the policies are defined with the [compact function declaration syntax](https://docs.julialang.org/en/v1/manual/functions/#man-functions), which is equivalent to the normal syntax. I.e., the following two declarations are equivalent:
	```julia
	π₀(actions::Vector{Bool}, states::Vector{Vector{Float64}}, rewards::Vector{Float64}) = true
	```
	and
	```julia
	function π₀(actions::Vector{Bool}, states::Vector{Vector{Float64}}, rewards::Vector{Float64})
		return true
	end
	```
!!! note
	The symbol "π" can be entered by typing `\pi` followed by the `<tab>` key. This is a nice feature of Julia and can be used to enter [any UNICODE character](https://docs.julialang.org/en/v1/manual/unicode-input/)! Under the hood, this is possible because Julia allows UNICODE characters to be part of function names and variable names in addition to the ASCII characters.
"""

# ╔═╡ c57331ac-ea8e-44b9-9213-9cad71788244
md"""
## Outputs

Define the sampling period $T$ and time horizon $H$
"""

# ╔═╡ 311337a7-9402-4ade-8707-e9ba9b72fa3b
const T = 0.02

# ╔═╡ 837c7cf2-66cb-4ebe-a417-df1e5da9cc73
const H = 1500

# ╔═╡ 2fee3edd-bba5-4738-a43c-691c9b4cf3de
md"""
Display all available models.
"""

# ╔═╡ 64bf8494-2e6c-4ad7-bffa-cf4a6ae74456
benchmarks

# ╔═╡ 84f2e971-241e-4895-9daf-18a65de77ea5
md"""
Convert a chosen model from continuous to discrete form using sampling period $T$ = $T
"""

# ╔═╡ a274cbd6-13c3-499f-8407-41211e25dae1
sys = c2d(benchmarks[:CC], T)

# ╔═╡ 4730f9cd-493d-42ea-9006-013a746a149f
md"""
Initiate the simulation environment and Simulate the system for $H$ steps.
"""

# ╔═╡ 09e3258a-a3fe-43a0-8f65-0d4a13b5c513
md"""
Calculate the total rewards over $H=$ $H steps
"""

# ╔═╡ 94d169f1-52db-4025-b018-a522fc306174
mean_utilization = sum(util_history)/ length(util_history)

# ╔═╡ 1580b319-08a8-4b2a-baf1-0fd326ce9d61
length(util_history)

# ╔═╡ eb39929a-46b6-4d53-a3e9-30af17500b54
md"""
Plot the trajectory of system dynamics following the reference policy.
"""

# ╔═╡ 9fe9173a-a458-4d3e-ac8f-1b4443dd4efc
begin
	#@bind safety_margin Slider(10:1:200, show_value=true)
	#safety_margin = 1000
end

# ╔═╡ d9b853f3-4f79-487e-98ef-2f1b321b9d69
md"""
Plot the trajectory of system dynamics following the defined policy.
"""

# ╔═╡ ad589207-0f42-446a-b3d6-167a54c02950
md"""
Plot the rewards (distance to the reference trajectory).
"""

# ╔═╡ 0ec39f15-aec2-4bd3-9847-d39ba9384588
@bind k Slider(-3:0.1:6, default=1, show_value=true)

# ╔═╡ e2c486a5-f734-4d24-893b-470e099180e3
@bind s Slider(-8:0.1:8, default=0, show_value=true)

# ╔═╡ e705f0df-bdcc-4673-976f-5d096c6a2abc
md"""
## Helper functions
"""

# ╔═╡ c34375b4-70ab-4468-9186-c43948f22a7a
plotH(v::Vector{Float64}) = plotH(reshape(v, 1, :))

# ╔═╡ efe4cb0d-76c1-421c-827b-726aafa4399b
function plot_distance(distances::Matrix{Float64})
	# Transposing `states` because plot uses the first dimension as indices.
	plot(0:size(distances, 2) - 1, 
		distances', 
		titlefont=12,
		label="Distance", 
		xlabel="Time Steps", 
		ylabel="Distance", 
		title="Distance to the Optimal State over Time", 
		legend=:bottomright,
		legend_orientation=:horizontal,
		color=:green,
		grid=true,)
	hline!([safety_margin], 
		label="safety margin = $safety_margin", 
		linestyle=:dash, 
		color=:red)
end

# ╔═╡ 669766e5-1f5f-4665-872d-ecb066887917
plot_distance(v::Vector{Float64}) = plot_distance(reshape(v, 1, :))

# ╔═╡ 70814015-d5b6-4a01-afeb-090d2aa40681

"""
	plot_utilization(actions::Vector{Bool})

Plots the utilization over time based on the actions array.
"""
function plot_utilization(actions::Vector{Bool})
	
	# Calculate utilization
	utilization = cumsum(Int.(actions)) ./ (1:length(actions))
	
	# Plot the utilization over time
	plot(0:length(actions)-1, 
		utilization, 
		titlefont=12,
		label="Utilization", 
		xlabel="Time Steps", 
		ylabel="Utilization", 
		title="Utilization over Time", 
		legend=:bottomright,
		color=:blue,
		grid=true)
end

# Example usage
#actions2 = [false, true, true, false, true, false, false, true]
#plot_utilization(actions2)
	

# ╔═╡ 44a9be8a-c9c8-49a8-bfaf-f81aa05d5516
function sig_prob(value, safety_margin)
    x_min = 0
    x_max = safety_margin
    y_min = -10
    y_max = 10
	value = min(value, safety_margin)
    # Linear mapping
    mapped_value = (value - x_min) * ((y_max - y_min) / (x_max - x_min)) + y_min
    #return 1 / (1 + exp(-mapped_value))
	return 1 / (1 + exp(-(mapped_value - s) * k))
end

# ╔═╡ fac6522b-c189-4b7c-be35-11d038a854bc
"""
	π(actions, states, rewards)

The policy π decides the action (deadline hit/miss) based on the history of
past actions, states, and rewards. It returns a single true/false value.
"""
function π(actions::Vector{Bool}, states::Vector{Vector{Float64}}, rewards::Vector{Float64})
	## Example 1: return true when the distance to reference is greater than 1
	# return rewards[end] <= -1
	
	## Example 2: return true when the distance increase consecutively for 3 steps
	# return length(rewards) > 2 && (rewards[end-2] > rewards[end-1] > rewards[end])

	## Example 3: return true when the utilization up to now is less than 0.5
	#return length(actions) > 0 && (sum(actions) / length(actions) > 0.2)

	#Idea 1
	#Execute either if the out of 80% of the safety margin (100) or if utilization rate is below 0.38 
	#safety_margin = 100
	if length(actions) == 0
		#reset util history
	    #empty!(util_history)
	end
	
	util_rate = length(actions) > 0 ?  sum(actions) / length(actions) : 0
	push!(util_history, util_rate)
	#return (-rewards[end] > 0.8 * safety_margin || util_rate < 0.38) ? true : false
	
	#Results
	#Works for:  CC, RC, DC, F1, CS, MPC
	#Does not work for:  EW
	#Oberservation: util rate can be used to limit divergence 
	#if the util rate is below 0.25 it still diverges constantly
	#if the util rate is 0.38. Good Convergence
    
	
	#Idea 2: Idea 1, but only utilization 
	#return util_rate < 0.15 ? true : false

	#Idea 3: Idea 1, but only safty margin
    #return -rewards[end] > 0.8 * safety_margin  ? true : false

	#Idea 4: 
	#k = 1
	#r1 = length(rewards) >= k && any(-rewards[end-i] > 0.8 * safety_margin for i in 0:k-1)
   	#return r1 ? true : false
	#Obeservation: k=4 helps to reduce utilization a little bit but otherwise setting a higher k is uselese and worsen the utilization 

	#Idea 5: Execute the job with a proability proportinal to the distance of the optimal trajectory.

	#linear probability increase
	#return rand() <= min(-rewards[end], safety_margin)/safety_margin ? true : false

	#sigmoid probability increase
	return rand() <= sig_prob(-rewards[end], safety_margin) ? true : false

	
	return false
	
	
	#Questions: What would be meaningful safeyt margin for each system? Or just assume any? 
	#Optimal Strategy: Minimum utilization rate while not leaving the safety margins.
	
	#r1 = length(rewards) > 2 && (rewards[end-2] > rewards[end-1] > rewards[end])
	#r2 = rewards[end] < -0.8 * safety_margin
	
	#return (-rewards[end] > 0.2 * safety_margin) ? true : false
	#return (r1 || r2 || util_rate < 0.6) ? true : false

	#another idea: try out a sampling approach 

end

# ╔═╡ cbd51753-b04a-40c9-8f5b-9b88c74fc6f7
actions, states, rewards, ideal_states = let 
	env = Environment(sys)
	sim!(env, π, H)
end

# ╔═╡ 45b657ae-6220-44b3-aa35-cae27bf730b0
total_rewards = sum(rewards)

# ╔═╡ 9c99d8ea-c858-4e42-9400-e69d2d1fcb94
mean_distance = -sum(rewards)/length(rewards)

# ╔═╡ 699627e9-5303-4149-ba96-048c55360c68
length(rewards)

# ╔═╡ 7c54f79a-6bb4-4190-ab13-bca71bb868a8
p_dist = plot_distance(.-rewards)

# ╔═╡ 35e9c74e-ef57-43d6-97e1-f7b4c6206b59
p_util = plot_utilization(actions)

# ╔═╡ 2b07679d-8078-4c73-84fc-c7d83d8daa2a
combined_plot = plot(p_dist, p_util, layout=(1, 2), legend=:bottomright,size=(1000,400))

# ╔═╡ 8bd3cfc7-8aca-4e52-b567-237213016f22
#for storing the compound plot 
begin
	using PlotlyJS
	plotlyjs()
	Plots.prepare_output(combined_plot)
	PlotlyJS.savefig(Plots.plotlyjs_syncplot(combined_plot), "../figures/system_metrics_CC_sigmoid_k05.pdf", width=1000, height=400)
end

# ╔═╡ 5402045e-83ef-4b90-9f14-1796fdadacc0
"""
	plotH(x)

Plot the system states as recorded in states matrix.
"""
function plotH(states::Matrix{Float64})
	# Transposing `states` because plot uses the first dimension as indices.
	plot(0:size(states, 2) - 1, states')
end

# ╔═╡ 19634c38-ec2c-45a0-862a-3f92beecb5a1
plotH(ideal_states)

# ╔═╡ 66fbe369-33e7-409f-ae66-29c1984518b3
plotH(states)

# ╔═╡ 2114c3d9-6e3b-4468-a27e-aa05a40df626
begin
	### Define the sigmoid function ###
	sigmoid(x, k, s) = 1 / (1 + exp(-(x - s) * k))
	
	### Create a range of x values ###
	x = -10:0.1:10
	
	### Compute the sigmoid values based on the interactive k ###
	y = sigmoid.(x, k, s)
	y_k = sigmoid.(x, 0.5, s)
	y_s = sigmoid.(x, k, 3)

	### Define a linear function ###
	linear(x, m, b) = m * x + b
	
	### Set parameters for the linear function ###
	m = 0.05  # Slope of the linear function
	b = 0.5  # Intercept of the linear function
	
	### Compute the linear values ###
	y_linear = linear.(x, m, b)

	### Plot the sigmoid function ###
	plot(x, y, xlabel="x", ylabel="pᵢ(1)", label="σ(x)", lw=2,ylim=(-0.05, 1.05),legend=:bottomright, grid=true, title="Probability of Choosing Action 1")
	#plot!(x, y_k, label="σ(0.5x)", lw=2)
	#plot!(x, y_s, label="σ(x-2)", lw=2)
	#plot!(x, y_linear, label="Linear", lw=2, color=:grey)
	#savefig("sigmoid_linear_plot.pdf")
end

# ╔═╡ Cell order:
# ╟─abb82687-12f0-4754-b3dd-49c03f3c9ad1
# ╠═04f3e318-6489-11ef-1ccc-89d0ed2d1029
# ╟─5ff9a070-12a3-45fd-a1b4-b619998e468a
# ╠═2fd32b80-1d52-4a97-8dab-46f1278ebc58
# ╠═2423d6a3-bc61-4659-b9d0-023f2685bff8
# ╠═0fb1d484-3b49-4af5-8edb-e7c9214ac951
# ╟─05117c1b-a715-44f4-9f98-c7fbca48ce30
# ╠═fac6522b-c189-4b7c-be35-11d038a854bc
# ╟─8015eee9-cfe9-4890-a3a5-e3f97517d1d2
# ╟─c57331ac-ea8e-44b9-9213-9cad71788244
# ╠═311337a7-9402-4ade-8707-e9ba9b72fa3b
# ╠═837c7cf2-66cb-4ebe-a417-df1e5da9cc73
# ╟─2fee3edd-bba5-4738-a43c-691c9b4cf3de
# ╠═64bf8494-2e6c-4ad7-bffa-cf4a6ae74456
# ╟─84f2e971-241e-4895-9daf-18a65de77ea5
# ╠═a274cbd6-13c3-499f-8407-41211e25dae1
# ╟─4730f9cd-493d-42ea-9006-013a746a149f
# ╠═cbd51753-b04a-40c9-8f5b-9b88c74fc6f7
# ╟─09e3258a-a3fe-43a0-8f65-0d4a13b5c513
# ╠═45b657ae-6220-44b3-aa35-cae27bf730b0
# ╠═9c99d8ea-c858-4e42-9400-e69d2d1fcb94
# ╠═94d169f1-52db-4025-b018-a522fc306174
# ╠═1580b319-08a8-4b2a-baf1-0fd326ce9d61
# ╠═699627e9-5303-4149-ba96-048c55360c68
# ╟─eb39929a-46b6-4d53-a3e9-30af17500b54
# ╠═9fe9173a-a458-4d3e-ac8f-1b4443dd4efc
# ╠═19634c38-ec2c-45a0-862a-3f92beecb5a1
# ╟─d9b853f3-4f79-487e-98ef-2f1b321b9d69
# ╠═66fbe369-33e7-409f-ae66-29c1984518b3
# ╟─ad589207-0f42-446a-b3d6-167a54c02950
# ╠═7c54f79a-6bb4-4190-ab13-bca71bb868a8
# ╠═35e9c74e-ef57-43d6-97e1-f7b4c6206b59
# ╠═2b07679d-8078-4c73-84fc-c7d83d8daa2a
# ╠═0ec39f15-aec2-4bd3-9847-d39ba9384588
# ╠═e2c486a5-f734-4d24-893b-470e099180e3
# ╟─e705f0df-bdcc-4673-976f-5d096c6a2abc
# ╠═5402045e-83ef-4b90-9f14-1796fdadacc0
# ╠═c34375b4-70ab-4468-9186-c43948f22a7a
# ╠═efe4cb0d-76c1-421c-827b-726aafa4399b
# ╠═669766e5-1f5f-4665-872d-ecb066887917
# ╠═70814015-d5b6-4a01-afeb-090d2aa40681
# ╠═44a9be8a-c9c8-49a8-bfaf-f81aa05d5516
# ╠═2114c3d9-6e3b-4468-a27e-aa05a40df626
# ╠═8bd3cfc7-8aca-4e52-b567-237213016f22
