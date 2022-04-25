using SafeTestsets, Pkg

const GROUP = get(ENV, "GROUP", "All")

function dev_subpkg(subpkg)
    subpkg_path = joinpath(dirname(@__DIR__), "lib", subpkg)
    Pkg.develop(PackageSpec(path=subpkg_path))
end

function activate_subpkg_env(subpkg)
    subpkg_path = joinpath(dirname(@__DIR__), "lib", subpkg)
    Pkg.activate(subpkg_path)
    Pkg.develop(PackageSpec(path=subpkg_path))
    Pkg.instantiate()
end

@time begin
if GROUP == "All" || GROUP == "Core"
    dev_subpkg("GalacticOptimJL")
    dev_subpkg("GalacticFlux")
    @safetestset "AD Tests" begin include("ADtests.jl") end
    @safetestset "Mini batching" begin include("minibatch.jl") end
    @safetestset "DiffEqFlux" begin include("diffeqfluxtests.jl") end
elseif GROUP == "GPU"
    dev_subpkg("GalacticOptimJL")
    dev_subpkg("GalacticFlux")
    activate_downstream_env()
    @safetestset "DiffEqFlux GPU" begin include("downstream/gpu_neural_ode.jl") end
else
    dev_subpkg(subpkg)
    include(joinpath(subpkg,"test","runtests.jl"))
end
end
