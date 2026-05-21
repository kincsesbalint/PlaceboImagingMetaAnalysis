function summaryy=Z_summary_and_statisticalinference_phasediff(intermedpath,n_perms,phasetype,mycontrast,params,varargin)
%%specify impotant variables

%% Load necessary files
% Original data frame with all the metadata based on the argument
load_b=load(fullfile(intermedpath,'data_frame'),'df');
df=load_b.df;
fieldnms=df.study_ID;
nstudy=height(df);
additionalinfo='';
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
end
% one can specify the dfv_masked as the first input varargin if it is
% already loaded to the environment.
if any(strcmp(fieldnames(varargin{1}),'pain_placebo')) && any(strcmp(fieldnames(varargin{1}),'anticip_placebo'))
    dfv_masked=varargin{1};
else
    load_a=load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
    dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor

end
phasetypes=["pain","anticip"];
if strcmp(mycontrast,'placebo')
    cons={'_placebo'};
elseif strcmp(mycontrast,'control')
    cons={'_control'};
elseif strcmp(mycontrast,'diff')
    cons={'_placebo','_control','_placebo_minus_control'};
elseif strcmp(mycontrast,'sum')
    cons={'_placebo_and_control'};
end
%cons={'_placebo','_control','_placebo_minus_control','_placebo_and_control'};
% put all the data on the gpu
for phase=1:length(phasetypes)
    for contrast=1:length(cons)
        for i=1:nstudy
            mys.(strcat(phasetypes(phase),cons{contrast})).(string(fieldnms{i}))=gpuArray(dfv_masked.(strcat(phasetypes(phase),cons{contrast})){i,1});
        end
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
end

h = waitbar(0,'Permuting placebo...');
if strcmp(mycontrast,'placebo')
    placebo_stats=phaseddiff(df, mys,mycontrast);
    summaryy=GIV_summary_BK(placebo_stats,params,0); %'g' %last number is for pooling the standardise indirect effect in the mediation analysis
%     for parameters=1:length(params)
%         summaryy.(params{parameters})=smooth_SE(summaryy.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));
%     end
elseif strcmp(mycontrast,'control')
    placebo_stats=phaseddiff(df, mys,mycontrast);
    summaryy=GIV_summary_BK(placebo_stats,params,0);
elseif strcmp(mycontrast,'diff')
    placebo_stats=phaseddiff(df, mys,mycontrast);
    summaryy=GIV_summary_BK(placebo_stats,params,0); %'g'
    for parameters=1:length(params)
        summaryy.(params{parameters})=smooth_SE(summaryy.(params{parameters}),dfv_masked.(strcat(phasetype,"_brainmask3d")));
    end

    for p=1:n_perms 
    % Summarize the study level permuted data
        %placebo minus control - g statistics        
        curr_null_stats_voxels_placebo_g=phaseddiff_perm(df, mys,placebo_stats,mycontrast,params,'perm',phasetype);
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_placebo_g,params,0);  % use output-argument to only compute stats for "g" and "r_external"
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
    
elseif strcmp(mycontrast,'sum')
    %todo rewrite script as above
    pain_stats = pain_g_sum(df, mys,phasetype);
    summaryy=GIV_summary_BK(pain_stats,params,0);
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
        curr_perm_summary_stats=GIV_summary_BK(curr_null_stats_voxels_pain,params,0);  % use output-argument to only compute stats for "g" and "r_external"
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
end
close(h) 

summaryy.permres=pval;
summaryy.nperm=n_perms;
save(fullfile(intermedpath,['WB_' phasetype '_phase_' mycontrast '_summary_' additionalinfo '.mat']),... 
    'summaryy','-v7.3'); % output file was placvontroldiff1lvl