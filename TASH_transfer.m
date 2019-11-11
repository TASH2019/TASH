function TASH_transfer(side,Dir,Dsave)

subjectsID = TASH_DefineSubjects;
D_save = fullfile(Dsave,side);
if ~isdir(D_save)
    mkdir(D_save);
end
    
for isub = 1:length(subjectsID) 
    try
    D_load = fullfile(Dir,subjectsID{isub},'RestrictedFlatPatches');
    fname = fullfile(D_load,['HG_',side,'_g1.tif'])
    fname2 = fullfile(D_save,['HG_',side,'_g1_', subjectsID{isub}, '.tif']) 
    copyfile(fname,fname2)
    catch
    end
end