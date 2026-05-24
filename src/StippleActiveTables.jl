module StippleActiveTables

using Stipple
using Stipple: flexgrid_kwargs
import Stipple.Genie.Renderer.Html: normal_element, register_normal_element, script

using DataFrames

export ActiveTable, activetable

const assets_config = Genie.Assets.AssetsConfig(package = "StippleActiveTables.jl")

function deps() :: Vector{String}
    [script(type = "module", src = Genie.Assets.asset_path(assets_config, :js, file = "activeTable.bundle"))]
end

function deps_routes(; basedir = @__DIR__) :: Nothing
    if !Genie.Assets.external_assets(assets_config)
        Genie.Assets.add_fileroute(assets_config, "activeTable.bundle.js"; basedir = normpath(joinpath(@__DIR__, "..")))
    end

    nothing
end

mutable struct ActiveTable
    data::DataFrame
end

register_normal_element("active__table", context = @__MODULE__)

function activetable(data::Symbol, args...; kwargs...)
    kwargs = Stipple.attributes(flexgrid_kwargs(; data, kwargs...))
    active__table(args...; kwargs...)
end

function Stipple.render(at::ActiveTable)
    vcat([names(at.data)], [Matrix(at.data)[i, :] for i in 1:nrow(at.data)])
end

function Stipple.stipple_parse(::Type{ActiveTable}, v::Vector)
    ActiveTable(DataFrame(permutedims(reduce(hcat, v[2:end])), v[1]))
end

function Stipple.convertvalue(activetable::Union{Ref{ActiveTable}, R{ActiveTable}}, v::Vector)
    df_new = Stipple.stipple_parse(ActiveTable, v).data
    df = activetable[].data
    nn = names(df)
    nn_new = names(df_new)
    nn = intersect(nn, nn_new)
    for n in nn
        T = nonmissingtype(eltype(df[:, n]))
        resize!(df, nrow(df_new))
        for i in 1:nrow(df_new)
            x = df_new[i, n]
            df[i, n] = if T <: AbstractString
                x
            elseif x === missing || x == ""
                allowmissing!(df, n)
                missing
            else
                try
                    Stipple.stipple_parse(T, x)
                catch e
                    @warn "Failed to parse value to type $T, make sure the value is compatible or modify the underlying DataFrame column type".
                    missing
                end
            end
        end
    end
    for n in setdiff(nn_new, nn)
        df[!, n] = string.(df_new[:, n])
    end
    select!(df, nn_new)
    activetable
end

function __init__()
    deps_routes()
end

end # module StippleActiveTables

