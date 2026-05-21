function stats=placebodiff_g_cor_sum(df,dfv,putamencorr,varargin)
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
%mediation analysis
if putamencorr==1
    mediationstats(n_studies).a_est=[];
    mediationstats(n_studies).a_est_se=[];
    mediationstats(n_studies).b_est=[];
    mediationstats(n_studies).b_est_se=[];
end
%% Voxel-by-voxel bold response change due to placebo condition - placebo minus control
%This is done for each study separately ("first level analysis"), the
%output stats will be pooled to get a summary stat eventually.
for studyrank=within_nonCon'
    pla=dfv.(cons{1}).(df.study_ID{studyrank});
    con=dfv.(cons{2}).(df.study_ID{studyrank});
    stats(studyrank)=summarize_within_BK(pla,con);
end
for studyrank=between_nonCon'
    pla=dfv.(cons{1}).(df.study_ID{studyrank});
    con=dfv.(cons{2}).(df.study_ID{studyrank});
    stats(studyrank)=summarize_between_BK(pla,con); % no subjects had to be excluded for between-group studies
end
% Calculate for those (within-subject) studies where only pla>con contrasts
% are available
impu_r=mean([stats.r],'omitnan'); % ... impute the mean within-subject study correlation observed in all other studies
% tmp_r_matrix=vertcat(stats(:).r);
% impu_r=mean(tmp_r_matrix,'omitnan');
%impute on voxel level and not mean voxel level.
for studyrank=conOnly'
    pla=dfv.(cons{3}).(df.study_ID{studyrank});
    stats(studyrank)=summarize_within_BK(pla,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

%% placebo and control condition


%% Correlation of behavioral effect and voxel-by-voxel bold response
if putamencorr==0 %correlation with ratings
    for studyrank=1:length(stats) %stats
        if any(strcmp(varargin,'conservative'))
            ex_subj=df.subjects{studyrank}.excluded;
        else
            ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %only the pain_placebo field was populated with this information.maybe we think about to include this in a separate field...
        end
        if ~isempty(stats(studyrank).delta) %&& ~isempty(stats(studyrank).pla)% necessary as "sum" returns 0 for [] for some stupid reason
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
elseif putamencorr==1 %correlation with putamen anticipatory activity
    stats(n_studies).ab_stand=[];
    stats(n_studies).se_stand_sobel=[];
%     stats(n_studies).b_est=[];
%     stats(n_studies).b_est_se=[];
        for studyrank=1:length(stats) %stats

        if any(strcmp(varargin,'conservative'))
            ex_subj=df.subjects{studyrank}.excluded;
        else
            ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %only the pain_placebo field was populated with this information.maybe we think about to include this in a separate field...
        end
        if ~isempty(stats(studyrank).delta) && df.anticipismodeled(studyrank) %%~isempty(stats(studyrank).pla)% necessary as "sum" returns 0 for [] for some stupid reason
            % with this condition we should only exclude between subject studies (2of them)
            missingsubj=sum(isnan(stats(studyrank).delta),1);
            %onl the second level PPI
            brainactivity_m=stats(studyrank).delta; %this is also placebo-control delta, as it was specified in this order above in the summary_within arguments.
  
            %un/comment this part for mediation analysis

            putplacact_x=df.putamensctivation{studyrank}; %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
            stats(studyrank).r_external=fastcorrcoef_BK(brainactivity_m,gpuArray(putplacact_x),'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
            stats(studyrank).n_r_external=sum(~(isnan(brainactivity_m)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                                 isnan(putplacact_x))); % AND non nan-ratings

            brainactivity_m=gather(brainactivity_m); %this is also placebo-control delta, as it was specified in this order above in the summary_within arguments.

            %comment this part
            involvedvox=brainactivity_m(:,missingsubj<5);
            involvedvox_id=find(missingsubj<5);
            n_voxels=length(stats(studyrank).delta);
            
            a_est=NaN(1,n_voxels);
            a_est_se=NaN(1,n_voxels);
            b_est=NaN(1,n_voxels);
            b_est_se=NaN(1,n_voxels);
            
            involved_voxels=length(involvedvox);
            a_est_inv=NaN(1,involved_voxels);
            a_est_se_inv=NaN(1,involved_voxels);
            b_est_inv=NaN(1,involved_voxels);
            b_est_se_inv=NaN(1,involved_voxels);
    %         activity=stats(studyrank).pla;
    %         activity=stats(studyrank).contr;
            rating_behav_y=df.GIV_stats_rating(studyrank).delta(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
            


            % todo double check above the ~ex_subj part
            parfor voxels=1:involved_voxels%n_voxels
            %mediation analysis with rating as the outcome
                %todo optimize here the parfor loop
                mod1=fitlm(putplacact_x,brainactivity_m(:,involvedvox_id(voxels)));
                a_est_inv(voxels)=mod1.Coefficients("x1",:).Estimate;
                a_est_se_inv(voxels)=mod1.Coefficients("x1",:).SE;
            
                mod2=fitlm(horzcat(putplacact_x,brainactivity_m(:,involvedvox_id(voxels))),rating_behav_y);
                b_est_inv(voxels)=mod2.Coefficients("x2",:).Estimate;
                b_est_se_inv(voxels)=mod2.Coefficients("x2",:).SE;
            end
            %one can do the standardization here:
                a_est(missingsubj<5)=a_est_inv;
                a_est_se(missingsubj<5)=a_est_se_inv;
                b_est(missingsubj<5)=b_est_inv;
                b_est_se(missingsubj<5)=b_est_se_inv;
                varratio=(sqrt(a_est_se)./sqrt(b_est_se));
                ab_stand=a_est.*b_est.*varratio;
                % fit_model = @(Y) fitlm(x_gpu, Y{1}, 'linear');
                se_ab=sqrt((a_est.^2.*a_est_se.^2)+(b_est.^2.*b_est_se.^2));
                se_stand_sobel=varratio.*se_ab;

                stats(studyrank).ab_stand=ab_stand;
                stats(studyrank).se_stand_sobel=se_stand_sobel;
            
%                 stats(studyrank).b_est=b_est;
%                 stats(studyrank).b_est_se=b_est_se;
        else
            stats(studyrank).r_external=[];%NaN(1,n_voxel);
            stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
        end
        end
elseif putamencorr==99 %this is just the dummy coding of calculating a quadratic assocaition between rating and brain activation
    for studyrank=1:length(stats) %stats
        if any(strcmp(varargin,'conservative'))
            ex_subj=df.subjects{studyrank}.excluded;
        else
            ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %only the pain_placebo field was populated with this information.maybe we think about to include this in a separate field...
        end
        if ~isempty(stats(studyrank).delta) %&& ~isempty(stats(studyrank).pla)% necessary as "sum" returns 0 for [] for some stupid reason
            % with this condition we should only exclude between subject studies (2of them)
            activity=stats(studyrank).delta; %this is also placebo-control delta, as it was specified in this order above in the summary_within arguments.
    %         activity=stats(studyrank).pla;
    %         activity=stats(studyrank).contr;
            ratings=df.GIV_stats_rating(studyrank).delta(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
            % todo double check above the ~ex_subj part
            stats(studyrank).r_external=fastcorrcoef_quadratic_BK(activity,ratings,'exclude_nan'); % as this is a quadratic model estimation, ...
            stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                                 isnan(ratings))); % AND non nan-ratings
        else
            stats(studyrank).r_external=[];%NaN(1,n_voxel);
            stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
        end
    end
end
    
end