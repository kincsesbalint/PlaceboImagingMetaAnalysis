function A_vectorize_all_BK(intermedpath,studyranks,varargin)
df_name='data_frame.mat';
load(fullfile(intermedpath,df_name),'df');
%% Preprocess data for meta-analysis study-wise
% >> sorts image and rating data into struct
% >> summarizes equivalent condition

%% Get data
%Preallocate struct for vectorized data
dfv.pain_placebo = cell(size(df,1),1);
dfv.pain_control = cell(size(df,1),1);
dfv.placebo_minus_control = cell(size(df,1),1);
% dfv.placebo_and_control = cell(size(df,1),1);

for studyrank=studyranks
    if strcmp(varargin,'conservative')
        ex_study=df.excluded_conservative_sample(studyrank);
        ex_subj=df.subjects{studyrank}.excluded;
    else
        ex_study=1;
        ex_subj=zeros((size(df.placebo{studyrank}.excluded)));
    end
    fprintf('stidyorder %i:\n',studyrank)
    if ex_study
        curr_df_control=df.control{studyrank}(~ex_subj,:);
        

        curr_df_placebo=df.placebo{studyrank}(~ex_subj,:);
        

        curr_df_placebo_minus_control=df.placebo_minus_control{studyrank}(~ex_subj,:);
        

        if  ~df.contrast_imgs_only(studyrank)==1 % only vectorize where both pla and con is available.
            validfiles_con=isfile(fullfile(intermedpath,curr_df_control.norm_img));
            validfiles_pla=isfile(fullfile(intermedpath,curr_df_placebo.norm_img));
            %TODO modify the v_masked function as it is not working well
            %with the path...
            dfv.pain_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_control.norm_img(validfiles_con)));
            dfv.pain_placebo{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo.norm_img(validfiles_pla)));        
        end

%         dfv.placebo_and_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_and_control.norm_img));

        if  strcmp(df.study_design(studyrank),'within') && df.contrast_imgs_only(studyrank)==1
            dfv.placebo_minus_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_minus_control.norm_img));
        end
    end
end
%% Add study/variable descriptions needed for meta-analysis
if strcmp(varargin,'conservative')
    save(fullfile(intermedpath,'vectorized_images_conservative'),'dfv','-v7.3');
else
    save(fullfile(intermedpath,'vectorized_images_full'),'dfv','-v7.3');
end
end




% null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL
% 
% n_nan=NaN(height(df),size(dfv.placebo{1},2));
% n_subj=NaN(height(df),1);
% for studyorder=1:height(df)
% %     if ~isempty(dfv.placebo{studyorder})
%         n_nan(studyorder,:)=sum(isnan(dfv.placebo{studyorder}));
%         n_not_nan(studyorder,:)=sum(~isnan(dfv.placebo{studyorder}));
%         n_subj(studyorder,:)=size(dfv.placebo{studyorder},1);
% %     end
% end
% %For each study: Proportion of participants with nan and not-nan at any given voxel
% prop_nan_study_level=n_nan./n_subj;
% prop_not_nan_study_level=n_not_nan./n_subj;
% 
% too_few_study_level=n_not_nan<=3; %select voxels where n<3 on study-level
% n_subj_matrix=repmat(n_subj,1,size(n_nan,2)); %create helper-matrix with max n of participants
% 
% n_nan_corrected=n_nan; %copy n_nan...   
% n_nan_corrected(too_few_study_level)=n_subj_matrix(too_few_study_level); %...replace voxels with too few subjects on study level
% 
% %Calculate overall proportion of subjects with nan at a given voxel (subjects from voxels with too few subjects at study-level excluded)
% prop_nan_overall=sum(n_nan_corrected)/sum(n_subj);
% mask_exvoxels=prop_nan_overall<null_trshld;
% dfv_masked=dfv;
% for i=1:size(df,1)
%     if ~isempty(dfv.placebo{i})
%     dfv_masked.placebo{i}=dfv.placebo{i}(:,mask_exvoxels);
%     end
% %     if ~isempty(dfv.pain_control{i})
% %     dfv_masked.pain_control{i}=dfv.pain_control{i}(:,mask_exvoxels);
% %     end
% %     if ~isempty(dfv.placebo_and_control{i})
% %     dfv_masked.placebo_and_control{i}=dfv.placebo_and_control{i}(:,mask_exvoxels);
% %     end
% %     if ~isempty(dfv.placebo_minus_control{i})
% %     dfv_masked.placebo_minus_control{i}=dfv.placebo_minus_control{i}(:,mask_exvoxels);
% %     end
% end
% %% Add study/variable descriptions needed for meta-analysis
% % if strcmp(varargin,'conservative')
% %     save(fullfile(intermedpath,'vectorized_images_conservative'),'dfv','-v7.3');
% % else
% %     save(fullfile(intermedpath,'vectorized_images_full'),'dfv','-v7.3');
% % end
% %     save(fullfile(intermedpath,'vectorized_images_full'),'dfv','-v7.3');
% maki=dfv.placebo;
% end