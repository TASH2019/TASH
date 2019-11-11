#!/bin/csh

#Define list of subjects
source TASH_DefineSubjects
foreach subj ($SUBJECTS)
  echo $subj

  set outD = $SUBJECTS_DIR/$subj/Volume
  mkdir -p $outD
  mris_anatomical_stats -l $SUBJECTS_DIR/$subj/RestrictedFlatPatches/lh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1.label -f $outD/lh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1_label $subj lh
  mris_anatomical_stats -l $SUBJECTS_DIR/$subj/RestrictedFlatPatches/rh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1.label -f $outD/rh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1_label $subj rh

  setenv outD "$SUBJECTS_DIR/$subj/RestrictedFlatPatches/"
  tksurfer $subj lh inflated -curv -overlay $SUBJECTS_DIR/$subj/RestrictedFlatPatches/lh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1.w -fminmax 0.00001 30 -tcl TASH_SaveImage_lh.tcl
  tksurfer $subj rh inflated -curv -overlay $SUBJECTS_DIR/$subj/RestrictedFlatPatches/rh_masked_thr01_Complete_expandedLT_Complete_erosion_dilatation_2_1halfnew_g1.w -fminmax 0.00001 30 -tcl TASH_SaveImage_rh.tcl
end

