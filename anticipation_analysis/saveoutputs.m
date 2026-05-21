function saveoutputs(imgstruct,outfoldpath,filenm,dfv_maskedpth)
imgstruct=onlycorperm_anticip;%correlationincluded_pain_badperm; onlycorperm_pain
outfold='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\';
outputpath= [ outfold 'pain\rndm\' ];%'anticipation\anticip_cor_behav_datacoll2021' painstimulus\placebo-behav_corr-dc2021\goodperm
mask_path='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\brainmask_logical_50.nii';
load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked'); %'vectorized_images_full_masked_10_percent.mat' 'vectorized_images_full_anticip_masked_10_percent_anticip'
% save the z_smoothed version of the "parametric" r-values
printImage_BK(imgstruct.r_external.random.z_smooth*(-1),mask_path,dfv_masked,[outputpath '\anticip_zsmth_param_reversed_dc2021'])
% save the z_smoothed version of the non-parametric r-values - I hsould
% boost this with the pTFCE
pmap=imgstruct.rpermres.permmap_smaller/100;
pmap(pmap==0)=1/5000;
pmap(pmap==1)=1-1/5000;
zmap=norminv(pmap);
printImage_BK(zmap,mask_path,dfv_masked,[outputpath '\pain_r_zsmthNONparam_smaller_dc2021'])
%boost with pTFCE and use the following values for thresholding
prctile(imgstruct.rpermres.max,95) % 4.3790
prctile(imgstruct.rpermres.min,5) % -4.3598


% save the results
%save out the uncorrected z-stats image
% load the correclty permuted repetition of the analysis
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\permutationbad_20study_gpu.mat');
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\ppermutationgood_20study_gpu_xtrameasures.mat');
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\permutationgood_26study_gpu.mat');
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\pain_26study_corr.mat');
% % imgsturct=wronlgyperformedperm_datacoll2015;
% % imgsturct=datacoll2015_corrpermgpu;
%  imgsturct=goodperm_datacoll2015;
%  imgsturct=anticipationres;
% % imgsturct=maki;
% outfold='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\zz_mainoutputimgs\';
% % outputpath= [ outfold 'painstimulus\placebo-behav_corr-dc2021'];
% % outputpath= [ outfold 'anticipation\anticip_placebo-control_datacoll2021'];
% outputpath= [ outfold 'anticipation\anticip_cor_behav_datacoll2021'];
% mask_path='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\brainmask_logical_50.nii';
% % load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
% load(fullfile(intermedpath,'vectorized_images_full_anticip_masked_10_percent_anticip.mat'),'dfv_masked');
% % this is the same image as in the publication uncorrected image in Fig2.A
% % That is the standardize effect values are smaller/larger than 2.58(so
% % p<0.01) (BUT the script what Tamas sent was with a threshold of 2.3(which
% % is a bit different...)
% % in MZ's results, one can find as Full_pla_g_z
% printImage_BK(imgsturct.g.random.z,mask_path,dfv_masked,[outputpath '\full_antic_g_z_dc2021'])
% % the same thing from the permutation, uncorrected version:
% pmap=imgsturct.rpermres.permmap_larger/100;
% % pmap=anticipationres.permmap_larger_rndtsmooth/100;
% pmap(pmap==0)=1/5000;
% pmap(pmap==1)=1-1/5000;
% zmap=norminv(pmap);
% printImage_BK(zmap,mask_path,dfv_masked,[outputpath '\pain_cor_permZ_larger_dc2021'])
% 
% % run the ptfce in R,using the saved mask from previous step(found in
% % PICO/C_calculations/D_results/full_masked_10_percent.nii result of B_mask
% % missing voxels function)
% % important: we can only use the ptfce to run one sided tets,so we need to
% % invert the negative image(eg: fslmath -1 multiplication) before we feed
% % into R OR we use the permmap smaller image, as it is already inverted...
% 
% %FDR correction based on the percentile values:
% %use these values to threshold the pTFCE boosted images.
% prctile(imgsturct.rpermres.max,95)
% prctile(imgsturct.rpermres.min,5)
% 
% % create FDR correction on the boosted images
% zstat.ptfce_pos=spm_vol('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\zz_mainoutputimgs\anticipation\anticip_placebo-control_datacoll2021\full_anticip_z_perm_ptfce_pos.nii');
% zstat.ptfce_neg=spm_vol('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles_anticip\zz_mainoutputimgs\anticipation\anticip_placebo-control_datacoll2021\full_anticip_z_perm_ptfce_neg.nii');
% 
% 
% %%%%%%%%%%%%%%
% %%% Fig2.B
% %%%%%%%%%%%%%%
% printImage_BK(datacoll2015_corrpermgpu.g.random.summary,mask_path,dfv_masked,[outputpath '\full_pla_g_summary_BK'])
% %%%%%%%%%%%%%%
% %%% mask images based on 
% % uncorrected (for multiple comparison) permuted p values
% %%% higher
% uncorphigher=(imgsturct.permmap_larger_rndtsmooth>97.5);
% printImage_BK(imgsturct.g.random.summary.*uncorphigher,mask_path,dfv_masked,[outputpath '\uncorrp_5perc_higher']);
% %%% lower
% uncorplower=(imgsturct.permmap_smaller_rndtsmooth>97.5);
% printImage_BK(imgsturct.g.random.summary.*uncorplower,mask_path,dfv_masked,[outputpath '\uncorrp_5perc_lower']);
% % corrected for multiple comparison (maximum z-stat approach) - FWER
% % we do have the zmax and zmin
% 
% %%% higher
% corphigher=(imgsturct.fwecor_permmap_larger_rndtsmooth>97.5);
% printImage_BK(imgsturct.g.random.summary.*corphigher,mask_path,dfv_masked,[outputpath '\corrp_5perc_higher_badperm']);
% %%% lower
% corplower=(imgsturct.fwecor_permmap_smaller_rndtsmooth>97.5);
% printImage_BK(imgsturct.g.random.summary.*corplower,mask_path,dfv_masked,[outputpath '\corrp_5perc_lower_badperm']);
% 
% % create a z map based on the uncorrected pvals(based on the distribution)
% % which we can use it in the ptfce r script.
% 
% zstat.pos=imgsturct.permmap_larger_rndtsmooth/100;
% zstat.pos(zstat.pos==0)=1/5000;
% zstat.pos(zstat.pos==1)=1-1/5000;
% zstat.pos=norminv(zstat.pos);
% printImage_BK(zstat.pos,mask_path,dfv_masked,[outputpath '\zstat_beforeptfce_pos_badperm']);
% 
% zstat.neg=imgsturct.permmap_smaller_rndtsmooth/100;
% zstat.neg(zstat.neg==0)=1/5000;
% zstat.neg(zstat.neg==1)=1-1/5000;
% zstat.neg=norminv(zstat.neg);
% printImage_BK(zstat.neg,mask_path,dfv_masked,[outputpath '\zstat_beforeptfce_neg_badperm']);
% 
% % run the ptfce in R,using the saved mask from previous step(found in
% % PICO/C_calculations/D_results/full_masked_10_percent.nii result of B_mask
% % missing voxels function)
% % important: we can only use the ptfce to run one sided tets,so we need to
% % invert the negative image(eg: fslmath -1 multiplication) before we feed into R
% 
% %create the fwe corrected images based on the save zmax and zmin stats.
% zstat.ptfce_pos=spm_vol('C:/Users/lenov/Documents/PICO_DATA/originaldatastructure/intermediatefiles_anticip/zz_mainoutputimgs/painstimulus/placebo-control_datacoll2015_badperm/zstat_afterptfce_pos_badperm.nii');
% zstat.ptfce_neg=spm_vol('C:/Users/lenov/Documents/PICO_DATA/originaldatastructure/intermediatefiles_anticip/zz_mainoutputimgs/painstimulus/placebo-control_datacoll2015_badperm/zstat_afterptfce_neg_badperm.nii');
% 
% inputfile=zstat.ptfce_pos;
% outimg=spm_read_vols(inputfile);
% outpvalimg=outimg;
% [ii jj kk]=size(outimg);
% for i=1:ii
%     for j=1:jj
%         for k=1:kk
%             outpvalimg(i,j,k)=1-sum(outimg(i,j,k)<imgsturct.zmax)/5000;
% %             outpvalimg(i,j,k)=1-sum(outimg(i,j,k)<(imgsturct.zmin*(-1)))/5000;
%         end
%     end
% end
% outheader=inputfile;
% outheader.fname='C:/Users/lenov/Documents/PICO_DATA/originaldatastructure/intermediatefiles_anticip/zz_mainoutputimgs/painstimulus/placebo-control_datacoll2015_badperm/pvals_afterptfce_fwe_pos.nii';
% spm_write_vol(outheader,outpvalimg)

