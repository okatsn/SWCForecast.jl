# Name-sensitive functions

!!! note 
    If error occurred in this page, try the followings in your local machine:
    ```julia
    makedocs(root=joinpath(dirname(pathof(SWCForecast)), "..", "docs"), sitename="TEMP")
    ```

```@autodocs
Modules = [SWCForecast]
Order   = [:function, :type]
using FileTools, SWCForecast
Pages = filelist(r".+\.jl", joinpath(dirname(pathof(SWCForecast)),"namesensitive"); join=false)
```
