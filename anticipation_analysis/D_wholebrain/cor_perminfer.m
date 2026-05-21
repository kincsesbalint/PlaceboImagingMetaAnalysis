function stats=cor_perminfer(df,stats,varargin)
% This function calculates the correlation between voxel intensity difference
% and rating difference. In the previous solution, the delta values
% differed from permutaion to permutation, however, I only intend to
% shuffle the ratings and not the (brain activation) deltas.
% 
% We do the calculation only on the within-subject design studies.
% 
% 
if any(strcmp(varargin,'pain'))
    cons={'pain_placebo','pain_control','pain_placebo_minus_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within'));
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between'));
    conOnly=find(df.contrast_imgs_only==1);
elseif any(strcmp(varargin,'anticip'))
    cons={'anticip_pain_placebo','anticip_pain_control','anticip_placebo_minus_control'};
    within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.modeled_anticipationphase==1);
    between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.modeled_anticipationphase==1);
    conOnly=find(df.contrast_imgs_only==1 & df.modeled_anticipationphase==1);
end

%% Correlation of behavioral effect and voxel-by-voxel bold response
for studyrank=1:length(stats) %stats
    if any(strcmp(varargin,'conservative'))
        ex_subj=df.subjects{studyrank}.excluded;
    else
        ex_subj=zeros((size(df.(cons{1}){studyrank}.excluded)));
    end
    if ~isempty(stats(studyrank).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        % with this condition we should only exclude between subject studies (2of them)
        %todo double check if we really only take into account these
        %studies(non between subject)
        
        if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
            % For voxel only the sign of effect has been permuted above.
            % So in respect to the correlation of voxel signal and ratings, data are
            % not fully randomized.
            % Just to make sure we have a completely random null-distribution in
            % respect to correlations, we shuffle ratings as well.
            activity=stats(studyrank).delta;
            ratings=shuffles(df.GIV_stats_rating(studyrank).delta); %todo
%             souble check this: this is not working strangly now,but
%             worked previously...this ithe orignal one used by MZ
%             ratings=Shuffle(df.GIV_stats_rating(studyrank).delta); 
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
