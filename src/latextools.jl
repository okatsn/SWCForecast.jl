"""
`latextable(dftmp, MIME("text/latex"))` returns a very simple latex table that applies `MIME("text/latex")`.
Other `MIME` is of-coursely unsupported.
This method is experimental following [Mimes In Julia: What Are They?](https://medium.com/chifi-media/mimes-in-julia-what-are-they-d9af13c3ed96).
"""
function latextable(df::DataFrame,  m::MIME{Symbol("text/latex")})
	str = let
        df = formatcolumn(df);
		io = IOBuffer();
		show(io, MIME("text/latex"), df);
		str = String(take!(io))
	end
	return str
end

function latextable(dftmp::DataFrame)
    Mtmp = hcat([formatcolumn(col) for col in eachcol(dftmp)]...) # To matrix
    header = names(dftmp)
    printfn() = pretty_table(Mtmp, backend = Val(:latex), header = header)
    mstr = print2string(printfn)
end

"""
# Other Support:
```
ISFs = [InfoShiftedFeature(gf) for gf in group_feature(names(X0))]
latextable(ISFs::Vector{InfoShiftedFeature})
```

which is equivalent to
```julia
dftmp = DataFrame("feature name" => String[], "time shift" => String[])
for ISF1 in ISFs
    push!(dftmp, [ISF1.root, join(string.(ISF1.timeshift), " ,")])
end
latextable(dftmp::DataFrame)
```
"""
function latextable(ISFs::Vector{InfoShiftedFeature})
    latextable(DataFrame(ISFs))
end

"""
`latextable(manytables::Vector{Pair{String,DataFrame}})` is under construction.
Noted that
"""
function latextable(manytables::Vector{Pair{String,DataFrame}})
# TODO: merge multiple table as a multi-column latex table
# - split pretty_table (latextable) outputs into vectors # TODO: try linking list
# - write a function insert the \multicolumn row
# - you need to make the two table matched in their row name
#
# Here are single and multi-column latex table example:
# \section{Two-Columns Table}
# \begin{tabular}{r|ccc|cc}
# 	% \toprule
# 	            & \multicolumn{3}{c}{Group 1} & \multicolumn{2}{c}{Group 2}                                  \\
# 	            & (1)                         & (2)                         & (3)      & (4)      & (5)      \\ \hline
# 	(Intercept) & 19.978*                     & 15.809                      & 14.167   & 11.834   & 11.011   \\
# 	            & (11.688)                    & (11.084)                    & (11.519) & (8.535)  & (11.704) \\
# 	Raises      & 0.691***                    & 0.379*                      & 0.352    & -0.026   & -0.033   \\
# 	            & (0.179)                     & (0.217)                     & (0.224)  & (0.184)  & (0.202)  \\
# 	Learning    &                             & 0.432**                     & 0.394*   & 0.246    & 0.249    \\
# 	            &                             & (0.193)                     & (0.204)  & (0.154)  & (0.160)  \\
# 	Privileges  &                             &                             & 0.105    & -0.103   & -0.104   \\
# 	            &                             &                             & (0.168)  & (0.132)  & (0.135)  \\
# 	Complaints  &                             &                             &          & 0.691*** & 0.692*** \\
# 	            &                             &                             &          & (0.146)  & (0.149)  \\
# 	Critical    &                             &                             &          &          & 0.015    \\
# 	            &                             &                             &          &          & (0.147)  \\ \hline
# 	N           & 30                          & 30                          & 30       & 30       & 30       \\
# 	$R^2$       & 0.348                       & 0.451                       & 0.459    & 0.715    & 0.715    \\
# 	% \bottomrule
# \end{tabular}
#
# \section{Single-Column Table}
# \begin{table}
# 	\begin{tabular}{rr}
# 		\multicolumn{2}{c}{input features}                                                     \\
# 		\hline\hline
# 		\textbf{feature name}      & \textbf{time shift}                                       \\\hline
# 		\text{hour}                & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{air\_temperature}    & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation}       & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation\_1hr}  & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation\_12hr} & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation\_1d}   & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation\_2d}   & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{precipitation\_3d}   & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{pressure\_CWB}       & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\
# 		\text{humidity\_CWB}       & \text{0 ,-2 ,-4 ,-6 ,-12 ,-18 ,-24 ,-48 ,-72 ,-144 ,-288} \\\hline\hline
# 	\end{tabular}
# \end{table}

    manytables = ["Input Features" => dffeat, "Target Features" => dftarg]

end

"""
Format `DataFrame`'s column if the element type belongs `AbstractString`:
- add "\\text{}"
- add "\\" to any dash (`"_" => "\\_"`) to prevent error in the LaTeX building stage
"""
function formatcolumn(df::DataFrame)
    select(dftmp, All() .=> formatcolumn; renamecols=false)
end


function formatcolumn(col::Vector{<:AbstractString})
    col = replace.(col, r"\_" => "\\_") # underline is illegal in latex.
    "\\text{".*col.*"}" # it is safe since \textbf{\text{blabla}} is fine
end

function formatcolumn(col::Vector{<:Any})
    col
end
