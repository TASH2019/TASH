clear all
[sub, Dir, Dsave] = TASH_DefineSubjects;
side='lh';
TASH_curv(side,Dir);
TASH_opening(side,Dir);
TASH_threshold(side,Dir);
TASH_grow(side,Dir);
TASH_cluster(side,Dir);
side='rh';
TASH_curv(side,Dir);
TASH_opening(side,Dir);
TASH_threshold(side,Dir);
TASH_grow(side,Dir);
TASH_cluster(side,Dir);