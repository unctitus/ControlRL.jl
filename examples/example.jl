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
	Pkg.add(url="https://github.com/shengjiex98/ControlRL.jl.git")
	Pkg.add("Plots")
	Pkg.add("LinearAlgebra")
	Pkg.add("PlutoUI")
	using ControlRL
	using Plots
	using LinearAlgebra
	using PlutoUI
end

# ╔═╡ 4f63bf67-8208-4742-8dee-aa3186c8d658
x0 = make_x0()

# ╔═╡ 66fbe369-33e7-409f-ae66-29c1984518b3
let
	x = [x0]
	for i in 1:100
		push!(x, sim(x[end], true))
	end
	@info stack(x)
	plot(0:100, stack(x)')
end

# ╔═╡ f26b1042-1974-4575-8faf-8f893c3e0584
@bind control_threshold Slider(0:0.1:2, show_value=true, default=0)

# ╔═╡ c0d2cc64-1f96-4405-a211-32e575cff94b
let
	x = [x0]
	for i in 1:100
		if norm(x[end]) > control_threshold
			push!(x, sim(x[end], true))
		else
			push!(x, sim(x[end], false))
		end
	end
	
	@info stack(x)
	plot(0:100, stack(x)')
end

# ╔═╡ Cell order:
# ╠═04f3e318-6489-11ef-1ccc-89d0ed2d1029
# ╠═4f63bf67-8208-4742-8dee-aa3186c8d658
# ╠═66fbe369-33e7-409f-ae66-29c1984518b3
# ╠═f26b1042-1974-4575-8faf-8f893c3e0584
# ╠═c0d2cc64-1f96-4405-a211-32e575cff94b
