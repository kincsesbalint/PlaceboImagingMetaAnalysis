function summary_placebo=C_WB_meta_analysis_permute_placebo_BK_gpu(intermedpath,n_perms,pubpath_forvectimg,varargin)
%% Create the original statistics and permuted sample for thresholding meta-analysis maps
% We do not keep all the permuted data, but create a "counting" map.
% We count the number of cases when the test statistics is higher/lower
% then the permuted statistics. Therefore we come up with p-values (for
% each voxels).
% This function uses and make calculation on gpuArrays. For this I have to
% restructure the original one a little.
%
% Balint Kincses
% balint.kincses@uk-essen.de
% 2022

results_path=pubpath_forvectimg;%fullfile(whole_brain_path,'vectorized_results');

if any(strcmp(varargin,'conservative'))
    load_a=load(fullfile(intermedpath,'vectorized_images_conservative_masked_10_percent'),'dfv_masked');
    else
    load_a=load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked'); %this is the vectorized clean data (NOTE that as we exlude voxels based on all studies(from both data collection), the brainmask size differs from MZ's brain mask...)
end
load_b=load(fullfile(intermedpath,'data_frame'),'df'); %this the data frame with the metadata
dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor
df=load_b.df; % Cludge necessary for parfor
clear load_a load_b

if any(strcmp(varargin,'painstimulus'))
    stimtype='painstimulus';
elseif any(strcmp(varargin,'anticipation'))
    stimtype='anticipation';
end

if any(strcmp(varargin,'datacoll2015')) %if we focus on MZ datacoll, we get rid of the new studies
    df=df(1:20,:);
    
    dfv_masked.pain_placebo=dfv_masked.pain_placebo(1:20);
    dfv_masked.pain_control=dfv_masked.pain_control(1:20);
    dfv_masked.placebo_minus_control=dfv_masked.placebo_minus_control(1:20);
elseif any(strcmp(varargin,'threestudy'))
    df=df(1:3,:);
    
    dfv_masked.pain_placebo=dfv_masked.pain_placebo(1:3);
    dfv_masked.pain_control=dfv_masked.pain_control(1:3);
    dfv_masked.placebo_minus_control=dfv_masked.placebo_minus_control(1:3);
elseif any(strcmp(varargin,'onlyonestudy'))
    df=df(10,:);
    dfv_masked.pain_placebo=dfv_masked.pain_placebo(10);
    dfv_masked.pain_control=dfv_masked.pain_control(10);
    dfv_masked.placebo_minus_control=dfv_masked.placebo_minus_control(10);
end
%% Meta-Analysis for FULL BRAIN ANALYSIS
% g_z_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
% g_z_random=NaN(n_perms,sum(dfv_masked.brainmask));
% g_tfce_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
% g_tfce_random=NaN(n_perms,sum(dfv_masked.brainmask));
% g_het=NaN(n_perms,sum(dfv_masked.brainmask));

% r_external_z_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
% r_external_z_random=NaN(n_perms,sum(dfv_masked.brainmask));
% r_external_tfce_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
% r_external_tfce_random=NaN(n_perms,sum(dfv_masked.brainmask));
% r_het=NaN(n_perms,sum(dfv_masked.brainmask));

%to speed up thing a little...
% studix.within=find(~df.contrast_imgs_only & df.study_design=="within");
% studix.between=find(df.study_design=="between");
% studix.contrastonly=find(df.contrast_imgs_only);
% 
% placgpu=gpuArray(vertcat(dfv_masked.pain_placebo{:}));
% congpu=gpuArray(vertcat(dfv_masked.pain_control{:}));
% 
% for study=1:length(dfv_masked.pain_placebo)
%     curr_n(study)=size(dfv_masked.pain_placebo{study},1);
% end
% studysubjingpumatrix=ones(1,length(curr_n)+1);
% for i=1:length(curr_n)+1
%     if 1<i && i<length(curr_n)+1
%         studysubjingpumatrix(i)=sum(curr_n(1:i-1));
% %     elseif i==2
% %         studysubjingpumatrix(i)=curr_n(i-1);
%     elseif i==1
%         studysubjingpumatrix(i)=0;
%     elseif i==length(curr_n)+1
%         studysubjingpumatrix(i)=sum(curr_n);
%     end
% end
% tic
% h = waitbar(0,'Permuting placebo...');
% if any(strcmp(varargin,'gpu'))
%     gpuon='gpu';
% else
%     gpuon=[];
% end
uncor_permmap_larger_rndtsmooth=zeros(1,sum(dfv_masked.brainmask));
uncor_permmap_smaller_rndtsmooth=zeros(1,sum(dfv_masked.brainmask));
uncor_permmap_larger_g=zeros(1,sum(dfv_masked.brainmask));
uncor_permmap_smaller_g=zeros(1,sum(dfv_masked.brainmask));
fwecor_permmap_larger_rndtsmooth=zeros(1,sum(dfv_masked.brainmask));
fwecor_permmap_smaller_rndtsmooth=zeros(1,sum(dfv_masked.brainmask));
zmaxvals=NaN(1,n_perms);
zminvals=NaN(1,n_perms);

gmaxvals=NaN(1,n_perms);
gminvals=NaN(1,n_perms);
% for the correlation
uncor_permmap_larger_r=zeros(1,sum(dfv_masked.brainmask));
uncor_permmap_smaller_r=zeros(1,sum(dfv_masked.brainmask));
rmaxvals=NaN(1,n_perms);
rminvals=NaN(1,n_perms);
fwecor_permmap_larger_r=zeros(1,sum(dfv_masked.brainmask));
fwecor_permmap_smaller_r=zeros(1,sum(dfv_masked.brainmask));
%the conversion of data to gpuArray has to be done here as we do not want
%to convert it after every permutation, bc that is kind of time consuming
%step.
% this is one way to do it: basically keep the original structure of the
% dfv_masked,but keep all the data in structure format which has gpuArrays
% field values
fieldnms=df.study_ID;
nstudy=height(df);
for i=1:nstudy; mys.pain_control.(string(fieldnms{i}))=gpuArray(dfv_masked.pain_control{i,1});end
for i=1:nstudy; mys.pain_placebo.(string(fieldnms{i}))=gpuArray(dfv_masked.pain_placebo{i,1});end
for i=1:nstudy; mys.placebo_minus_control.(string(fieldnms{i}))=gpuArray(dfv_masked.placebo_minus_control{i,1});end

placebo_stats=create_meta_stats_voxels_placebo_BK_gpu(df, mys,stimtype); %placgpu,congpu,studysubjingpumatrix,studix
if ~any(strcmp(varargin,'onlyonestudy'))
    summary_placebo=GIV_summary_BK(placebo_stats,{'g','r_external'});
    summary_placebo.g=smooth_SE(summary_placebo.g,dfv_masked.brainmask3d);
end

for p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels 
    % NOTE: Originally, I've shuffled labels for permutation testing using a separate function
    % however, it turned out that creating a full second shuffled copy of the data would occupy too much memory.
    %[curr_df_null, curr_dfv_null]=relabel_placebo_for_perm(df,dfv_masked);
    %
    % Analyze as in original
    if any(strcmp(varargin,'conservative'))
        curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo(df, dfv_masked,'conservative','perm');
    else
        
        curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo_BK_gpu(df, mys,'perm',stimtype); %placgpu,congpu,studysubjingpumatrix,studix
    end
        % Summarize
    
%     summary_placebo.g.random.z_smooth; %this is the original stat what we need to compare to the distributed one
    
    if ~any(strcmp(varargin,'onlyonestudy'))
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo,{'g','r_external'});  %,'r_external'         % use output-argument to only compute stats for "g" and "r_external"
    
    % Obtained smoothed error image and smoothed z-Distribution
    % BK: only calculate the the random effect of smoothed, but one can change
    %it 
    curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);
    
%     curr_perm_summary_stats.g.random.z_smooth; %this is the permuted one
    % these are the smoothed
    uncor_permmap_larger_rndtsmooth=uncor_permmap_larger_rndtsmooth+double(summary_placebo.g.random.z_smooth>curr_perm_summary_stats.g.random.z_smooth);
    uncor_permmap_smaller_rndtsmooth=uncor_permmap_smaller_rndtsmooth+double(summary_placebo.g.random.z_smooth<curr_perm_summary_stats.g.random.z_smooth);
%     uncor_permmap_larger_g=uncor_permmap_larger_g+double(summary_placebo.g.random.summary>curr_perm_summary_stats.g.random.summary);
%     uncor_permmap_smaller_g=uncor_permmap_smaller_g+double(summary_placebo.g.random.summary<curr_perm_summary_stats.g.random.summary);
    %ezt e kettot ki kell menteni
    zmaxvals(p)=max(curr_perm_summary_stats.g.random.z_smooth);
    zminvals(p)=min(curr_perm_summary_stats.g.random.z_smooth);
    
%     gmaxvals(p)=max(curr_perm_summary_stats.g.random.summary);
%     gminvals(p)=min(curr_perm_summary_stats.g.random.summary);
%     zmaxvals_nonsmoothed(p)=max(curr_perm_summary_stats.g.random.z);
%     zminvals_nonsmoothed(p)=min(curr_perm_summary_stats.g.random.z);
%     zposmeanvals(p)=mean(curr_perm_summary_stats.g.random.z_smooth(curr_perm_summary_stats.g.random.z_smooth>0));
%     znegmeanvals(p)=mean(curr_perm_summary_stats.g.random.z_smooth(curr_perm_summary_stats.g.random.z_smooth<0));
    fwecor_permmap_larger_rndtsmooth=fwecor_permmap_larger_rndtsmooth+double(summary_placebo.g.random.z_smooth>max(curr_perm_summary_stats.g.random.z_smooth));
    fwecor_permmap_smaller_rndtsmooth=fwecor_permmap_smaller_rndtsmooth+double(summary_placebo.g.random.z_smooth<min(curr_perm_summary_stats.g.random.z_smooth));
    
%     zmax_fixed(p)=max(curr_perm_summary_stats.g.fixed.z_smooth);
%     zmin_fixed(p)=min(curr_perm_summary_stats.g.fixed.z_smooth);
%     zposmean_fixed(p)=mean(curr_perm_summary_stats.g.fixed.z_smooth(curr_perm_summary_stats.g.fixed.z_smooth>0));
%     znegmean_fixed(p)=mean(curr_perm_summary_stats.g.fixed.z_smooth(curr_perm_summary_stats.g.fixed.z_smooth<0));
%     weight_fixed(p)=mean(curr_perm_summary_stats.g.fixed.weight,'all','omitnan');
%     %effectsize - they seemed to be the same for the bad and good perm
%     effposmean(p)=mean(curr_perm_summary_stats.g.random.summary(curr_perm_summary_stats.g.random.summary>0));
%     effnegmean(p)=mean(curr_perm_summary_stats.g.random.summary(curr_perm_summary_stats.g.random.summary<0));
%     SEsummary_mean(p)=mean(curr_perm_summary_stats.g.random.SEsummary);
%     SEsummary_max(p)=max(curr_perm_summary_stats.g.random.SEsummary);
    
    %heterogeneity

    
    heterogenposmean(p)=mean(curr_perm_summary_stats.g.heterogeneity.tausq(curr_perm_summary_stats.g.heterogeneity.tausq>0));
    % the correlation:
    uncor_permmap_larger_r=uncor_permmap_larger_r+double(summary_placebo.r_external.random.summary>curr_perm_summary_stats.r_external.random.summary);
    uncor_permmap_smaller_r=uncor_permmap_smaller_r+double(summary_placebo.r_external.random.summary<curr_perm_summary_stats.r_external.random.summary);  
    
    rmaxvals(p)=max(curr_perm_summary_stats.r_external.random.summary);
    rminvals(p)=min(curr_perm_summary_stats.r_external.random.summary);
    fwecor_permmap_larger_r=fwecor_permmap_larger_r+double(summary_placebo.r_external.random.summary>max(curr_perm_summary_stats.r_external.random.summary));
    fwecor_permmap_smaller_r=fwecor_permmap_smaller_r+double(summary_placebo.r_external.random.summary<min(curr_perm_summary_stats.r_external.random.summary));


    else
        gposmean(p)=mean(curr_null_stats_voxels_placebo.g(curr_null_stats_voxels_placebo.g>0));
        gnegmean(p)=mean(curr_null_stats_voxels_placebo.g(curr_null_stats_voxels_placebo.g<0));
        g_semean(p)=mean(curr_null_stats_voxels_placebo.se_g,'omitnan');
    end
%     curr_perm_summary_stats.r_external=smooth_SE(curr_perm_summary_stats.r_external,dfv_masked.brainmask3d);
% 
%     % TFCE based on z-smooth
%     curr_perm_summary_stats.g=meta_TFCE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);
%     curr_perm_summary_stats.r_external=meta_TFCE(curr_perm_summary_stats.r_external,dfv_masked.brainmask3d);
%     
%     g_z_fixed(p,:)=curr_perm_summary_stats.g.fixed.z_smooth;
%     g_z_random(p,:)=curr_perm_summary_stats.g.random.z_smooth;
%     g_tfce_fixed(p,:)=curr_perm_summary_stats.g.fixed.tfce;
%     g_tfce_random(p,:)=curr_perm_summary_stats.g.random.tfce;
%     g_het(p,:)=curr_perm_summary_stats.g.heterogeneity.chisq;
% 
%     r_external_z_fixed(p,:)=curr_perm_summary_stats.r_external.fixed.z_smooth;
%     r_external_z_random(p,:)=curr_perm_summary_stats.r_external.random.z_smooth;
%     r_external_tfce_fixed(p,:)=curr_perm_summary_stats.r_external.fixed.tfce;
%     r_external_tfce_random(p,:)=curr_perm_summary_stats.r_external.random.tfce;
%     r_het(p,:)=curr_perm_summary_stats.r_external.heterogeneity.chisq;
%     waitbar(p / n_perms)
end
% close(h) 
% toc
%% Add permuted null-distributions to statistical summary struct

% if any(strcmp(varargin,'conservative'))
%     load(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
%     'summary_placebo');
% else
%     load(fullfile(results_path,'WB_summary_placebo_full.mat'),...
%     'summary_placebo');
% end
% 
% summary_placebo.g.fixed.perm.z_dist=g_z_fixed;
% summary_placebo.g.random.perm.z_dist=g_z_random;
% summary_placebo.g.fixed.perm.tfce_dist=g_tfce_fixed;
% summary_placebo.g.random.perm.tfce_dist=g_tfce_random;
% summary_placebo.g.heterogeneity.perm.chi_dist=g_het;
% 
% summary_placebo.r_external.fixed.perm.z_dist=r_external_z_fixed;
% summary_placebo.r_external.random.perm.z_dist=r_external_z_random;
% summary_placebo.r_external.fixed.perm.tfce_dist=r_external_tfce_fixed;
% summary_placebo.r_external.random.perm.tfce_dist=r_external_tfce_random;
% summary_placebo.r_external.heterogeneity.perm.chi_dist=r_het;
% 

%% This is where the statistics is added to the mat file

% %% Add smoothened errors, pseudo-z and TFCE to statistical summary struct
% summary_placebo.g=smooth_SE(summary_placebo.g,dfv_masked.brainmask3d);
% summary_placebo.g=meta_TFCE(summary_placebo.g,dfv_masked.brainmask3d);
% 
% summary_placebo.r_external=smooth_SE(summary_placebo.r_external,dfv_masked.brainmask3d);
% summary_placebo.r_external=meta_TFCE(summary_placebo.r_external,dfv_masked.brainmask3d);

% the values at each voxels means in how much percent of the test statistics was
% larger/smaller then the permuted one. The values are between 0 and 100,
% which means the given voxel was higher in NN% of the cases from the
% permuted distribution. Therefre, we can pick those voxels which are in
% the upper or lower 2.5%)(in the resulted map, voxels with a value higher
% than 97.5% (two-tailed 5%test,separaetly on the larger/smaller imgs), are significatn with the
% uncor and the fwe corrected level).
if ~any(strcmp(varargin,'onlyonestudy'))
summary_placebo.diffpermres.permmap_larger_rndtsmooth=uncor_permmap_larger_rndtsmooth/n_perms*100;
summary_placebo.diffpermres.permmap_smaller_rndtsmooth=uncor_permmap_smaller_rndtsmooth/n_perms*100;
% summary_placebo.permmap_larger_g=uncor_permmap_larger_g/n_perms*100;
% summary_placebo.permmap_smaller_g=uncor_permmap_smaller_g/n_perms*100;
summary_placebo.diffpermres.fwecor_permmap_larger_rndtsmooth=fwecor_permmap_larger_rndtsmooth/n_perms*100;
summary_placebo.diffpermres.fwecor_permmap_smaller_rndtsmooth=fwecor_permmap_smaller_rndtsmooth/n_perms*100;
summary_placebo.diffpermres.zmax=zmaxvals;
summary_placebo.diffpermres.zmin=zminvals;
% summary_placebo.g.max=gmaxvals;
% summary_placebo.g.min=gminvals;
% summary_placebo.zmean=zmeanvals;
% summary_placebo.zposmean=zposmeanvals;
% summary_placebo.znegmean=znegmeanvals;
% summary_placebo.zvals.maxnonsmth=zmaxvals_nonsmoothed;
% summary_placebo.zvals.minnonsmth=zminvals_nonsmoothed;
% summary_placebo.fixed.zmax=zmax_fixed;
% summary_placebo.fixed.zmin=zmin_fixed;
% summary_placebo.fixed.zposmean=zposmean_fixed;
% summary_placebo.fixed.znegmean=znegmean_fixed;
% summary_placebo.fixed.weight=weight_fixed;
% summary_placebo.summary.posmean=effposmean;
% summary_placebo.summary.negmean=effnegmean;
% summary_placebo.summary.semean=SEsummary_mean;
% summary_placebo.summary.semax=SEsummary_max;

summary_placebo.heterogen.posmean=heterogenposmean;

summary_placebo.rpermres.permmap_larger=uncor_permmap_larger_r/n_perms*100;
summary_placebo.rpermres.permmap_smaller=uncor_permmap_smaller_r/n_perms*100;
summary_placebo.rpermres.fwecor_larger=fwecor_permmap_larger_r/n_perms*100;
summary_placebo.rpermres.fwecor_smaller=fwecor_permmap_smaller_r/n_perms*100;
summary_placebo.rpermres.max=rmaxvals;
summary_placebo.rpermres.min=rminvals;
else
    summary_placebo.gposmean=gposmean;
    summary_placebo.gnegmean=gnegmean;
    summary_placebo.gsemean=g_semean;
end

% if any(strcmp(varargin,'conservative'))
%     save(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
%     'summary_placebo','-append');
% else
%     save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
%     'summary_placebo','-append');
% end
