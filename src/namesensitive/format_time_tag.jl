expr_ttag = r"(?<=\At)-?\d+"
"""
`format_time_tag` format time tag into LaTeX maths.

# Example
```julia
julia> format_time_tag(["t-1", "t-2", "t-3", "t-4"])
"t_{i=-4,-3,...,-1}"
```
"""
function format_time_tag(tagvec::Vector{<:AbstractString}; maxtag=3)
    tagvecd = broadcast(mt -> parse(Int,mt.match), match.(r"-?\+?\d+", tagvec))
    numorder = tagvecd |> sortperm
    convstr(num) = "$num"
    sortedvec_str = convstr.(tagvecd[numorder])
    lenv = length(sortedvec_str)
    if lenv == 1
        strf = sortedvec_str[1]

    elseif lenv == maxtag
        str2join = sortedvec_str
        str2join[2] = "..."
        strf = join(str2join, ",")

    elseif lenv > maxtag
        str2join = [sortedvec_str[1:2]..., "...", sortedvec_str[end]]
        strf = join(str2join, ",")
    else
        str2join = sortedvec_str
        strf = join(str2join, ",")
    end

    return "t_i, i=$strf"
end


"""
`split_time_tag(str)` split the feature name into variable name and the time-shift tag (which should be at the last).

# Example
```julia
julia> split_time_tag("Soil_water_content_10cm_t-24")
("Soil_water_content_10cm", "t-24")
```
"""
function split_time_tag(str::AbstractString)
    v = rsplit(str, "_";limit=2)
    ttag = v[end]
    @assert occursin(expr_ttag, ttag) "The last one ($ttag in $str) is not time tag (didn't match $(expr_ttag))"
    return (v...,)
end

# function split_time_tag(strvec::Vector{<:AbstractString})
#     lenv = length(strvec)
#     v1 = Vector{String}(undef, lenv)
#     v2 = Vector{String}(undef, lenv)
#     for (i, str) in enumerate(strvec)
#         v = split_time_tag(str)
#         v1[i] = v[1]
#         v2[i] = v[2]
#     end
#     return v1, v2
# end # this is just a little bit faster.

function split_time_tag(strvec::Vector{<:AbstractString})
    v1 = String[]
    v2 = String[]
    for str in strvec
        v = split_time_tag(str)
        push!(v1, v[1])
        push!(v2, v[2])
    end
    return v1, v2
end


"""
Given a string such as `str = a_certain_variable_name_t-3`, `parselag(str)` returns the  `-3`.
"""
function parselag(str)
    strv = split_time_tag(string(str))
    ttag = match(expr_ttag,strv[end]).match
    parse(Int, ttag)
end
