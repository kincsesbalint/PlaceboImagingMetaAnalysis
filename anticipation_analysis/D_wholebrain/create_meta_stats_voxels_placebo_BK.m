function stats=create_meta_stats_voxels_placebo_BK(df,dfv,varargin)
% This function calculate one stat image from all the studies.
% 3 types of studies should be differentiated: 
%   1. within-subject design stuides(most of them)
%   2. between-subject studies (2of them)
%   3. study with contrast img only(1within study)
% find(df.contrast_imgs_only)
% find(~df.contrast_imgs_only)
% find(df.study_design=="between")
% gpuplac,gpucon,studysubjingpumatrix,studix

% they use a bit different children functions to caluclate the voxelwise
% statistics.
% The function returns a stat structurw which contine images(many-many
% voxels about the below listed parameters.

%Preallocate stats for speed
n_studies=size(df,1);
n_voxel=sum(dfv.brainmask);
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
% stats(n_studies).delta=[];
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

%what if we perform at the beginning a gpuarray conversion for the whole
%structure(we need to reshape the structure into a huge matrix,and work the
%rows separatley(those would be the studyrank variable))
%within design

% for study=1:length(studysubjingpumatrix)-1
%     if any(study==studix.within)
% %     studyrank=withinsubjdes(study);
%     % Actual statistic
% %     planongpu=dfv.pain_placebo{studyrank};
% %     connongpu=dfv.pain_control{studyrank};
%         pla=gpuplac(studysubjingpumatrix(study)+1:studysubjingpumatrix(study+1),:);
%         con=gpucon(studysubjingpumatrix(study)+1:studysubjingpumatrix(study+1),:);
%         
%     %     curr_n=size(dfv.pain_placebo{studyrank},1);
%         if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
%             
%             relabel=logical(random('Discrete Uniform',2,height(pla),1)-1); % randomly generate 0 or 1 to invert contrasts
%             %I think this solution result in a pessimistic 0
%             %distribution:
%             pla=vertcat(pla(relabel,:),...
%                                             con(~relabel,:));
%             con=vertcat(pla(~relabel,:),...
%                                             con(relabel,:));                            
%             %Instead of this maybe this result in a bit better 0
%             %distribution todo: double check with Tamas
%         %                 plamas=dfv.pain_placebo{studyrank};
%         %                 plamas(~relabel,:)=dfv.pain_control{studyrank}(~relabel,:);
%         %                 conmas=dfv.pain_control{studyrank};
%         %                 conmas(~relabel,:)=dfv.pain_placebo{studyrank}(~relabel,:);
% %             stats(study)=summarize_within_BK(pla_perm,con_perm);
%             
%         end
%         stats(study)=summarize_within_BK(pla,con);
%         %             tic
%         
%     %            toc
% %between design
%     elseif any(study==studix.between)
% %         for study=1:length(betweensubjdes)
% %             studyrank=betweensubjdes(study);
%             pla=gpuplac(studysubjingpumatrix(study)+1:studysubjingpumatrix(study+1),:);
%             con=gpucon(studysubjingpumatrix(study)+1:studysubjingpumatrix(study+1),:);
%         %     pla=dfv.pain_placebo{studyrank};
%         %         con=dfv.pain_control{studyrank};
%             if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
%                sample=vertcat(pla,con); %pool groups
%                sample=sample(randperm(size(sample,1)),:); %shuffle groups
%                pla=sample(1:size(pla,1),:);
%                con=sample(size(con,1)+1:end,:);   
%             else    
%                 
%             end
%            stats(study)=summarize_between_BK(pla,con); % no subjects had to be excluded for between-group studies
% %         end
%     elseif any(study==studix.contrastonly)
%         % Calculate for those (within-subject) studies where only pla>con contrasts are available
% %         conOnly=find(df.contrast_imgs_only==1);
% %         impu_r=mean([stats.r]); % ... impute the mean within-subject study correlation observed in all other studies
% %         for studyrank=conOnly'
% %             if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
% %                 curr_n=size(dfv.placebo_minus_control{studyrank},1);
% %                 relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
% %                 pla=dfv.placebo_minus_control{studyrank}.*relabel;
% %             else
% %                 pla=dfv.placebo_minus_control{studyrank};
% %             end
% %             stats(studyrank)=summarize_within(pla,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
% %         end
%     end
if any(strcmp(varargin,'gpu'))
    gpuon='gpu';
else
    gpuon=[];
end
for studyrank=1:size(df,1) % Calculate for all studies except...
    if  df.contrast_imgs_only(studyrank)==0 %...data-sets where only contrasts are available
        if strcmp(df.study_design{studyrank}, 'within') %Calculate within-subject studies
            if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
                curr_n=size(dfv.pain_placebo{studyrank},1);
                relabel=logical(random('Discrete Uniform',2,curr_n,1)-1); % randomly generate 0 or 1 to invert contrasts
                %I think this solution result in a pessimistic 0
                %distribution:
%                 pla=vertcat(dfv.pain_placebo{studyrank}(relabel,:),...
%                                                 dfv.pain_control{studyrank}(~relabel,:));
%                 con=vertcat(dfv.pain_placebo{studyrank}(~relabel,:),...
%                                                 dfv.pain_control{studyrank}(relabel,:));                            
                %Instead of this maybe this result in a bit better 0
                %distribution 
                %it seems this solution shuffles only between participants
                pla=vertcat(dfv.pain_placebo{studyrank}(relabel,:),...
                                                dfv.pain_control{studyrank}(~relabel,:));
                con=vertcat(dfv.pain_control{studyrank}(relabel,:),...
                                                dfv.pain_placebo{studyrank}(~relabel,:));
            else % Actual statistic
                pla=dfv.pain_placebo{studyrank};
                con=dfv.pain_control{studyrank};
            end
%             tic
           stats(studyrank)=summarize_within_BK(pla,con,gpuon);
%            toc
        elseif strcmp(df.study_design{studyrank}, 'between') %Calculate between-group studies
            if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
               sample=vertcat(dfv.pain_placebo{studyrank},dfv.pain_control{studyrank}); %pool groups
               sample=sample(randperm(size(sample,1)),:); %shuffle groups
               pla=sample(1:size(dfv.pain_placebo{studyrank},1),:);
               con=sample(size(dfv.pain_placebo{studyrank},1)+1:end,:);   
            else    
                pla=dfv.pain_placebo{studyrank};
                con=dfv.pain_control{studyrank};
            end
           stats(studyrank)=summarize_between_BK(pla,con,gpuon); % no subjects had to be excluded for between-group studies
        end        
    end
end
% Calculate for those (within-subject) studies where only pla>con contrasts are available
conOnly=find(df.contrast_imgs_only==1);
impu_r=mean([stats.r],'omitnan'); % ... impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
    if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
        curr_n=size(dfv.placebo_minus_control{i},1);
        relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
        pla=dfv.placebo_minus_control{i}.*relabel;
    else
        pla=dfv.placebo_minus_control{i};
    end
    stats(i)=summarize_within_BK(pla,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

%% Correlation of behavioral effect and voxel-by-voxel bold response
% for studyrank=1:length(stats)
%     if any(strcmp(varargin,'conservative'))
%         ex_subj=df.subjects{studyrank}.excluded;
%     else
%         ex_subj=zeros((size(df.placebo{studyrank}.excluded)));
%     end
%     if ~isempty(stats(studyrank).delta) % necessary as "sum" returns 0 for [] for some stupid reason
%         if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
%             % For voxel only the sign of effect has been permuted above.
%             % So in respect to the correlation of voxel signal and ratings, data are
%             % not fully randomized.
%             % Just to make sure we have a completely random null-distribution in
%             % respect to correlations, we shuffle ratings as well.
%             activity=stats(studyrank).delta;
% %             ratings=shuffles(df.GIV_stats_rating(studyrank).delta); %todo souble check this: this is not working strangly now,but worked previously...
%             ratings=Shuffle(df.GIV_stats_rating(studyrank).delta); 
%             ratings=ratings(~ex_subj,:);
%         else
%             activity=stats(studyrank).delta;
%             ratings=df.GIV_stats_rating(studyrank).delta(~ex_subj,:);
%         end
%         stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan',gpuon); % correlate single-subject effect of behavior and voxel signal 
%         stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
%                                              isnan(ratings))); % AND non nan-ratings
%     else
%         stats(studyrank).r_external=[];%NaN(1,n_voxel);
%         stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
%     end
% end

end