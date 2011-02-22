function sh5_assemblesq(sensor, basename, tag, itmin, dit, itmax, split)

for it=itmin:dit:itmax
    sh5_assemble(sensor, basename, tag, it, split);
end
