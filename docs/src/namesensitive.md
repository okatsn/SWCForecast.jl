# Name-sensitive functions

```@example
using FileTools, SWCForecast
flist = filelist(r".+\.jl", joinpath(dirname(pathof(SWCForecast)),"namesensitive"); join=false)
show(flist[2])
```

!!! note 
    If error occurred in this page, try the followings in your local machine:
    ```julia
    makedocs(root=joinpath(dirname(pathof(SWCForecast)), "..", "docs"), sitename="TEMP")
    ```

```@autodocs
Modules = [SWCForecast]
Order   = [:function, :type]
using FileTools, SWCForecast
flist = filelist(r".+\.jl", joinpath(dirname(pathof(SWCForecast)),"namesensitive"); join=false)
Pages = flist
```
