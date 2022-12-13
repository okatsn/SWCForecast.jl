mutable struct NamedMachine
    name
    machine
end

function SWCForecast.fit!(nm::NamedMachine;kwargs...)
    fit!(nm.machine;kwargs...)
end

function SWCForecast.report(nm::NamedMachine)
    rp = report(nm.machine)
    return (machine_name=nm.name, rp...)
end

function SWCForecast.fitted_params(nm::NamedMachine;kwargs...)
    ftpr = fitted_params(nm.machine;kwargs...)
    return ftpr
end
