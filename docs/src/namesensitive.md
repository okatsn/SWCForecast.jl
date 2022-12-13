```@meta
CurrentModule = SWCForecast
```

!!! note 
    If error occurred in this page, try the followings in your local machine:
    ```julia
    makedocs(root=joinpath(dirname(pathof(SWCForecast)), "..", "docs"), sitename="TEMP")
    ```
# Functions by topics
## Name-sensitive functions

```@autodocs
Modules = [SWCForecast]
Order   = [:function, :type]
using FileTools, SWCForecast
Pages = filelist(r".+\.jl", joinpath(dirname(pathof(SWCForecast)),"namesensitive"); join=false)
```

## Data processing

```@autodocs
Modules = [SWCForecast]
Order   = [:function, :type]
using FileTools, SWCForecast
Pages = filelist(r".+\.jl", joinpath(dirname(pathof(SWCForecast)),"dataprocessing"); join=false)
```

## Miscellaneous functions
These are functions under `SWCForecast/src/`
```@autodocs
Modules = [SWCForecast]
Order   = [:function, :type]
using FileTools, SWCForecast
Pages = basename.(filelistall(r".+\.jl", joinpath(dirname(pathof(SWCForecast)))))
```
