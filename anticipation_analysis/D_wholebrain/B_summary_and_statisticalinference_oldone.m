function summaryy=B_summary_and_statisticalinference(intermedpath,n_perms,phasetype,mycontrast,params,varargin)
%% Create the original statistics and permuted sample for thresholding meta-analysis maps
% 
% This is a revised version of the
% C_WB_meta_analysis_permute_placebo_BK_gpu function.
% 
% This function is a modified version of MZ's 
%  -A_WB_meta_analysis_placebo(datapathorig,'conservative')
%  -C_WB_meta_analysis_permute_placebo(datapathorig,1500,'conservative')
%  -D_WB_meta_analysis_p_values_placebo(datapathorig,'conservative')
% functions.
%
% It uses the vectorized, (whole brain) masked individual images and calculates voxelwise 
% summary statistics (eg: Hedges's g and correlation) for the whole sample.
% It uses the GIV approach to calculate summary statistics. (GIV
% method-GIV_summary and the GIV_weight does the real work) 
% 
% 
% Permutation based statistical inference:
% We do not keep all the permuted data, but create a "counting" map.
% We count the number of cases when the test statistics is higher/lower
% then the permuted statistics. Therefore we come up with p-values (for
% each voxels).
%
% GPU calculation: 
% This function uses and make calculation on gpuArrays. For this I have to
% restructure the original one a little. As the GPU access is also limited,
% so this function needs to be called separately for anticipation and for
% pain phase.
%
% Input:
%   - intermedpath: the path to the folder where the meta table is
%   - n_perms: the # of permutation
%   - phasetype: specify if we calculate the pain stimulation or the
%   anticipation part,i.e:'pain' OR 'anticip'
%   - mycontrast: specify if we calculate the difference or the sum of the
%   placebo, control conditions,i.e: 'diff' OR 'sum' means 'placebo minus
%   control' OR 'placebo and control' respectively
%   - varagin: stimtype: painstimulus OR anticipation, depending on the
%   type of image what we investigate
% 
% 
% 
% 
% 
% Balint Kincses
% balint.kincses@uk-essen.de
% 2022

%% Load necessary files
% Original data frame with all the metadata based on the argument
load_b=load(fullfile(intermedpath,'data_frame'),'df');
df=load_b.df;
fieldnms=df.study_ID;

if any(strcmp(varargin,'datacoll2015')) %if we focus on MZ datacoll, we get rid of the new studies
    df=df(1:20,:);
        
end

nstudy=height(df);
% one can specify the dfv_masked as the first input varargin if it is
% already loaded to the environment.
if any(strcmp(fieldnames(varargin{1}),'pain_placebo')) && any(strcmp(fieldnames(varargin{1}),'anticip_placebo'))
    dfv_masked=varargin{1};
else
    load_a=load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
    dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor

end
if strcmp(mycontrast,'diff')
    cons={'_placebo','_control','_placebo_minus_control'};
elseif strcmp(mycontrast,'sum')
    cons={'_placebo_and_control'};
end
% put all the data on the gpu
for contrast=1:length(cons)
    for i=1:nstudy
        mys.(strcat(phasetype,cons{contrast})).(string(fieldnms{i}))=gpuArray(dfv_masked.(strcat(phasetype,cons{contrast})){i,1});
    end
end
%  % Cludge necessary for parfor
clear load_a load_b

%% prespecify variables which contain the voxel level p-values 
for parameters=1:length(params)
    pval.(params{parameters}).rnd.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).rnd.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    % pval.g.fwecor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    % pval.g.fwecor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).rnd.zmaxvals=NaN(1,n_perms);
    pval.(params{parameters}).rnd.zminvals=NaN(1,n_perms);
    
    
    pval.(params{parameters}).fx.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).fx.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).fx.zmaxvals=NaN(1,n_perms);
    pval.(params{parameters}).fx.zminvals=NaN(1,n_perms);
end
% if any(strcmp(params,'g'))
%     pval.g.rnd.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.g.rnd.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     % pval.g.fwecor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     % pval.g.fwecor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.g.rnd.zmaxvals=NaN(1,n_perms);
%     pval.g.rnd.zminvals=NaN(1,n_perms);
%     
%     
%     pval.g.fx.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.g.fx.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.g.fx.zmaxvals=NaN(1,n_perms);
%     pval.g.fx.zminvals=NaN(1,n_perms);
% end
% if any(strcmp(params,'r_external'))
% 
%     pval.r.rnd.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.rnd.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     %     pval.r.fwecor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     %     pval.r.fwecor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.rnd.zmaxvals=NaN(1,n_perms);
%     pval.r.rnd.zminvals=NaN(1,n_perms);
%     
%     pval.r.fx.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.fx.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.fx.zmaxvals=NaN(1,n_perms);
%     pval.r.fx.zminvals=NaN(1,n_perms);
% end
h = waitbar(0,'Permuting placebo...');
if strcmp(mycontrast,'diff')
    placebo_stats=placebodiff_g_cor_sum(df, mys,phasetype);
    summaryy=GIV_summary_BK(placebo_stats,params); %'g'
    for parameters=1:length(params)
        summaryy.(params{parameters})=smooth_SE(summaryy.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));
    end
%     summaryy.r_external=smooth_SE(summaryy.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     stat={'g','r_external'};
%     pval.r.rnd.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.rnd.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
% %     pval.r.fwecor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
% %     pval.r.fwecor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.rnd.zmaxvals=NaN(1,n_perms);
%     pval.r.rnd.zminvals=NaN(1,n_perms);
%     pval.r.fx.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.fx.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
%     pval.r.fx.zmaxvals=NaN(1,n_perms);
%     pval.r.fx.zminvals=NaN(1,n_perms);
    for p=1:n_perms 
    % Summarize the study level permuted data
        %placebo minus control - g statistics        
        curr_null_stats_voxels_placebo_g=perminfer(df, mys,placebo_stats,mycontrast,params,'perm',phasetype);
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo_g,params);  % use output-argument to only compute stats for "g" and "r_external"
        for parameters=1:length(params)
            curr_perm_summary_stats.(params{parameters})=smooth_SE(curr_perm_summary_stats.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));

            pval.(params{parameters}).rnd.uncor_larger=pval.(params{parameters}).rnd.uncor_larger+double(summaryy.(params{parameters}).random.z_smooth>curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.uncor_smaller=pval.(params{parameters}).rnd.uncor_smaller+double(summaryy.(params{parameters}).random.z_smooth<curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).rnd.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
    %         pval.g.fwecor_larger=pval.g.fwecor_larger+double(summaryy.g.random.z_smooth>pval.g.zmaxvals(p));
    %         pval.g.fwecor_smaller=pval.g.fwecor_smaller+double(summaryy.g.random.z_smooth<pval.g.zminvals(p));
            pval.(params{parameters}).fx.uncor_larger=pval.(params{parameters}).fx.uncor_larger+double(summaryy.(params{parameters}).fixed.z_smooth>curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.uncor_smaller=pval.(params{parameters}).fx.uncor_smaller+double(summaryy.(params{parameters}).fixed.z_smooth<curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).fx.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
        end
%         curr_perm_summary_stats.r_external=smooth_SE(curr_perm_summary_stats.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
        
        % Uncorrected for multiple comparison. Non-parametric distribution...
        % Calculate if the permutation based stat is larger/smaller then the
        % original stat. This count has to be divided with the number of
        % permutations to end up with a p-value. So values which are smaller then
        % 0.05, means statistical signifcant on a one-sided uncorrected test.
        
%         if any(strcmp(params,'g'))
%             pval.g.rnd.uncor_larger=pval.g.rnd.uncor_larger+double(summaryy.g.random.z_smooth>curr_perm_summary_stats.g.random.z_smooth);
%             pval.g.rnd.uncor_smaller=pval.g.rnd.uncor_smaller+double(summaryy.g.random.z_smooth<curr_perm_summary_stats.g.random.z_smooth);
%             % Corrected for multiple comparison with FWE, using zmax stat
%             pval.g.rnd.zmaxvals(p)=max(curr_perm_summary_stats.g.random.z_smooth);
%             pval.g.rnd.zminvals(p)=min(curr_perm_summary_stats.g.random.z_smooth);
%     %         pval.g.fwecor_larger=pval.g.fwecor_larger+double(summaryy.g.random.z_smooth>pval.g.zmaxvals(p));
%     %         pval.g.fwecor_smaller=pval.g.fwecor_smaller+double(summaryy.g.random.z_smooth<pval.g.zminvals(p));
%             pval.g.fx.uncor_larger=pval.g.fx.uncor_larger+double(summaryy.g.fixed.z_smooth>curr_perm_summary_stats.g.fixed.z_smooth);
%             pval.g.fx.uncor_smaller=pval.g.fx.uncor_smaller+double(summaryy.g.fixed.z_smooth<curr_perm_summary_stats.g.fixed.z_smooth);
%             % Corrected for multiple comparison with FWE, using zmax stat
%             pval.g.fx.zmaxvals(p)=max(curr_perm_summary_stats.g.fixed.z_smooth);
%             pval.g.fx.zminvals(p)=min(curr_perm_summary_stats.g.fixed.z_smooth);
%         end
%         if any(strcmp(params,'r_external'))
%             pval.r.rnd.uncor_larger=pval.r.rnd.uncor_larger+double(summaryy.r_external.random.z_smooth>curr_perm_summary_stats.r_external.random.z_smooth);
%             pval.r.rnd.uncor_smaller=pval.r.rnd.uncor_smaller+double(summaryy.r_external.random.z_smooth<curr_perm_summary_stats.r_external.random.z_smooth);
%             % Corrected for multiple comparison with FWE, using zmax stat
%             pval.r.rnd.zmaxvals(p)=max(curr_perm_summary_stats.r_external.random.z_smooth);
%             pval.r.rnd.zminvals(p)=min(curr_perm_summary_stats.r_external.random.z_smooth);
%     %         pval.r.fwecor_larger=pval.r.fwecor_larger+double(summaryy.r_external.random.z_smooth>pval.r.zmaxvals(p));
%     %         pval.r.fwecor_smaller=pval.r.fwecor_smaller+double(summaryy.r_external.random.z_smooth<pval.r.zminvals(p));
%             pval.r.fx.uncor_larger=pval.r.fx.uncor_larger+double(summaryy.r_external.fixed.z_smooth>curr_perm_summary_stats.r_external.fixed.z_smooth);
%             pval.r.fx.uncor_smaller=pval.r.fx.uncor_smaller+double(summaryy.r_external.fixed.z_smooth<curr_perm_summary_stats.r_external.fixed.z_smooth);
%             % Corrected for multiple comparison with FWE, using zmax stat
%             pval.r.fx.zmaxvals(p)=max(curr_perm_summary_stats.r_external.fixed.z_smooth);
%             pval.r.fx.zminvals(p)=min(curr_perm_summary_stats.r_external.fixed.z_smooth);
%         end
%     
        waitbar(p / n_perms)
    end
    
elseif strcmp(mycontrast,'sum')
    %todo rewrite script as above
    pain_stats = pain_g_sum(df, mys,phasetype);
    summaryy=GIV_summary_BK(pain_stats,{'g','r_external'});
    summaryy.g=smooth_SE(summaryy.g,dfv_masked.(strcat(phasetype,"_brainmask3d")));
    summaryy.r_external=smooth_SE(summaryy.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     stat={'g'};

    for p=1:n_perms 
    % Summarize the study level permuted data
        %placebo minus control - g statistics        

        %     %placebo and control - g statistics
        curr_null_stats_voxels_pain=perminfer(df,mys,pain_stats,mycontrast,params,'perm',phasetype);
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_pain,{'g','r_external'});  % use output-argument to only compute stats for "g" and "r_external"
        curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.(strcat(phasetype,"_brainmask3d")));
        curr_perm_summary_stats.r_external=smooth_SE(curr_perm_summary_stats.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
        % Uncorrected for multiple comparison. Non-parametric distribution...
        % Calculate if the permutation based stat is larger/smaller then the
        % original stat. This count has to be divided with the number of
        % permutations to end up with a p-value. So values which are smaller then
        % 0.05, means statistical signifcant on a one-sided uncorrected test.
        pval.g.rnd.uncor_larger=pval.g.rnd.uncor_larger+double(summaryy.g.random.z_smooth>curr_perm_summary_stats.g.random.z_smooth);
        pval.g.rnd.uncor_smaller=pval.g.rnd.uncor_smaller+double(summaryy.g.random.z_smooth<curr_perm_summary_stats.g.random.z_smooth);
        % Corrected for multiple comparison with FWE, using zmax stat
        pval.g.rnd.zmaxvals(p)=max(curr_perm_summary_stats.g.random.z_smooth);
        pval.g.rnd.zminvals(p)=min(curr_perm_summary_stats.g.random.z_smooth);
%         pval.g.fwecor_larger=pval.g.fwecor_larger+double(summaryy.g.random.z_smooth>pval.g.zmaxvals(p));
%         pval.g.fwecor_smaller=pval.g.fwecor_smaller+double(summaryy.g.random.z_smooth<pval.g.zminvals(p));
        pval.g.fx.uncor_larger=pval.g.fx.uncor_larger+double(summaryy.g.fixed.z_smooth>curr_perm_summary_stats.g.fixed.z_smooth);
        pval.g.fx.uncor_smaller=pval.g.fx.uncor_smaller+double(summaryy.g.fixed.z_smooth<curr_perm_summary_stats.g.fixed.z_smooth);
        % Corrected for multiple comparison with FWE, using zmax stat
        pval.g.fx.zmaxvals(p)=max(curr_perm_summary_stats.g.fixed.z_smooth);
        pval.g.fx.zminvals(p)=min(curr_perm_summary_stats.g.fixed.z_smooth);


        pval.r.rnd.uncor_larger=pval.r.rnd.uncor_larger+double(summaryy.r_external.random.z_smooth>curr_perm_summary_stats.r_external.random.z_smooth);
        pval.r.rnd.uncor_smaller=pval.r.rnd.uncor_smaller+double(summaryy.r_external.random.z_smooth<curr_perm_summary_stats.r_external.random.z_smooth);
        % Corrected for multiple comparison with FWE, using zmax stat
        pval.r.rnd.zmaxvals(p)=max(curr_perm_summary_stats.r_external.random.z_smooth);
        pval.r.rnd.zminvals(p)=min(curr_perm_summary_stats.r_external.random.z_smooth);
%         pval.r.fwecor_larger=pval.r.fwecor_larger+double(summaryy.r_external.random.z_smooth>pval.r.zmaxvals(p));
%         pval.r.fwecor_smaller=pval.r.fwecor_smaller+double(summaryy.r_external.random.z_smooth<pval.r.zminvals(p));
        pval.r.fx.uncor_larger=pval.r.fx.uncor_larger+double(summaryy.r_external.fixed.z_smooth>curr_perm_summary_stats.r_external.fixed.z_smooth);
        pval.r.fx.uncor_smaller=pval.r.fx.uncor_smaller+double(summaryy.r_external.fixed.z_smooth<curr_perm_summary_stats.r_external.fixed.z_smooth);
        % Corrected for multiple comparison with FWE, using zmax stat
        pval.r.fx.zmaxvals(p)=max(curr_perm_summary_stats.r_external.fixed.z_smooth);
        pval.r.fx.zminvals(p)=min(curr_perm_summary_stats.r_external.fixed.z_smooth);
        waitbar(p / n_perms)
    end
    
end



% for p=1:n_perms %exchange parfor with for if parallel processing is not possible
% % Summarize the study level permuted data
%     %placebo minus control - g statistics
%     
%     curr_null_stats_voxels_placebo_g=g_perminfer(df, mys,'perm',phasetype);
%     curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo_g,{'g'});  % use output-argument to only compute stats for "g" and "r_external"
%     curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     %placebo minus control correlation with behavior - r statistics
% %     curr_null_stats_voxels_placebo_r=cor_perminfer(df,placebo_stats,'perm',phasetype);
% %     curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo_r,{'r_external'});  % use output-argument to only compute stats for "g" and "r_external"
% %     curr_perm_summary_stats.r_external=smooth_SE(curr_perm_summary_stats.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
% %     %placebo and control - g statistics
% %     curr_null_stats_voxels_pain_g=g_perminfer(df,mys,'perm',phasetype);
% %     curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_pain_g,{'g'});  % use output-argument to only compute stats for "g" and "r_external"
% % Uncorrected for multiple comparison. Non-parametric distribution...
% % Calculate if the permutation based stat is larger/smaller then the
% % original stat. This count has to be divided with the number of
% % permutations to end up with a p-value. So values which are smaller then
% % 0.05, means statistical signifcant on a one-sided uncorrected test.
% pval.uncor_larger=pval.uncor_larger+double(summary_placebo.(stat{1}).random.z_smooth>curr_perm_summary_stats.g.random.z_smooth);
% pval.uncor_smaller=pval.uncor_smaller+double(summary_placebo.g.random.z_smooth<curr_perm_summary_stats.g.random.z_smooth);
% % Corrected for multiple comparison with FWE, using zmax stat
% pval.zmaxvals(p)=max(curr_perm_summary_stats.g.random.z_smooth);
% pval.zminvals(p)=min(curr_perm_summary_stats.g.random.z_smooth);
% pval.fwecor_larger=pval.fwecor_larger+double(summary_placebo.g.random.z_smooth>pval.zmaxvals(p));
% pval.fwecor_smaller=pval.fwecor_smaller+double(summary_placebo.g.random.z_smooth<pval.zminvals(p));
% 
%     % the correlation:
%     % with the use of these one can estimate the permutation based
%     % smoothed Z-values(it has a max/min value as it depends on the number of
%     % permutations)
% %     uncor_permmap_larger_r=uncor_permmap_larger_r+double(summary_placebo.r_external.random.z_smooth>curr_perm_summary_stats.r_external.random.z_smooth);
% %     uncor_permmap_smaller_r=uncor_permmap_smaller_r+double(summary_placebo.r_external.random.z_smooth<curr_perm_summary_stats.r_external.random.z_smooth);  
%     % this is the maximum Z-statistics, we save out hte maximum/minmum
%     % values of the z_smooth stat, therefore, we can estimate the upper and
%     % lower 5% percentile based on the distribution. This value can be
%     % used to threshold the parametric(smooth)Z, the permuted smooth Z
%     % maps, or the previous two pTFCE boosted maps.
% %     rmaxvals(p)=max(curr_perm_summary_stats.r_external.random.z_smooth);
% %     rminvals(p)=min(curr_perm_summary_stats.r_external.random.z_smooth);
%     %this should be the same as the previous one, receiving
%     %p-values(depending on the number of permutation).
%     % So the above two has some correspondance...check it!!!
% %     fwecor_permmap_larger_r=fwecor_permmap_larger_r+double(summary_placebo.r_external.random.z_smooth>max(curr_perm_summary_stats.r_external.random.z_smooth));
% %     fwecor_permmap_smaller_r=fwecor_permmap_smaller_r+double(summary_placebo.r_external.random.z_smooth<min(curr_perm_summary_stats.r_external.random.z_smooth));
% 
% 
%   
% 
%     waitbar(p / n_perms)
% end
close(h) 
% toc
%% Add permuted null-distributions to statistical summary struct

summaryy.permres=pval;
summaryy.nperm=n_perms;

save(fullfile(intermedpath,['WB_' phasetype '_phase_' mycontrast '_summary.mat']),...
    'summaryy','-v7.3');
