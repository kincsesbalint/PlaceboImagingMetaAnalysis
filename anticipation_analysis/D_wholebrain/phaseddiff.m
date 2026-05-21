function stats=phaseddiff(df,dfv,varargin)
% This function calculates one stat image (placebo-control) for each study.
% These statistical images will be summarized with another function(see
% GIV_summary)
% 3 types of studies should be differentiated: 
%   1. within-subject design stuides(most of them)
%   2. between-subject studies (2of them: 10,14)
%   3. study with contrast img only(2of them: 17,20)
% 
% Balint Kincses
% balint.kincses@uk-essen.de
% 2023

if any(strcmp(varargin,'placebo'))
    cons={'anticip_placebo','pain_placebo'};
    nonCon=find(df.contrast_imgs_only==0 & df.anticipismodeled==1);
    conOnly=[];%find(df.contrast_imgs_only==1 & df.anticipismodeled==1);
elseif any(strcmp(varargin,'control'))
    cons={'anticip_control','pain_control'};
    nonCon=find(df.contrast_imgs_only==0 & df.anticipismodeled==1);
    conOnly=[];%find(df.contrast_imgs_only==1 & df.anticipismodeled==1);
elseif any(strcmp(varargin,'diff'))
    cons={'anticip_placebo','pain_placebo', ...
        'anticip_control','pain_control',...
        'anticip_placebo_minus_control','pain_placebo_minus_control'};
    nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.anticipismodeled==1);
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.anticipismodeled==1);
    conOnly=find(df.contrast_imgs_only==1 & df.anticipismodeled==1);
elseif any(strcmp(varargin,'placebo_and_control'))
    cons={'anticip_control','pain_control','anticip_placebo_minus_control','anticip_placebo_and_control'};

end


%Preallocate stats for speed
% there are much more variables as an output of the summarize_...
% funcitons, however, as we would like to use the same outputs as in the
% previous analysis I would rather focus on the previous outcomes and do
% not save the rest.
n_studies=size(df,1);
% stats(n_studies).avg=[];
stats(n_studies).n=[];
stats(n_studies).r=[];
stats(n_studies).g=[];
stats(n_studies).se_g=[];
stats(n_studies).delta=[];
stats(n_studies).r_external=[];
stats(n_studies).n_r_external=[];
%added for posthoc calculations
stats(n_studies).pla=[];
stats(n_studies).contr=[];
stats_maki=stats;
%% Voxel-by-voxel bold response change due to placebo condition - placebo minus control
%This is done for each study separately ("first level analysis"), the
%output stats will be pooled to get a summary stat eventually.

for studyrank=nonCon'
    if any(strcmp(varargin,'diff'))
        plac=dfv.(cons{1}).(df.study_ID{studyrank})-dfv.(cons{2}).(df.study_ID{studyrank});
        contr=dfv.(cons{3}).(df.study_ID{studyrank})-dfv.(cons{4}).(df.study_ID{studyrank});
%         anticip=dfv.(cons{1}).(df.study_ID{studyrank})-dfv.(cons{3}).(df.study_ID{studyrank});
%         pain=dfv.(cons{2}).(df.study_ID{studyrank})-dfv.(cons{4}).(df.study_ID{studyrank});
        stats(studyrank)=summarize_within_BK(plac,contr);
%         stats(studyrank)=summarize_within_BK(anticip,pain);
        
    else
        anticip=dfv.(cons{1}).(df.study_ID{studyrank});
        pain=dfv.(cons{2}).(df.study_ID{studyrank});
        stats(studyrank)=summarize_within_BK(anticip,pain);
    end
end
for studyrank=between_nonCon'
    pla=dfv.(cons{1}).(df.study_ID{studyrank})-dfv.(cons{2}).(df.study_ID{studyrank});
    con=dfv.(cons{3}).(df.study_ID{studyrank})-dfv.(cons{4}).(df.study_ID{studyrank});
    %this cannot work as this is a between subjects design.
%     anticp=dfv.(cons{1}).(df.study_ID{studyrank})-dfv.(cons{3}).(df.study_ID{studyrank});
%     pain=dfv.(cons{2}).(df.study_ID{studyrank})-dfv.(cons{4}).(df.study_ID{studyrank});
    stats(studyrank)=summarize_between_BK(pla,con); % no subjects had to be excluded for between-group studies
%     stats(studyrank)=summarize_between_BK(anticip,pain); % no subjects had to be excluded for between-group studies
end
% Calculate for those (within-subject) studies where only pla>con contrasts
% are available
impu_r=mean([stats.r],'omitnan'); % ... impute the mean within-subject study correlation observed in all other studies
% tmp_r_matrix=vertcat(stats(:).r);
% impu_r=mean(tmp_r_matrix,'omitnan');
%impute on voxel level and not mean voxel level.
for studyrank=conOnly'
%     pla=dfv.(cons{3}).(df.study_ID{studyrank});
    anticip=dfv.(cons{5}).(df.study_ID{studyrank});
    pain=dfv.(cons{6}).(df.study_ID{studyrank});
%     stats(studyrank)=summarize_within_BK(anticip,pain);
    stats(studyrank)=summarize_within_BK(anticip-pain,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

%% placebo and control condition


%% Correlation of behavioral effect and voxel-by-voxel bold response
for studyrank=1:length(stats) %stats
    if any(strcmp(varargin,'conservative'))
        ex_subj=df.subjects{studyrank}.excluded;
    else
        ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %only the pain_placebo field was populated with this information.maybe we think about to include this in a separate field...
    end
    if ~isempty(stats(studyrank).delta) && strcmp(df.study_design(studyrank),'within')%&& ~isempty(stats(studyrank).pla)% necessary as "sum" returns 0 for [] for some stupid reason
        % with this condition we should only exclude between subject studies (2of them)
        activity=stats(studyrank).delta; %this is also placebo-control delta, as it was specified in this order above in the summary_within arguments.
%         activity=stats(studyrank).pla;
%         activity=stats(studyrank).contr;
        ratings=df.GIV_stats_rating(studyrank).delta(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
        % todo double check above the ~ex_subj part
        stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
        stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(ratings))); % AND non nan-ratings
    else
        stats(studyrank).r_external=[];%NaN(1,n_voxel);
        stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
    end
end
end