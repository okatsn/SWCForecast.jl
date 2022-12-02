function feature_summary(DDT::DescriptDecisionTree)
    DDTdescript = DDT.description
    feats0 = DDTdescript["Model"]["features"]
    targs0 = DDTdescript["Model"]["targets"]
    return feature_summary(feats0, targs0)
end

"""
# Example
```julia
DDTdescript = readdescription(path2toml)
feats0 = DDTdescript["Model"]["features"]
targs0 = DDTdescript["Model"]["targets"]
list_features, list_targets = feature_summary(feats0, targs0)

```
"""
function feature_summary(feats0, targs0)
    list_features = feature_summary(feats0)
    list_targets = join(broadcast(x -> "- `\""*x*"\"`", targs0), " \n ")

    return list_features, list_targets
end

"""
```julia
feats0 = [
"pressure_CWB_t0" ,
"pressure_CWB_t-2" ,
"pressure_CWB_t-4" ,
"pressure_CWB_t-6" ,
"pressure_CWB_t-12" ,
"humidity_CWB_t0" ,
"humidity_CWB_t-2" ,
"humidity_CWB_t-4" ,
"humidity_CWB_t-6" ,
"humidity_CWB_t-12" ,
]
```

```julia-repl
julia> feature_summary(feats0)
"- pressure CWB (\$t_i, i=-12,-6,...,0\$; total 5 variables) \n - humidity CWB (\$t_i, i=-12,-6,...,0\$; total 5 variables)"
```

"""
function feature_summary(feats0)
    list_features0, list_ttagsummary = reduce_feature(feats0)
    features_summ = replace.(list_features0, "_" => " ") .* list_ttagsummary

    list_features = list_features = join(broadcast(x -> "- "*x, features_summ), " \n ")
    return list_features
end

"""
`reduce_feature(feats0)` returns unique feature names and time tags that are split by `split_time_tag`.

"""
function reduce_feature(feats0; maxtag = 3)
    featnms, ttags = split_time_tag(string.(feats0))
    list_features0 = String[]
    list_ttagsummary = String[]
    for fnm in unique(featnms)
        push!(list_features0, fnm)


        tagvec = ttags[fnm .== featnms]
        tags_abbr = format_time_tag(tagvec; maxtag = maxtag)
        lentag = length(tagvec)

        ttagsum = " ("*"\$$tags_abbr\$"*"; total $lentag variables)"
        push!(list_ttagsummary, ttagsum)
    end

    return list_features0, list_ttagsummary
end

"""
Given a vector of string `str0` with each element being like `"r_o_o_t_suffix"`, `group_feature(str0)` returns an Iterator with each a subgroup of elements having the same root.
"""
function group_feature(str0)
    (map((x,y) -> join([x,y], "_"), roots, suffixes) for (roots, suffixes) in _group_feature(str0))
end

"""
Given a vector of string `str0` with each element being like `"r_o_o_t_suffix"`, `SWCForecast._group_feature(str0)` returns the vector of `(root_string, suffix_string)`.
"""
function _group_feature(str0)
    featnms, ttags = SWCForecast.split_time_tag(string.(str0))
    dffstr = DataFrame(:root => featnms, :suffix => ttags)
    dfg = groupby(dffstr, :root)

    return [(df.root, df.suffix) for df in dfg]
end

add_code_fence_inline(str) = "`$str`"
getnum(str) = match(r"(\+|\-)?\d+", str).match |> str -> parse(Int, str)


function SWCForecast.DataFrame(ISFs::Vector{InfoShiftedFeature})
    dftmp = DataFrame("feature name" => String[], "time shift" => String[])
    for ISF1 in ISFs
        push!(dftmp, [ISF1.root, join(string.(ISF1.timeshift), " ,")])
    end
    return dftmp
end

function SWCForecast.show(io::IO, ISF::InfoShiftedFeature)
    mdp = Markdown.parse("""
    $(ISF.root_display_code) at \$$(ISF.ts_display)\$
    - Root: $(ISF.root_display_code)
    - Time shifts: $(ISF.timeshift)
    """);
    show(io, mdp)


end

function SWCForecast.display(ISFs::Vector{InfoShiftedFeature}; saveto="")
    md0 = Markdown.parse("""
    # Input features
    $(join([ISF.root_display_code for ISF in ISFs], ", ", " and "))

    # Detail

    """);

    for ISF in ISFs
        merge!(md0,Markdown.parse("- $(ISF.root_display_code) with time shift $(ISF.timeshift)"))
    end

    Base.display(md0)

    if !isempty(saveto)
        open(saveto, "w") do f
            print(f, md0)
        end
    end
    return md0
end

rmprefix(str) = last(split(str, "_"; limit=2))

function quicksave(md0::Markdown.MD; saveto = "temp.md")
    open(saveto, "w") do f
        print(f, md0)
    end
end
