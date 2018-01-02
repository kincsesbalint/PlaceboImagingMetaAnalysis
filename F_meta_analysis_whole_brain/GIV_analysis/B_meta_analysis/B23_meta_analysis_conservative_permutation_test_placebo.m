%% Meta-Analysis for CONSERVATIVE BRAIN ANALYSIS
% Script analog to the conservative meta-analysis of NPS results
% for creating a permuted (null) distribution of statistics
% Duration for 1000 permutations (with two parpools): ~138.8 minutes! Size of saved distribution is ~6 GB
% 
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
%% Create permuted sample for thresholding meta-analysis maps
tic
load('A1_Conservative_Sample_Img_Data_Masked_10_percent.mat')

n_perms=2000; %number of permutations smallest p possible is 1/n_perms

g_min_z_fixed=NaN(n_perms,1);
g_max_z_fixed=NaN(n_perms,1);
g_min_z_random=NaN(n_perms,1);
g_max_z_random=NaN(n_perms,1);
g_het_max_chi=NaN(n_perms,1);

r_external_min_z_fixed=NaN(n_perms,1);
r_external_max_z_fixed=NaN(n_perms,1);
r_external_min_z_random=NaN(n_perms,1);
r_external_max_z_random=NaN(n_perms,1);
r_external_het_max_chi=NaN(n_perms,1);

parfor p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels 
    curr_df_null=relabel_placebo_for_perm(df_conserv_masked);
    
    % Analyze as in original
    curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo(curr_df_null);
    curr_null_stats_ratings=create_meta_stats_behavior(curr_df_null);
    
    % Analyze as in original
    for i=1:length(curr_null_stats_voxels_placebo)
        curr_null_stats_voxels_placebo(i).r_external=fastcorrcoef(curr_null_stats_voxels_placebo(i).delta,curr_null_stats_ratings(i).delta,true); % correlate single-subject effect of behavior and voxel signal 
        if ~isempty(curr_null_stats_voxels_placebo(i).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        curr_null_stats_voxels_placebo(i).n_r_external=sum(~(isnan(curr_null_stats_voxels_placebo(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(curr_null_stats_ratings(i).delta))); % AND non nan-ratings
        end
    end

    % Summarize
    curr_perm_summary_stats=GIVsummary(curr_null_stats_voxels_placebo,{'g','r_external'});           % use output-argument to only compute stats for "g" and "r_external"
    %keep only essential stats to keep size of output low
    
    g_min_z_fixed(p)=min(curr_perm_summary_stats.g.fixed.z);
    g_max_z_fixed(p)=max(curr_perm_summary_stats.g.fixed.z);
    g_min_z_random(p)=min(curr_perm_summary_stats.g.random.z);
    g_max_z_random(p)=max(curr_perm_summary_stats.g.random.z);
    g_het_max_chi(p)=max(curr_perm_summary_stats.g.heterogeneity.chisq);
    
    r_external_min_z_fixed(p)=min(curr_perm_summary_stats.r_external.fixed.z);
    r_external_max_z_fixed(p)=max(curr_perm_summary_stats.r_external.fixed.z);
    r_external_min_z_random(p)=min(curr_perm_summary_stats.r_external.random.z);
    r_external_max_z_random(p)=max(curr_perm_summary_stats.r_external.random.z);
    r_external_het_max_chi(p)=max(curr_perm_summary_stats.r_external.heterogeneity.chisq);
end

toc

%% Create thresholds:
load('B1_Conservative_Sample_Summary_Placebo.mat')
summary_placebo.g.fixed.perm.min_z=quantile(g_min_z_fixed,0.025); %two-tailed!
summary_placebo.g.fixed.perm.max_z=quantile(g_max_z_fixed,0.975); %two-tailed!
summary_placebo.g.fixed.perm.min_z_dist=g_min_z_fixed; %two-tailed!
summary_placebo.g.fixed.perm.max_z_dist=g_max_z_fixed; %two-tailed!
summary_placebo.g.fixed.perm.p=p_perm(summary_placebo.g.fixed.z,[g_min_z_fixed;g_max_z_fixed],'monte-carlo','two-tailed');

summary_placebo.g.random.perm.min_z=quantile(g_min_z_random,0.025); %two-tailed!
summary_placebo.g.random.perm.max_z=quantile(g_max_z_random,0.975); %two-tailed!
summary_placebo.g.random.perm.min_z_dist=g_min_z_random; %two-tailed!
summary_placebo.g.random.perm.max_z_dist=g_max_z_random; %two-tailed!
summary_placebo.g.random.perm.p=p_perm(summary_placebo.g.random.z,[g_min_z_random;g_max_z_random],'monte-carlo','two-tailed');

summary_placebo.g.heterogeneity.perm.max_chi=quantile(g_het_max_chi,0.95); %one-tailed!
summary_placebo.g.heterogeneity.perm.max_chi_dist=g_het_max_chi; %one-tailed!
summary_placebo.g.heterogeneity.perm.p=p_perm(summary_placebo.g.heterogeneity.chisq,g_het_max_chi,'monte-carlo','one-tailed-larger');


summary_placebo.r_external.fixed.perm.min_z=quantile(r_external_min_z_fixed,0.025); %two-tailed!
summary_placebo.r_external.fixed.perm.max_z=quantile(r_external_max_z_fixed,0.975); %two-tailed!
summary_placebo.r_external.fixed.perm.min_z_dist=r_external_min_z_fixed; %two-tailed!
summary_placebo.r_external.fixed.perm.max_z_dist=r_external_max_z_fixed; %two-tailed!
summary_placebo.r_external.fixed.perm.p=p_perm(summary_placebo.r_external.fixed.z,[r_external_min_z_fixed;r_external_max_z_fixed],'monte-carlo','two-tailed');

summary_placebo.r_external.random.perm.min_z=quantile(r_external_min_z_random,0.025); %two-tailed!
summary_placebo.r_external.random.perm.max_z=quantile(r_external_max_z_random,0.975); %two-tailed!
summary_placebo.r_external.random.perm.min_z_dist=r_external_min_z_random; %two-tailed!
summary_placebo.r_external.random.perm.max_z_dist=r_external_max_z_random; %two-tailed!
summary_placebo.r_external.random.perm.p=p_perm(summary_placebo.r_external.random.z,[r_external_min_z_random;r_external_max_z_random],'monte-carlo','two-tailed');

summary_placebo.r_external.heterogeneity.perm.max_chi=quantile(r_external_het_max_chi,0.95); %one-tailed!
summary_placebo.r_external.heterogeneity.perm.max_chi_dist=r_external_het_max_chi; %one-tailed!
summary_placebo.r_external.heterogeneity.perm.p=p_perm(summary_placebo.r_external.heterogeneity.chisq,r_external_het_max_chi,'monte-carlo','one-tailed-larger');
save('B1_Conservative_Sample_Summary_Placebo.mat','summary_placebo','-append');