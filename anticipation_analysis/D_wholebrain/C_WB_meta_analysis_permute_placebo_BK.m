function summary_placebo=C_WB_meta_analysis_permute_placebo_BK(intermedpath,n_perms,pubpath_forvectimg,varargin)
%% Create the original statistics and permuted sample for thresholding meta-analysis maps
% We do not keep all the permuted data, but create a "counting" map.
% We count the number of cases when the test statistics is higher/lower
% then the permuted statistics. Therefore we come up with p-values (for
% each voxels). We do it for the 

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
if any(strcmp(varargin,'datacoll2015')) %if we focus on MZ datacoll, we get rid of the new studies
    df=df(1:20,:);
    
    dfv_masked.pain_placebo=dfv_masked.pain_placebo(1:20);
    dfv_masked.pain_control=dfv_masked.pain_control(1:20);
    dfv_masked.placebo_minus_control=dfv_masked.placebo_minus_control(1:20);
    
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
if any(strcmp(varargin,'gpu'))
    gpuon='gpu';
else
    gpuon=[];
end
uncor_permmap_larger_rndtsmooth=zeros(1,length(dfv_masked.pain_placebo{1,1}));
uncor_permmap_smaller_rndtsmooth=zeros(1,length(dfv_masked.pain_placebo{1,1}));
fwecor_permmap_larger_rndtsmooth=zeros(1,length(dfv_masked.pain_placebo{1,1}));
fwecor_permmap_smaller_rndtsmooth=zeros(1,length(dfv_masked.pain_placebo{1,1}));
zmaxvals=NaN(1,n_perms);
zminvals=NaN(1,n_perms);
placebo_stats=create_meta_stats_voxels_placebo_BK(df, dfv_masked,gpuon); %placgpu,congpu,studysubjingpumatrix,studix
summary_placebo=GIV_summary_BK(placebo_stats,{'g'});
summary_placebo.g=smooth_SE(summary_placebo.g,dfv_masked.brainmask3d);
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
        
        curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo_BK(df, dfv_masked,'perm',gpuon); %placgpu,congpu,studysubjingpumatrix,studix
    end
        % Summarize
    
%     summary_placebo.g.random.z_smooth; %this is the original stat what we need to compare to the distributed one
    
    
    curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo,{'g'});  %,'r_external'         % use output-argument to only compute stats for "g" and "r_external"
    
    % Obtained smoothed error image and smoothed z-Distribution
    % BK: only calculate the the random effect of smoothed, but one can change
    %it
    curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);

%     curr_perm_summary_stats.g.random.z_smooth; %this is the permuted one
    uncor_permmap_larger_rndtsmooth=uncor_permmap_larger_rndtsmooth+double(summary_placebo.g.random.z_smooth>curr_perm_summary_stats.g.random.z_smooth);
    uncor_permmap_smaller_rndtsmooth=uncor_permmap_smaller_rndtsmooth+double(summary_placebo.g.random.z_smooth<curr_perm_summary_stats.g.random.z_smooth);
    %ezt e kettot ki kell menteni
    zmaxvals(p)=max(curr_perm_summary_stats.g.random.z_smooth);
    zminvals(p)=min(curr_perm_summary_stats.g.random.z_smooth);
    fwecor_permmap_larger_rndtsmooth=fwecor_permmap_larger_rndtsmooth+double(summary_placebo.g.random.z_smooth>max(curr_perm_summary_stats.g.random.z_smooth));
    fwecor_permmap_smaller_rndtsmooth=fwecor_permmap_smaller_rndtsmooth+double(summary_placebo.g.random.z_smooth<min(curr_perm_summary_stats.g.random.z_smooth));
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
summary_placebo.permmap_larger_rndtsmooth=uncor_permmap_larger_rndtsmooth/n_perms*100;
summary_placebo.permmap_smaller_rndtsmooth=uncor_permmap_smaller_rndtsmooth/n_perms*100;
summary_placebo.fwecor_permmap_larger_rndtsmooth=fwecor_permmap_larger_rndtsmooth/n_perms*100;
summary_placebo.fwecor_permmap_smaller_rndtsmooth=fwecor_permmap_smaller_rndtsmooth/n_perms*100;
summary_placebo.zmax=zmaxvals;
summary_placebo.zmin=zminvals;
% if any(strcmp(varargin,'conservative'))
%     save(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
%     'summary_placebo','-append');
% else
%     save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
%     'summary_placebo','-append');
% end
