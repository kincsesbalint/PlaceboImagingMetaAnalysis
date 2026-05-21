function A_vectorize_painandanticip_BK(intermedpath,studyranks,phase,consforwinsorizing,varargin)
df_name='data_frame.mat';
load(fullfile(intermedpath,df_name),'df');
%% Preprocess data for meta-analysis study-wise
% >> sorts image and rating data into struct
% >> summarizes equivalent condition

%% Get data
%Preallocate struct for vectorized data
for phases=1:length(phase)
%     switch phase{phases}
%         case 'pain'
            dfv.(strcat(phase(phases) ,"_placebo")) = cell(size(df,1),1);
            dfv.(strcat(phase(phases) ,"_control")) = cell(size(df,1),1);
            dfv.(strcat(phase(phases) ,"_placebo_minus_control"))= cell(size(df,1),1);
            dfv.(strcat(phase(phases) ,"_placebo_and_control")) = cell(size(df,1),1);
            for studyrank=studyranks
                if strcmp(varargin,'conservative')
                    ex_study=df.excluded_conservative_sample(studyrank);
                    ex_subj=df.subjects{studyrank}.excluded;
                else
                    ex_study=1;
                    ex_subj=zeros((size(df.pain_placebo{studyrank}.excluded))); %this is written here by the C_designate function
                end
                fprintf('%s studyorder %i:\n',phase(phases),studyrank)
                if ex_study && df.(strcat(phase(phases) ,"ismodeled"))(studyrank)
                    curr_df_control=df.(strcat(phase(phases) ,"_control")){studyrank}(~ex_subj,:);
                    curr_df_placebo=df.(strcat(phase(phases) ,"_placebo")){studyrank}(~ex_subj,:);
                    curr_df_placebo_minus_control=df.(strcat(phase(phases) ,"_placebo_minus_control")){studyrank}(~ex_subj,:);
                    curr_df_placebo_and_control=df.(strcat(phase(phases) ,"_placebo_and_control")){studyrank}(~ex_subj,:);
                    if  ~df.contrast_imgs_only(studyrank)==1 % only vectorize where both pla and con is available.
                        validfiles_con=isfile(fullfile(intermedpath,curr_df_control.norm_img));
                        validfiles_pla=isfile(fullfile(intermedpath,curr_df_placebo.norm_img));
                        %TODO modify the v_masked function as it is not working well
                        %with the path...
                        dfv.(strcat(phase(phases) ,"_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_control.norm_img(validfiles_con)));
                        dfv.(strcat(phase(phases) ,"_placebo")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo.norm_img(validfiles_pla)));        
                    end
                    if ~any(cellfun(@isempty,curr_df_placebo_and_control.norm_img)) %only vectorize image which is available
                        dfv.(strcat(phase(phases) ,"_placebo_and_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_and_control.norm_img));
                    end
            
                    if  strcmp(df.study_design(studyrank),'within') && df.contrast_imgs_only(studyrank)==1
                        dfv.(strcat(phase(phases) ,"_placebo_minus_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_minus_control.norm_img));
                    end
                end
            end
%         case 'anticip'
%             dfv.anticip_placebo = cell(size(df,1),1);
%             dfv.anticip_control = cell(size(df,1),1);
%             dfv.anticip_placebo_minus_control = cell(size(df,1),1);
%             dfv.anticip_placebo_and_control = cell(size(df,1),1);
% 
%             for studyrank=studyranks
%                 if strcmp(varargin,'conservative')
%                     ex_study=df.excluded_conservative_sample(studyrank);
%                     ex_subj=df.subjects{studyrank}.excluded;
%                 else
%                     ex_study=1;
%                     ex_subj=zeros((size(df.placebo{studyrank}.excluded)));
%                 end
%                 fprintf('Anticip studyorder %i:\n',studyrank)
%                 if ex_study && df.anticipismodeled(studyrank)
%                     curr_df_control=df.anticip_control{studyrank}(~ex_subj,:);
%                     curr_df_placebo=df.anticip_placebo{studyrank}(~ex_subj,:);
%                     curr_df_placebo_minus_control=df.anticip_placebo_minus_control{studyrank}(~ex_subj,:);
%                     curr_df_anticip_placebo_and_control=df.anticip_placebo_and_control{studyrank}(~ex_subj,:);
%                     if  ~df.contrast_imgs_only(studyrank)==1 % only vectorize where both pla and con is available.
%                         validfiles_con=isfile(fullfile(intermedpath,curr_df_control.norm_img));
%                         validfiles_pla=isfile(fullfile(intermedpath,curr_df_placebo.norm_img));
%                         %TODO modify the v_masked function as it is not working well
%                         %with the path...
%                         dfv.anticip_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_control.norm_img(validfiles_con)));
%                         dfv.anticip_placebo{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo.norm_img(validfiles_pla)));        
%                     end
%             
%                     dfv.anticip_placebo_and_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_anticip_placebo_and_control.norm_img));
%             
%                     if  strcmp(df.study_design(studyrank),'within') && df.contrast_imgs_only(studyrank)==1
%                         dfv.anticip_placebo_minus_control{studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_minus_control.norm_img));
%                     end
%                 end
%             end
%     end
end

%% Masking - Remove nan voxels

null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL
dfv_masked=dfv;
mask_path='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\brainmask_logical_50.nii';
for phases=1:length(phase)
%     if ismember(phase)
    
    switch phase(phases)
        case 'pain'
            NotconOnlywithin{phases}=intersect(find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within')),studyranks); % this was modified if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
            NotconOnlybetween{phases}=intersect(find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between')),studyranks);
            conOnly{phases}=intersect(find(df.contrast_imgs_only==1),studyranks);
%             numstud=size(studyranks,2);
        case 'anticip'
            NotconOnlywithin{phases}=intersect(find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.anticipismodeled==1),studyranks); % this was modified if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
            NotconOnlybetween{phases}=intersect(find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.anticipismodeled==1),studyranks);
            conOnly{phases}=intersect(find(df.contrast_imgs_only==1 & df.anticipismodeled==1),studyranks);
%             numstud=length(NotconOnlywithin{phases})+length(NotconOnlybetween{phases})+length(conOnly{phases});
    end
    NaN(size(studyranks,2),size(dfv.(strcat(phase(phases) ,"_placebo")){1},2));
    n_nan=NaN(size(studyranks,2),size(dfv.(strcat(phase(phases) ,"_placebo")){1},2)); %
    n_subj=NaN(size(studyranks,2),1);
%     numstud=length(NotconOnlywithin{phases})+length(NotconOnlybetween{phases})+length(conOnly{phases});
    for i=NotconOnlywithin{phases}' % Calculate for studies with within design and nocontract only imgs
        cdata=mean(cat(3,dfv.(strcat(phase(phases) ,"_placebo")){i},dfv.(strcat(phase(phases) ,"_control")){i}),3); %if either pla or con image is nan, voxel is marked as nan
        n_nan(i,:)=sum(isnan(cdata));
        n_not_nan(i,:)=sum(~isnan(cdata));
        n_subj(i,:)=size(cdata,1);
    end
    if ~isempty(NotconOnlybetween{phases})
        for i=NotconOnlybetween{phases}'
            cdata=[dfv.(strcat(phase(phases) ,"_placebo")){i};dfv.(strcat(phase(phases) ,"_control")){i}];
            n_nan(i,:)=sum(isnan(cdata));
            n_not_nan(i,:)=sum(~isnan(cdata));
            n_subj(i,:)=size(cdata,1);
        end
    end
% Extra loop for (within-subject) studies where only
% pla>con contrasts are available (con_img is filled with nans)
    if ~isempty(NotconOnlybetween{phases})
        for i=conOnly{phases}'
            cdata=dfv.(strcat(phase(phases) ,"_placebo_minus_control")){i};
            n_nan(i,:)=sum(isnan(cdata));
            n_not_nan(i,:)=sum(~isnan(cdata));
            n_subj(i,:)=size(cdata,1);
        end
    end
    n_nan=n_nan([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}],:);   
    n_not_nan=n_not_nan([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}],:);   
    n_subj=n_subj([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}],:);   
    %For each study: Proportion of participants with nan and not-nan at any given voxel
    prop_nan_study_level=n_nan./n_subj;
    prop_not_nan_study_level=n_not_nan./n_subj;
    
    %For each study: Exclude (set to all-nan) studies with less than 3 not-nan
    %subjects. ( those will be excluded anyway when calculating the meta-stats, as
    % correlations/error estimates based on 3 participants are unreliable and will produce outlier voxels)
    
    too_few_study_level=n_not_nan<=3; %select voxels where n<3 on study-level
    n_subj_matrix=repmat(n_subj,1,size(n_nan,2)); %create helper-matrix with max n of participants
    
    n_nan_corrected=n_nan; %copy n_nan...   
    n_nan_corrected(too_few_study_level)=n_subj_matrix(too_few_study_level); %...replace voxels with too few subjects on study level

    %Calculate overall proportion of subjects with nan at a given voxel (subjects from voxels with too few subjects at study-level excluded)
    prop_nan_overall=sum(n_nan_corrected)/sum(n_subj);
    
    
%      hist(prop_nan_overall,50);
%      hold on
%      vline(null_trshld);
%      hold off
     
    mask_exvoxels=prop_nan_overall<null_trshld;
    
    
        for i=1:size(df,1)
            if ~isempty(dfv.(strcat(phase(phases) ,"_placebo")){i})
            dfv_masked.(strcat(phase(phases) ,"_placebo")){i}=dfv.(strcat(phase(phases) ,"_placebo")){i}(:,mask_exvoxels);
            end
            if ~isempty(dfv.(strcat(phase(phases) ,"_control")){i})
            dfv_masked.(strcat(phase(phases) ,"_control")){i}=dfv.(strcat(phase(phases) ,"_control")){i}(:,mask_exvoxels);
            end
            if ~isempty(dfv.(strcat(phase(phases) ,"_placebo_and_control")){i})
            dfv_masked.(strcat(phase(phases) ,"_placebo_and_control")){i}=dfv.(strcat(phase(phases) ,"_placebo_and_control")){i}(:,mask_exvoxels);
            end
            if ~isempty(dfv.(strcat(phase(phases) ,"_placebo_minus_control")){i})
            dfv_masked.(strcat(phase(phases) ,"_placebo_minus_control")){i}=dfv.(strcat(phase(phases) ,"_placebo_minus_control")){i}(:,mask_exvoxels);
            end
        end


dfv_masked.(strcat(phase(phases) ,"_brainmask"))=mask_exvoxels;
dfv_masked.(strcat(phase(phases) ,"_brainmask3d"))=vector2img(mask_exvoxels,mask_path);



end
%% Winsorizing
% Censoring extreme values to 3 standard deviations (most extreme 0.3% of data)
% The 3 SD target is chosen for consistency with earlier Wager studies.
% Winsorizing is performed on a by-study-by-contrast level.
target_sd=3;
p_low=(normcdf(target_sd*-1,0,1))*100;
p_high=(normcdf(target_sd,0,1))*100;
% cons={'pain_placebo','pain_control','placebo_minus_control'}
for phases=1:length(phase)    
    for cons = 1:length(consforwinsorizing)
        winsorized.(strcat(phase(phases) ,consforwinsorizing{cons}))=cell(size(df,1),1);
    end
end
phases=1:length(phase) 
for j = 1:length(consforwinsorizing)
    for i = 1:length(dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})))
        curr_matrix=dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})){i};
        if ~isempty(curr_matrix)
            curr_upper_prctile=prctile(curr_matrix(:),p_high);
            curr_lower_prctile=prctile(curr_matrix(:),p_low);
            winsorized.(strcat(phase(phases) ,cons{j})){i}=(curr_matrix>curr_upper_prctile) + (curr_matrix<curr_lower_prctile);
            curr_matrix(curr_matrix>curr_upper_prctile)=curr_upper_prctile;
            curr_matrix(curr_matrix<curr_lower_prctile)=curr_lower_prctile;
            dfv_masked.(strcat(phase(phases) ,cons{j})){i}=curr_matrix;
        end
    end
end
save(fullfile(intermedpath,['vectorized_images_full_masked_10_percent.mat']),'dfv_masked','-v7.3');
