module StippleActiveTables

using Stipple
using Stipple: flexgrid_kwargs
import Stipple.Genie
import Stipple.Genie.Renderer.Html: normal_element, register_normal_element, script

using DataFrames

export ActiveTable, activetable

const assets_config = Genie.Assets.AssetsConfig(package = "StippleActiveTables.jl")

function deps() :: Vector{String}
    [script(type = "module", src = Genie.Assets.asset_path(assets_config, :js, file="activeTable.bundle"))]
end

function deps_routes(; basedir = @__DIR__) :: Nothing
    if !Genie.Assets.external_assets(assets_config)
        Genie.Assets.add_fileroute(assets_config, "activeTable.bundle.js"; basedir = joinpath(dirname(basedir), "assets"))
    end

    nothing
end

function __init__()
    deps_routes()
end

mutable struct ActiveTable
    data::DataFrame
end

function Stipple.stipple_parse(::Type{ActiveTable}, v::Vector)
    isempty(v) && return DataFrame
    matrix = reduce(hcat, v[2:end])
    ActiveTable(DataFrame([[matrix[i, :]...] for i in 1:size(matrix, 1)], v[1]))
end

function Stipple.render(at::ActiveTable)
    vcat([names(at.data)], [Matrix(at.data)[i, :] for i in 1:nrow(at.data)])
end

register_normal_element("active__table", context = @__MODULE__)

function activetable(data::Symbol, args...; kwargs...)
    kwargs = Stipple.attributes(flexgrid_kwargs(; data, kwargs...))
    active__table(:active__table, args...; kwargs...)
end

end # module StippleActiveTables

