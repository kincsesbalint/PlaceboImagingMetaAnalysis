function C_visualizationofresults(intermedpath,dfv_masked,varargin)
    individualfile=uigetfile(intermedpath);
    [~,filename,~]=fileparts(individualfile);
    fprintf("We loaded the following file:%s\n",filename)
    fileinfos=strsplit(filename,'_');
%     if strcmp(fileinfos{2},"both")
%         load(fullfile(intermedpath,'zz_WB_res_phasediff',individualfile))
%     else
        load(fullfile(intermedpath,individualfile));
%     end

    %load dfv_masked structure
%     dfv_maskedpth='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent.mat';
%     load(dfv_maskedpth)
    %load mask
    %todo save the mask in the intermediate folder to use it later
    mask_path='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\';
    maskfile=fullfile(mask_path,'brainmask_logical_50.nii');
    %create output folder
    outfold='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\'; %zz_imgs_maki
    outputpath= fullfile( outfold ,fileinfos{2});%'anticipation\anticip_cor_behav_datacoll2021' painstimulus\placebo-behav_corr-dc2021\goodperm
    mkdir(outputpath)
    %we would need for each condition and each phase all the output images
    
    if strcmp(fileinfos{4},"diff") && ~(strcmp(fileinfos{2},"both")) && ~(strcmp(fileinfos{end},'putamencorrnperm0')) && ~(strcmp(fileinfos{6},'quadraticmodelestimation'))
        forvis.data{1}=summaryy.g.random.z;
        forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_pos');
        forvis.data{2}=summaryy.g.random.z*(-1);
        forvis.outputfile{2}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_neg');
        fprintf("The two-sided FWER threshold for effect size(g):%f\n", ...
            prctile(max([summaryy.permres.g.rnd.zmaxvals; -summaryy.permres.g.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(g):%f\n", ...
            prctile(summaryy.permres.g.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(g):%f\n", ...
            prctile(-summaryy.permres.g.rnd.zminvals,95))

        forvis.data{3}=summaryy.r_external.random.z;
        forvis.outputfile{3}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_pos');
        forvis.data{4}=summaryy.r_external.random.z*(-1);
        forvis.outputfile{4}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_neg');
        fprintf("The FWER threshold for correlation(r):%f\n", ...
            prctile(max([summaryy.permres.r_external.rnd.zmaxvals; -summaryy.permres.r_external.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(r):%f\n", ...
            prctile(summaryy.permres.r_external.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(r):%f\n", ...
            prctile(-summaryy.permres.r_external.rnd.zminvals,95))
%         fprintf("The FWER threshold for correlation(r):%f\n", ...
%             prctile(max([summaryy.permres.r_external.rnd.zmaxvals; -summaryy.permres.r_external.rnd.zminvals]),95))
%         fprintf("The one-sided (positive) FWER threshold for effect size(r):%f\n", ...
%             prctile(summaryy.permres.r_external.rnd.zmaxvals,95))
%         fprintf("The one-sided (negative) FWER threshold for effect size(r):%f\n", ...
%             prctile(-summaryy.permres.r_external.rnd.zminvals,95))

        [summaryy.r_external.fixed,...
         summaryy.r_external.random,...
         summaryy.r_external.heterogeneity]=GIV_weight_fishersZ2r(summaryy.r_external.fixed,...
                                                summaryy.r_external.random,...
                                                summaryy.r_external.heterogeneity);
        forvis.data{5}=summaryy.g.random.summary;
        forvis.outputfile{5}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_effect_rnd_pos');
        forvis.data{6}=summaryy.g.random.summary*(-1);
        forvis.outputfile{6}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_effect_rnd_neg');

        forvis.data{7}=summaryy.r_external.random.summary;
        forvis.outputfile{7}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_effect_rnd_pos');
        forvis.data{8}=summaryy.r_external.random.summary*(-1);
        forvis.outputfile{8}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_effect_rnd_neg');

        forvis.data{9}=summaryy.g.heterogeneity.tausq;
        forvis.outputfile{9}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_tausq');
        forvis.data{10}=summaryy.g.heterogeneity.Isq;
        forvis.outputfile{10}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_Isq');
        
        forvis.data{11}=summaryy.r_external.heterogeneity.tausq;
        forvis.outputfile{11}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_tausq');
        forvis.data{12}=summaryy.r_external.heterogeneity.Isq;
        forvis.outputfile{12}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_Isq');

    elseif strcmp(fileinfos{4},"sum") && ~(strcmp(fileinfos{2},"both")) && ~(strcmp(fileinfos{end},'putamencorrnperm0')) && ~(strcmp(fileinfos{6},'quadraticmodelestimation'))
        forvis.data{1}=summaryy.g.random.z;
        forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_pos');
        forvis.data{2}=summaryy.g.random.z*(-1);
        forvis.outputfile{2}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_neg');
        fprintf("The FWER threshold for effect size(g):%f\n", ...
            prctile(max([summaryy.permres.g.rnd.zmaxvals; -summaryy.permres.g.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(g):%f\n", ...
            prctile(summaryy.permres.g.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(g):%f\n", ...
            prctile(-summaryy.permres.g.rnd.zminvals,95))

        forvis.data{3}=summaryy.r_external.random.z;
        forvis.outputfile{3}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_pos');
        forvis.data{4}=summaryy.r_external.random.z*(-1);
        forvis.outputfile{4}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_neg');
        fprintf("The FWER threshold for correlation(r):%f\n", ...
            prctile(max([summaryy.permres.r_external.rnd.zmaxvals; -summaryy.permres.r_external.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(r):%f\n", ...
            prctile(summaryy.permres.r_external.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(r):%f\n", ...
            prctile(-summaryy.permres.r_external.rnd.zminvals,95))
        
        forvis.data{5}=summaryy.g.random.summary;
        forvis.outputfile{5}=strcat(fileinfos{2},'_',fileinfos{4} ,'_effect_rnd_pos');
        forvis.data{6}=summaryy.g.random.summary*(-1);
        forvis.outputfile{6}=strcat(fileinfos{2},'_',fileinfos{4} ,'_effect_rnd_neg');

        forvis.data{7}=summaryy.g.heterogeneity.tausq;
        forvis.outputfile{7}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_tausq');
        forvis.data{8}=summaryy.g.heterogeneity.Isq;
        forvis.outputfile{8}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_Isq');
        
%         forvis.data{6}=summaryy.g.random.summary*(-1);
%         forvis.outputfile{6}=strcat(fileinfos{2},'_',fileinfos{4} ,'_effect_rnd_neg');


    elseif strcmp(fileinfos{2},"both") && ~(strcmp(fileinfos{end},'putamencorrnperm0')) && ~(strcmp(fileinfos{6},'quadraticmodelestimation'))
        forvis.data{1}=summaryy.g.random.z;
        forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_pos');
        forvis.data{2}=summaryy.g.random.z*(-1);
        forvis.outputfile{2}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_rnd_neg');
        fprintf("The two-sided FWER threshold for effect size(g):%f\n", ...
            prctile(max([summaryy.permres.g.rnd.zmaxvals; -summaryy.permres.g.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(g):%f\n", ...
            prctile(summaryy.permres.g.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(g):%f\n", ...
            prctile(-summaryy.permres.g.rnd.zminvals,95))

        forvis.data{3}=summaryy.r_external.random.z;
        forvis.outputfile{3}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_pos');
        forvis.data{4}=summaryy.r_external.random.z*(-1);
        forvis.outputfile{4}=strcat(fileinfos{2},'_',fileinfos{4}, '_r_rnd_neg');
        fprintf("The FWER threshold for correlation(r):%f\n", ...
            prctile(max([summaryy.permres.r_external.rnd.zmaxvals; -summaryy.permres.r_external.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(r):%f\n", ...
            prctile(summaryy.permres.r_external.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(r):%f\n", ...
            prctile(-summaryy.permres.r_external.rnd.zminvals,95))


        forvis.data{5}=summaryy.g.heterogeneity.tausq;
        forvis.outputfile{5}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_tausq');
        forvis.data{6}=summaryy.g.heterogeneity.Isq;
        forvis.outputfile{6}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_Isq');
        
        forvis.data{7}=summaryy.r_external.heterogeneity.tausq;
        forvis.outputfile{7}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_tausq');
        forvis.data{8}=summaryy.r_external.heterogeneity.Isq;
        forvis.outputfile{8}=strcat(fileinfos{2},'_',fileinfos{4} ,'_r_Isq');


    elseif strcmp(fileinfos{end},'putamencorrnperm0')
        forvis.data{1}=summaryy.r_external.random.z;
        forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4}, 'anticputamen_r_rnd_pos');
        forvis.data{2}=summaryy.r_external.random.z*(-1);
        forvis.outputfile{2}=strcat(fileinfos{2},'_',fileinfos{4}, 'anticputamen_r_rnd_neg');

        forvis.data{3}=summaryy.ab_stand.random.z;
        forvis.outputfile{3}=strcat(fileinfos{2},'_',fileinfos{4}, 'anticputamen_ab_rnd_pos');
        forvis.data{4}=summaryy.ab_stand.random.z*(-1);
        forvis.outputfile{4}=strcat(fileinfos{2},'_',fileinfos{4}, 'anticputamen_ab_rnd_neg');
    elseif strcmp(fileinfos{6},'quadraticmodelestimation')
        forvis.data{1}=summaryy.r_external.random.z;
        forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4}, 'quadraticmodelestimation_r_rnd_pos');
        forvis.data{2}=summaryy.r_external.random.z*(-1);
        forvis.outputfile{2}=strcat(fileinfos{2},'_',fileinfos{4}, 'quadraticmodelestimation_r_rnd_neg');
        fprintf("The FWER threshold for correlation(r):%f\n", ...
            prctile(max([summaryy.permres.r_external.rnd.zmaxvals; -summaryy.permres.r_external.rnd.zminvals]),95))
        fprintf("The one-sided (positive) FWER threshold for effect size(r):%f\n", ...
            prctile(summaryy.permres.r_external.rnd.zmaxvals,95))
        fprintf("The one-sided (negative) FWER threshold for effect size(r):%f\n", ...
            prctile(-summaryy.permres.r_external.rnd.zminvals,95))
    end
%     forvis.data{1}=summaryy.g.heterogeneity.tausq;
%     forvis.outputfile{1}=strcat(fileinfos{2},'_',fileinfos{4} ,'_g_tausq');
    for outpfiles=1:length(forvis.data)
        if ~isempty(forvis.data{outpfiles})
        printImage_anticip(forvis.data{outpfiles}, ...
            maskfile, ...
            dfv_masked, ...
            fullfile(outputpath,forvis.outputfile{outpfiles}), ...
            fileinfos{2})
        end
    end

     
% save the z_smoothed version of the non-parametric r-values - I hsould
% boost this with the pTFCE
% pmap=imgstruct.rpermres.permmap_smaller/100;
% pmap(pmap==0)=1/5000;
% pmap(pmap==1)=1-1/5000;
% zmap=norminv(pmap);
% printImage_BK(zmap,mask_path,dfv_masked,[outputpath '\pain_r_zsmthNONparam_smaller_dc2021'])
% %boost with pTFCE and use the following values for thresholding
% prctile(imgstruct.rpermres.max,95) % 4.3790
% prctile(imgstruct.rpermres.min,5) % -4.3598


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

