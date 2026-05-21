function stats=g_perminfer(df,dfv,varargin)
% This function calculate one stat image from all the studies.
% 3 types of studies should be differentiated: 
%   1. within-subject design stuides(most of them)
%   2. between-subject studies (2of them: 10,14)
%   3. study with contrast img only(2of them: 17,20)
% find(df.contrast_imgs_only)
% find(~df.contrast_imgs_only)
% find(df.study_design=="between")
% gpuplac,gpucon,studysubjingpumatrix,studix
% It uses only gpu data. The inputs must be gpuArrays.
if any(strcmp(varargin,'pain'))
    cons={'pain_placebo','pain_control','pain_placebo_minus_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within'));
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between'));
    conOnly=find(df.contrast_imgs_only==1);
elseif any(strcmp(varargin,'anticipation'))
    cons={'anticip_pain_placebo','anticip_pain_control','anticip_placebo_minus_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.modeled_anticipationphase==1);
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.modeled_anticipationphase==1);
    conOnly=find(df.contrast_imgs_only==1 & df.modeled_anticipationphase==1);
end
% they use a bit different children functions to caluclate the voxelwise
% statistics.
% The function returns a stat structurw which contine images(many-many
% voxels about the below listed parameters.

%Preallocate stats for speed
n_studies=size(df,1);
% n_voxel=sum(dfv.brainmask);
% stats(n_studies).mu=[];
% stats(n_studies).sd_diff=[];
% stats(n_studies).sd_pooled=[];
% stats(n_studies).se_mu=[];
stats(n_studies).n=[];
stats(n_studies).r=[];
% stats(n_studies).d=[];
% stats(n_studies).se_d=[];
stats(n_studies).g=[];
stats(n_studies).se_g=[];
stats(n_studies).delta=[];
% stats(n_studies).std_delta=[];
% stats(n_studies).ICC=[];
% stats(n_studies).r_external=[];
% stats(n_studies).n_r_external=[];

% stats.n=n_studies,[];
% stats(n_studies).r=[];
% 
% stats(n_studies).g=[];
% stats(n_studies).se_g=[];


%% Voxel-by-voxel bold response change due to placebo condition
for studyrank=within_nonCon'
    
    if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
        curr_n=size(dfv.(cons{1}).(df.study_ID{studyrank}),1);
        relabel=logical(random('Discrete Uniform',2,curr_n,1)-1); % randomly generate 0 or 1 to invert contrasts

        pla=vertcat(dfv.(cons{1}).(df.study_ID{studyrank})(relabel,:),...
                                        dfv.(cons{2}).(df.study_ID{studyrank})(~relabel,:));
        %todo check if the permutation is good!(mistake previously
        %observed)
        %this is the good permutation
        con=vertcat(dfv.(cons{2}).(df.study_ID{studyrank})(relabel,:),...
                                        dfv.(cons{1}).(df.study_ID{studyrank})(~relabel,:));
        %this is the bad permutation
%         con=vertcat(dfv.(cons{1}).(df.study_ID{studyrank})(~relabel,:),...
%                                                 dfv.(cons{2}).(df.study_ID{studyrank})(relabel,:));
    else % Actual statistic

        pla=dfv.(cons{1}).(df.study_ID{studyrank});
%         mys.pain_control.(ans)
        con=dfv.(cons{2}).(df.study_ID{studyrank});
    end
    stats(studyrank)=summarize_within_BK(pla,con);
end
for studyrank=between_nonCon'
    if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
       sample=vertcat(dfv.(cons{1}).(df.study_ID{studyrank}),dfv.(cons{2}).(df.study_ID{studyrank})); %pool groups
       sample=sample(randperm(size(sample,1)),:); %shuffle groups
       pla=sample(1:size(dfv.(cons{1}).(df.study_ID{studyrank}),1),:);
       con=sample(size(dfv.(cons{1}).(df.study_ID{studyrank}),1)+1:end,:);   
    else    
        pla=dfv.(cons{1}).(df.study_ID{studyrank});
        con=dfv.(cons{2}).(df.study_ID{studyrank});
    end
   stats(studyrank)=summarize_between_BK(pla,con); % no subjects had to be excluded for between-group studies
end
% Calculate for those (within-subject) studies where only pla>con contrasts are available

impu_r=mean([stats.r],'omitnan'); % ... impute the mean within-subject study correlation observed in all other studies
for studyrank=conOnly'
    if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
        curr_n=size(dfv.(cons{3}).(df.study_ID{studyrank}),1);
        relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
        pla=dfv.(cons{3}).(df.study_ID{studyrank}).*relabel;
    else
        pla=dfv.(cons{3}).(df.study_ID{studyrank});
    end
    stats(studyrank)=summarize_within_BK(pla,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

end