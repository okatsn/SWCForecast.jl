mutable struct NamedMachine
    name
    machine
end

function SWCForecast.fit!(nm::NamedMachine)
    fit!(nm.machine)
end

function SWCForecast.report(nm::NamedMachine)
    rp = report(nm.machine)
    return (machine_name=nm.name, rp...)
end
