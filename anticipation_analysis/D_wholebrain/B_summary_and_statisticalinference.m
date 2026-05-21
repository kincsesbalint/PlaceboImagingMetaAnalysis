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
%   - params: the parameters which the GIV pooling has to be done. Two
%   input is accepted 'g'/'r_external' for summary (difference/sum) of
%   placebo related activity and correlation with it.
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
totalnstudy=height(df);

if any(strcmp(varargin,'putamen')) %if we want to calculate the correlation between anticipatory putamen activity difference with activity during pain 
    putamencorr=1;
    additionalinfo='putamencorr';
else
    putamencorr=0;
    additionalinfo='';
end
if any(strcmp(varargin,'quadratic')) %model a quadratic association between rating and brain activity, add the dummy variable putamencorr a wierd value
    warning('The script was initialized to estimate QUADRATIC association between rating and brain activation') 
    putamencorr=99;
    additionalinfo='quadraticmodelestimation';
end
if any(strcmp(varargin,'datacoll2015')) %if we focus on MZ datacoll, we get rid of the new studies
    df=df(1:20,:);
elseif any(strcmp(varargin,'colinearity_neg')) 
    poscolstudies=[ find(strcmp(df.study_ID,'atlas')) ...
        find(strcmp(df.study_ID,'lui')) ...
        find(strcmp(df.study_ID,'wager04a_princeton')) ...
        find(strcmp(df.study_ID,'hartmann')) ...
        find(strcmp(df.study_ID,'schenk20'))];
    df=df(setdiff(1:end,poscolstudies),:);
    additionalinfo='colinearity_neg';
elseif any(strcmp(varargin,'excl_colinearity_highpos'))
    poscolstudies=[ find(strcmp(df.study_ID,'lui')) ...
        find(strcmp(df.study_ID,'wager04a_princeton')) ...
        find(strcmp(df.study_ID,'hartmann')) ];
    df=df(setdiff(1:end,poscolstudies),:);
    additionalinfo='excl_colinearity_highpos';
elseif any(strcmp(varargin,'excl_wager'))
    poscolstudies=[ find(strcmp(df.study_ID,'wager04a_princeton')) ...
                    find(strcmp(df.study_ID,'wager04b_michigan')) ];
    df=df(setdiff(1:end,poscolstudies),:);
    additionalinfo='excl_wager';
elseif any(strcmp(varargin,'corrhigherthen03'))
    poscolstudies=[ find(strcmp(df.study_ID,'lui')) ...
        find(strcmp(df.study_ID,'wager04a_princeton')) ...
        find(strcmp(df.study_ID,'fehse')) ...
        find(strcmp(df.study_ID,'hartmann')) ];
    df=df(setdiff(1:end,poscolstudies),:);
    additionalinfo='corrhigherthen03';
end


nstudy=height(df);
% one can specify the dfv_masked as the first input varargin if it is
% already loaded to the environment.
if ~isempty(varargin) && any(isfield(varargin{1},'pain_placebo') & isfield(varargin{1},'anticip_placebo'))
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
    for i=1:totalnstudy
        mys.(strcat(phasetype,cons{contrast})).(string(fieldnms{i}))=gpuArray(dfv_masked.(strcat(phasetype,cons{contrast})){i,1});
    end
end
%  % Cludge necessary for parfor
clear load_a load_b

%% preallocate variables which contain the voxel level stat values 
for parameters=1:length(params)
    pval.(params{parameters}).rnd.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).rnd.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).rnd.zmaxvals=NaN(1,n_perms);
    pval.(params{parameters}).rnd.zminvals=NaN(1,n_perms);
        
    pval.(params{parameters}).fx.uncor_larger=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).fx.uncor_smaller=zeros(1,sum(dfv_masked.(strcat(phasetype,"_brainmask"))));
    pval.(params{parameters}).fx.zmaxvals=NaN(1,n_perms);
    pval.(params{parameters}).fx.zminvals=NaN(1,n_perms);

    pval.(params{parameters}).heterogeneity.zmaxvals=NaN(1,n_perms);
end

h = waitbar(0,'Permuting placebo...');
if strcmp(mycontrast,'diff')
    
    placebo_stats=placebodiff_g_cor_sum(df, mys,putamencorr,phasetype);
    summaryy=GIV_summary_BK(placebo_stats,params,putamencorr); %'g'
    
    for parameters=1:length(params)
        summaryy.(params{parameters})=smooth_SE(summaryy.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));
    end

    for p=1:n_perms 
    % Summarize the study level permuted data
        %placebo minus control - g statistics        
        curr_null_stats_voxels_placebo_g=perminfer(df, mys,placebo_stats,mycontrast,params,putamencorr,'perm',phasetype);
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo_g,params,putamencorr);  % use output-argument to only compute stats for "g" and "r_external"
        for parameters=1:length(params)
            curr_perm_summary_stats.(params{parameters})=smooth_SE(curr_perm_summary_stats.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));

            pval.(params{parameters}).rnd.uncor_larger=pval.(params{parameters}).rnd.uncor_larger+double(summaryy.(params{parameters}).random.z_smooth>curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.uncor_smaller=pval.(params{parameters}).rnd.uncor_smaller+double(summaryy.(params{parameters}).random.z_smooth<curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).rnd.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            
            pval.(params{parameters}).fx.uncor_larger=pval.(params{parameters}).fx.uncor_larger+double(summaryy.(params{parameters}).fixed.z_smooth>curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.uncor_smaller=pval.(params{parameters}).fx.uncor_smaller+double(summaryy.(params{parameters}).fixed.z_smooth<curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).fx.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            % Save statistics from heterogeneity test:
            pval.(params{parameters}).heterogeneity.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).heterogeneity.chisq);
        end
    
        waitbar(p / n_perms)
    end
    
elseif strcmp(mycontrast,'sum')
    %todo rewrite script as above
    pain_stats = pain_g_sum(df, mys,phasetype);
    summaryy=GIV_summary_BK(pain_stats,params,putamencorr);
    for parameters=1:length(params)
        summaryy.(params{parameters})=smooth_SE(summaryy.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));
    end
%     summaryy.g=smooth_SE(summaryy.g,dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     summaryy.r_external=smooth_SE(summaryy.r_external,dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     stat={'g'};

    for p=1:n_perms 
    % Summarize the study level permuted data
        %placebo minus control - g statistics        

        %     %placebo and control - g statistics
        curr_null_stats_voxels_pain=perminfer(df,mys,pain_stats,mycontrast,params,'perm',phasetype);
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_pain,params,putamencorr);  % use output-argument to only compute stats for "g" and "r_external"
        for parameters=1:length(params)
            curr_perm_summary_stats.(params{parameters})=smooth_SE(curr_perm_summary_stats.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));

            pval.(params{parameters}).rnd.uncor_larger=pval.(params{parameters}).rnd.uncor_larger+double(summaryy.(params{parameters}).random.z_smooth>curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.uncor_smaller=pval.(params{parameters}).rnd.uncor_smaller+double(summaryy.(params{parameters}).random.z_smooth<curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).rnd.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            pval.(params{parameters}).rnd.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).random.z_smooth);
            
            pval.(params{parameters}).fx.uncor_larger=pval.(params{parameters}).fx.uncor_larger+double(summaryy.(params{parameters}).fixed.z_smooth>curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.uncor_smaller=pval.(params{parameters}).fx.uncor_smaller+double(summaryy.(params{parameters}).fixed.z_smooth<curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            % Corrected for multiple comparison with FWE, using zmax stat
            pval.(params{parameters}).fx.zmaxvals(p)=max(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
            pval.(params{parameters}).fx.zminvals(p)=min(curr_perm_summary_stats.(params{parameters}).fixed.z_smooth);
        end

        waitbar(p / n_perms)
    end
elseif strcmp(mycontrast,'phasediff')

    
end
close(h) 
% toc
%% Add permuted null-distributions to statistical summary struct

summaryy.permres=pval;
summaryy.nperm=n_perms;
%r05foronesamplettest
save(fullfile(intermedpath,['WB_' phasetype '_phase_' mycontrast '_summary_' additionalinfo '_nperm' num2str(n_perms) '.mat']),...
    'summaryy','-v7.3');
%this create a very huge file, I am not sure if we need that right now...
% save(fullfile(intermedpath,['placebo_stats_' phasetype '_phase_' mycontrast '_summary_' additionalinfo '_nperm' num2str(n_perms) '.mat']),...
%     'placebo_stats','-v7.3')
