function sh5_assemblesq(sensor, basename, tag, itmin, dit, itmax, split)

for it=itmin:dit:itmax

    dirpath = sensor;
    % Remove sensor tag
    idx=strfind(dirpath,'/');
    if ~isempty(idx);
        dirpath = dirpath(1:idx(end));
    end
    
    % UNTAR
    tarname = [sensor basename 'i' int2str(it) '.tar'];
    untar(tarname, ['./' dirpath]);
    
    % ASSEMBLE
    sh5_assemble(sensor, basename, tag, it, split);
    
    % DELETE
    delete([sensor basename 'i' int2str(it) '_*']);
    delete(tarname);
    
    fprintf('Processed it = %i\n',it);
end
