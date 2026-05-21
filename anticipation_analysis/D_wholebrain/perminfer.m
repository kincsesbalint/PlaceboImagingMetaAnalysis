function stats=perminfer(df,dfv,origstat,mycontrast,params,putamencorr,varargin)
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
    cons={'pain_placebo','pain_control','pain_placebo_minus_control','pain_placebo_and_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within'));
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between'));
    conOnly=find(df.contrast_imgs_only==1);
elseif any(strcmp(varargin,'anticip'))
    cons={'anticip_placebo','anticip_control','anticip_placebo_minus_control','anticip_placebo_and_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.anticipismodeled==1);
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.anticipismodeled==1);
    conOnly=find(df.contrast_imgs_only==1 & df.anticipismodeled==1);
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
stats(n_studies).r_external=[];
stats(n_studies).n_r_external=[];
stats(n_studies).pla=[];
stats(n_studies).contr=[];


% stats.n=n_studies,[];
% stats(n_studies).r=[];
% 
% stats(n_studies).g=[];
% stats(n_studies).se_g=[];

if any(strcmp(mycontrast,'diff'))
    if any(strcmp(params,'g'))
    
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
                %this is the bad permutation:
%                 con=vertcat(dfv.(cons{1}).(df.study_ID{studyrank})(~relabel,:),...
%                                                         dfv.(cons{2}).(df.study_ID{studyrank})(relabel,:));
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
               nplacgr=size(dfv.(cons{1}).(df.study_ID{studyrank}),1);
               ncongr=size(dfv.(cons{2}).(df.study_ID{studyrank}),1);
               relabelbtw=randperm(size(sample,1));
               sample_perm=sample(relabelbtw,:); %shuffle groups
               pla=sample_perm(1:nplacgr,:);
               con=sample_perm(nplacgr+1:end,:);   
            else    
                pla=dfv.(cons{1}).(df.study_ID{studyrank});
                con=dfv.(cons{2}).(df.study_ID{studyrank});
            end
           stats(studyrank)=summarize_between_BK(pla,con); % no subjects had to be excluded for between-group studies
        end
        % Calculate for those (within-subject) studies where only pla>con contrasts are available
        
        impu_r=mean([stats.r],'omitnan'); % ... impute the mean within-subject study correlation observed in all other studies. 
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
    %% Correlation of behavioral effect and voxel-by-voxel bold response
    if any(strcmp(params,'r_external'))
        for studyrank=1:length(origstat) %stats
            if any(strcmp(varargin,'conservative'))
                ex_subj=df.subjects{studyrank}.excluded;
            else
                ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %we include all the participants, no exclusion
            end
            if ~isempty(origstat(studyrank).delta) && df.anticipismodeled(studyrank) % necessary as "sum" returns 0 for [] for some stupid reason
                % with this condition we should only exclude between subject studies (2of them)
                %todo double check if we really only take into account these
                %studies(non between subject)
                
                if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
                    % Original permutation:
                    % For voxel only the sign of effect has been permuted above.
                    % So in respect to the correlation of voxel signal and ratings, data are
                    % not fully randomized.
                    % Just to make sure we have a completely random null-distribution in
                    % respect to correlations, we shuffle ratings as well.
                    % New permutation:
                    % Using the original delta values and shuffles only the
                    % rating values. This is how I would implement it (see
                    % eg:
                    % https://dgarcia-eu.github.io/SocialDataScience/5_SocialNetworkPhenomena/056_PermutationTests/PermutationTests)

                    activity=origstat(studyrank).delta;
%                     ratings=shuffles(df.GIV_stats_rating(studyrank).delta); 
        %             souble check this: this is not working strangly now,but
        %             worked previously...this ithe orignal one used by MZ
                    if putamencorr==0 || putamencorr==99
                        ratings=Shuffle(df.GIV_stats_rating(studyrank).delta); 
                        ratings=ratings(~ex_subj,:);
                    elseif putamencorr==1
                        ratings=Shuffle(df.putamensctivation{studyrank});
                    end
                end
                if putamencorr==99
                    stats(studyrank).r_external=fastcorrcoef_quadratic_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
                    stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                                     isnan(ratings))); % AND non nan-ratings
                else

                    stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
                    stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                                     isnan(ratings))); % AND non nan-ratings
                end


            else
                stats(studyrank).r_external=[];%NaN(1,n_voxel);
                stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
            end
        end
    end
elseif any(strcmp(mycontrast,'sum'))
    if any(strcmp(varargin,'pain'))
%         cons={'pain_placebo','pain_control','pain_placebo_minus_control','pain_placebo_and_control'};
        focusstudies=find(df.painismodeled==1 & ~strcmp(df.study_ID,'koban'));
    elseif any(strcmp(varargin,'anticip'))
%         cons={'anticip_pain_placebo','anticip_pain_control','anticip_placebo_minus_control','anticip_placebo_and_control'};
        focusstudies=find(df.anticipismodeled==1);    
    end
    
    
    for i=focusstudies'
        curr_n=size(dfv.(cons{4}).(df.study_ID{i}),1);
        relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
        plaandcontr=dfv.(cons{4}).(df.study_ID{i}).*relabel;
%         plaandcontr=dfv.(cons{4}).(df.study_ID{i});
        stats(i)=summarize_within_BK(plaandcontr,0); % Pain vs baseline contrast within subjects (one-sample test) 
%         stats(i)=summarize_within_BK(plaandcontr,0.5); % Pain vs baseline contrast within subjects (one-sample test) 
    end
    %% Correlation of behavioral effect and voxel-by-voxel bold response
    for studyrank=1:length(origstat) %stats
        if any(strcmp(varargin,'conservative'))
            ex_subj=df.subjects{studyrank}.excluded;
        else
            ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded)));
        end
        if ~isempty(origstat(studyrank).delta) && ~isempty(df.GIV_stats_rating(studyrank).delta) % necessary as "sum" returns 0 for [] for some stupid reason
            % with this condition we should only exclude between subject studies (2of them)
            %todo double check if we really only take into account these
            %studies(non between subject)
            
            if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
                % Original was to shuffle both the rating and the brain
                % acitivity.
                % For voxel only the sign of effect has been permuted above.
                % So in respect to the correlation of voxel signal and ratings, data are
                % not fully randomized.
                % Just to make sure we have a completely random null-distribution in
                % respect to correlations, we shuffle ratings as well.
                % new solution si to shuffles only the ratings:
                activity=origstat(studyrank).delta;
%                 ratings=shuffles(df.GIV_stats_rating(studyrank).delta); 
                ratings=Shuffle(df.GIV_stats_rating(studyrank).delta); 
                
                ratings=ratings(~ex_subj,:);
            end
            stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
            stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                                 isnan(ratings))); % AND non nan-ratings
        else
            stats(studyrank).r_external=[];%NaN(1,n_voxel);
            stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
        end
    end
end