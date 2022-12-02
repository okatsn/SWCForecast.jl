"""
# Example
```
featstrs = [v for v in values(dmachs)][1][1].mach.data[1] |> names
ISFs = [InfoShiftedFeature(gf) for gf in group_feature(rmprefix.(featstrs))]
```
"""
mutable struct InfoShiftedFeature
    strs::Vector
    root
    root_display_code::String
    suffix::Vector
    timeshift::Vector{Int}
    ts_display::String
    ts_display_codes::Vector
    function InfoShiftedFeature(strs)
        rsp = rsplit.(strs, "_"; limit=2)
        root = first.(rsp) |> unique |> only
        suffix = last.(rsp)
        timeshift = getnum.(suffix)
        root_display_code = add_code_fence_inline(root)
        ts_display_codes = add_code_fence_inline.(suffix)
        ts_display = format_time_tag(suffix)
        new(strs,
            root,
            root_display_code,
            suffix,
            timeshift,
            ts_display,
            ts_display_codes)
    end
end
