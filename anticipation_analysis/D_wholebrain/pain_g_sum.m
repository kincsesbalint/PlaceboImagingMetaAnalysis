function stats=pain_g_sum(df,dfv,varargin)
% This function calculates one stat image (placebo+control) for all the studies.
% These statistical images will be summarized with another function(see
% GIV_summary)
% 3 types of studies should be differentiated: 
%   1. within-subject design stuides(most of them)
%   2. between-subject studies (2of them: 10,14)
%   3. study with contrast img only(2of them: 17,20)

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
stats(n_studies).pla=[];
stats(n_studies).contr=[];

if any(strcmp(varargin,'pain'))
    cons={'pain_placebo','pain_control','pain_placebo_minus_control','pain_placebo_and_control'};
    focusstudies=find(df.painismodeled==1 & ~strcmp(df.study_ID,'koban')); %the koban study has no placebo and control condition provided. 
    %todo double check if we have something pain maps for the koban study
elseif any(strcmp(varargin,'anticip'))
    cons={'anticip_pain_placebo','anticip_pain_control','anticip_placebo_minus_control','anticip_placebo_and_control'};
    focusstudies=find(df.anticipismodeled==1);    
end


for i=focusstudies'
     
    plaandcontr=dfv.(cons{4}).(df.study_ID{i});
    stats(i)=summarize_within_BK(plaandcontr,0); % Pain vs baseline contrast within subjects (one-sample test) (average of control and placebo)
%     stats(i)=summarize_within_BK(plaandcontr,0.5); % Pain vs baseline contrast within subjects (one-sample test) (average of control and placebo)
end


%% Correlation of behavioral effect and voxel-by-voxel bold response
for studyrank=1:length(stats) %stats
    if any(strcmp(varargin,'conservative'))
        ex_subj=df.subjects{studyrank}.excluded;
    else
        ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %only the pain_placebo field was populated with this information.maybe we think about to include this in a separate field...
    end
    if ~isempty(stats(studyrank).delta) && ~isempty(df.GIV_stats_rating(studyrank).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        % with this condition we should only exclude between subject studies (2of them)
        activity=stats(studyrank).delta; %this is pain vs baseline (placebo+control average) as the summarize within was only populated with the averege signal activity
        ratings=df.GIV_stats_rating(studyrank).delta(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
        %
        stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
        stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(ratings))); % AND non nan-ratings
    else
        stats(studyrank).r_external=[];%NaN(1,n_voxel);
        stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
    end
end
end
