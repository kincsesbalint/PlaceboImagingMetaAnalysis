function v=v_masked_BK(nii_imgs,maskpath)
% Wrapper function used to reduce code in A1_Select_All_and_Conservative
% when loading nii images as brain-masked vectors.

if nargin<2
  maskpath = 'C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks';
end

v=nii2vector(nii_imgs,fullfile(maskpath,'brainmask_logical_50.nii')); % brainmask thresholded at a cut-off of 50% brain tissue probability