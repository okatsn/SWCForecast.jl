"""
a type that should be a path
"""
abstract type MyPath end


struct AFolder <: MyPath
    function2path::Function
end

function AFolder(path::AbstractString)
    function2path(args...) = joinpath(path, args...)
    return AFolder(function2path)
end

struct AFile <: MyPath
    path::AbstractString
end
