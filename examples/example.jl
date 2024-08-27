### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 04f3e318-6489-11ef-1ccc-89d0ed2d1029
begin
	import Pkg
	Pkg.activate(".")
	Pkg.add(url="https://github.com/shengjiex98/ControlRL.jl.git")
	Pkg.add("Plots")
	using ControlRL
	using Plots
end

# ╔═╡ 4f63bf67-8208-4742-8dee-aa3186c8d658
x0 = make_x0()

# ╔═╡ 66fbe369-33e7-409f-ae66-29c1984518b3
let
	x = [x0]
	for i in 1:100
		push!(x, sim(x[end], true))
	end
	@info stack(x)'
	plot(0:100, stack(x)')
end

# ╔═╡ Cell order:
# ╠═04f3e318-6489-11ef-1ccc-89d0ed2d1029
# ╠═4f63bf67-8208-4742-8dee-aa3186c8d658
# ╠═66fbe369-33e7-409f-ae66-29c1984518b3
