[sub, Dir, Dsave] = TASH_DefineSubjects;
[lh,rh]=TASH_Measures(Dir)
fname = fullfile(Dsave,['TASH_measures.mat'])
save(fname,'lh','rh')
side='lh';
TASH_transfer(side,Dir,Dsave);
side='rh';
TASH_transfer(side,Dir,Dsave);