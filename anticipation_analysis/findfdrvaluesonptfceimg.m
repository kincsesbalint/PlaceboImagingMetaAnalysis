% Here we aim to load the ptfce boosted images and convert the z-values
% into p-values. After that, run FDR correction and use the image for
% running a design comparison.

pathtoimg='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\pain\rndm\pain_diff_rndm_pos_ptfce.nii.gz';
img_header=spm_vol(pathtoimg);
img_pos=spm_read_vols(img_header);

pathtoimg='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\pain\rndm\pain_diff_rndm_neg_ptfce.nii.gz';
img_header=spm_vol(pathtoimg);
img_neg=spm_read_vols(img_header);

img_pos=img_pos(:)';
img_neg=img_neg(:)';


img_pos=img_pos(dfv_masked.pain_brainmask3d(:)==1);
img_neg=img_neg(dfv_masked.pain_brainmask3d(:)==1);

img=img_pos;



img(pain_diffcontr.g.random.z_smooth<0)=img_neg(pain_diffcontr.g.random.z_smooth<0)*(-1);
printImage_BK(img,mask_path,dfv_masked,[outputpath '\pain_diff_rndm_ptfce'])