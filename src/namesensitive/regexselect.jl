"""
Given `df` and `rselector`, `namesx(df::DataFrame,rselector::Vector{Regex})` returns non-repeat names matching either pattern.
"""
function namesx(df::DataFrame,rselector::Vector{Regex})
    return union([names(df, rs) for rs in rselector]...)
end
