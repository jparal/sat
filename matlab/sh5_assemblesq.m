function data = sh5_assemblesq(sensor, basename, tag, itmin, dit, itmax, split, comps)

for it=itmin:dit:itmax
    if
    sh5_assemble(sensor, basename, tag, it, split)
end
