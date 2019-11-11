# zone33: G_temp_sup-G_T_transv -> lh.G_temp_sup-G_T_transv.label  
# zone36: G_temp_sup-Plan_tempo -> lh.G_temp_sup-Plan_tempo.label
# zone74: S_temporal_transverse -> lh.S_temporal_transverse.label
# zone35: G_temp_sup-Plan_polar -> lh.G_temp_sup-Plan_polar.label
# zone48: S_circular_insula_inf -> lh.S_circular_insula_inf.label

source TASH_DefineSubjects
foreach subj ($SUBJECTS)
  echo $subj
  set labeldir = $SUBJECTS_DIR/$subj/label/labelsAtlas2009
  mkdir -p $labeldir
  set surfdir = $SUBJECTS_DIR/$subj/surf

  set annotationfile = aparc.a2009s
  set cmd = (mri_annotation2label --annotation $annotationfile --subject $subj --hemi lh --outdir $labeldir)
  echo $cmd
  eval $cmd

  set extendedROI = lh.AC.extended.label
  set cmd = (mri_mergelabels -i $labeldir/lh.G_temp_sup-G_T_transv.label -i $labeldir/lh.G_temp_sup-Plan_tempo.label -i $labeldir/lh.S_temporal_transverse.label -i $labeldir/lh.S_circular_insula_inf.label -o $labeldir/$extendedROI)
  echo $cmd
  eval $cmd
  set expansionROI = lh.expansion.label
  set cmd = (mri_mergelabels -i $labeldir/lh.G_temp_sup-G_T_transv.label -i $labeldir/lh.G_temp_sup-Plan_tempo.label -i $labeldir/lh.S_temporal_transverse.label -i $labeldir/lh.Lat_Fis-post.label -i $labeldir/lh.S_circular_insula_inf.label -i $labeldir/lh.G_temp_sup-Plan_polar.label -o $labeldir/$expansionROI)
  echo $cmd
  eval $cmd

  set labelfile = lh.AC.extended.label
  set patchfile = lh.AC.extended.patch
  set cmd = (label2patch $subj lh $labeldir/$labelfile $surfdir/$patchfile)
  echo $cmd
  eval $cmd

  set patchfile = lh.AC.extended.patch
  set flatten_patchfile = lh.AC.extended.flat.patch
  set cmd = (mris_flatten -w 100 $surfdir/$patchfile $surfdir/$flatten_patchfile)
  echo $cmd
  eval $cmd

  mris_convert -p $surfdir/lh.AC.extended.flat.patch $surfdir/lh.AC.extended.flat.patch.asc

end

foreach subj ($SUBJECTS)
  echo $subj
  set labeldir = $SUBJECTS_DIR/$subj/label/labelsAtlas2009
  mkdir -p $labeldir
  set surfdir = $SUBJECTS_DIR/$subj/surf

  set annotationfile = aparc.a2009s
  set cmd = (mri_annotation2label --annotation $annotationfile --subject $subj --hemi rh --outdir $labeldir)
  echo $cmd
  eval $cmd

  set extendedROI = rh.AC.extended.label
  set cmd = (mri_mergelabels -i $labeldir/rh.G_temp_sup-G_T_transv.label -i $labeldir/rh.G_temp_sup-Plan_tempo.label -i $labeldir/rh.S_temporal_transverse.label -i $labeldir/rh.S_circular_insula_inf.label -o $labeldir/$extendedROI)
  echo $cmd
  eval $cmd
  set expansionROI = rh.expansion.label
  set cmd = (mri_mergelabels -i $labeldir/rh.G_temp_sup-G_T_transv.label -i $labeldir/rh.G_temp_sup-Plan_tempo.label -i $labeldir/rh.S_temporal_transverse.label -i $labeldir/rh.Lat_Fis-post.label -i $labeldir/rh.S_circular_insula_inf.label -i $labeldir/rh.G_temp_sup-Plan_polar.label -o $labeldir/$expansionROI)
  echo $cmd
  eval $cmd

  set labelfile = rh.AC.extended.label
  set patchfile = rh.AC.extended.patch
  set cmd = (label2patch $subj rh $labeldir/$labelfile $surfdir/$patchfile)
  echo $cmd
  eval $cmd

  set patchfile = rh.AC.extended.patch
  set flatten_patchfile = rh.AC.extended.flat.patch
  set cmd = (mris_flatten -w 100 $surfdir/$patchfile $surfdir/$flatten_patchfile)
  echo $cmd
  eval $cmd

  mris_convert -p $SUBJECTS_DIR/$subj/surf/rh.AC.extended.flat.patch $SUBJECTS_DIR/$subj/surf/rh.AC.extended.flat.patch.asc

end