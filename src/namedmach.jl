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
