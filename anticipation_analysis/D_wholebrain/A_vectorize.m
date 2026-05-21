function A_vectorize(intermedpath,studyranks,phase,consforwinsorizing,mask_path,varargin)
% % --------------------------------------------------------------------
% This is a modification of MZ's original functions to load and vectorize
% all the individual images (resliced and registered to SPM standard space)
% per condition. It loads the data, mask missing voxels (get rid of voxels
% with too much missing values), and winsorize the data.
% It only works with included participants (get rid of excluded ones).
%
% 
% In detail:
%   1. part: load the data of included subjects. Go through all specified
%   phases, all specified studies and define path to the _placebo,
%   _control, _placebo_and_control, and _placebo_minus_control images. Some
%   studies have only contrast images, in those the "raw" placebo/control
%   is not specified. It uses a mask to vectorize the nifti files. Each
%   individual nifti is loaded in a vector (MZ's nii2vector function) and a
%   cell array of each study is created. Non-brain voxels value are NaN.
%   2. part: excluding voxels with too many missingvalues(mostly non-brain
%   voxels) using the threshold defined in "null_trshld" variable. It
%   returns the mask of the interesting voxels.
%   3. part: winsorizing - censoring extreme values to 3 standard
%   deviations (most extreme 0.3% of data) The 3 SD target is chosen for
%   consistency with earlier Wager studies. Winsorizing is performed on a
%   by-study-by-contrast level. 
% todo:change mask parent path to the exact mask path.
% % --------------------------------------------------------------------
% Inputs:
%   - intermedpath: the path to the intermediate files 
%   - studyranks: perform the funciton only on a subset of studies. If not
%   all the studies are specified, the rows are left open for non-included
%   studies.
%   - phase: ["pain","anticip"]
%   - consforwinsorizing: the contrast which should be used for
%   winsorizing. winsorizing is performed on a by-study-by-contrast level.
%   It can be all the contrasts or only a subset of available contrasts.
%   
% 
% %%%
% Outputs:
%   -dfv_masked (saved as: vectorized_images_full_masked_10_percent.mat): a
%   huge file (~4GB), which contains all the conditions (placebo, control,
%   or the contrast of them(if that was only available)) study wise in a
%   matrix format. This will be used to calculate the test statistics and
%   also to make the permutation test for statistical inference.
% 
% % --------------------------------------------------------------------
% Balint Kincses 2023
% balint.kincses@uk-essen.de
% mask_path='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\brainmask_logical_50.nii';
df_name='data_frame.mat';
load(fullfile(intermedpath,df_name),'df');
%% First part: get data

for phases=1:length(phase)
        %Preallocate struct for vectorized data
        dfv.(strcat(phase(phases) ,"_placebo")) = cell(size(df,1),1);
        dfv.(strcat(phase(phases) ,"_control")) = cell(size(df,1),1);
        dfv.(strcat(phase(phases) ,"_placebo_minus_control"))= cell(size(df,1),1);
        dfv.(strcat(phase(phases) ,"_placebo_and_control")) = cell(size(df,1),1);
        for studyrank=studyranks
            %conservative sample is not in the focus, but I kept to be
            %compatible with MZ's pipeline.
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
                    dfv.(strcat(phase(phases) ,"_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_control.norm_img(validfiles_con)),mask_path);
                    dfv.(strcat(phase(phases) ,"_placebo")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo.norm_img(validfiles_pla)),mask_path);        
                end
                if ~any(cellfun(@isempty,curr_df_placebo_and_control.norm_img)) %only vectorize image which is available
                    dfv.(strcat(phase(phases) ,"_placebo_and_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_and_control.norm_img),mask_path);
                end
        
                if  strcmp(df.study_design(studyrank),'within') && df.contrast_imgs_only(studyrank)==1
                    dfv.(strcat(phase(phases) ,"_placebo_minus_control")){studyrank}=v_masked_BK(fullfile(intermedpath,curr_df_placebo_minus_control.norm_img),mask_path);
                end
            end
        end
end

%% Masking - Remove nan voxels

null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL
dfv_masked=dfv;

for phases=1:length(phase)

    
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
%     NaN(size(studyranks,2),size(dfv.(strcat(phase(phases) ,"_placebo")){1},2));
    n_nan=NaN(size(studyranks,2),size(dfv.(strcat(phase(phases) ,"_placebo")){1},2)); %
    n_subj=NaN(size(studyranks,2),1);
    n_not_nan=NaN(size(studyranks,2),size(dfv.(strcat(phase(phases) ,"_placebo")){1},2));
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
    if ~isempty(conOnly{phases})
        for i=conOnly{phases}'
            cdata=dfv.(strcat(phase(phases) ,"_placebo_minus_control")){i};
            n_nan(i,:)=sum(isnan(cdata));
            n_not_nan(i,:)=sum(~isnan(cdata));
            n_subj(i,:)=size(cdata,1);
        end
    end
    n_nan=n_nan(sort([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}]),:);   
    n_not_nan=n_not_nan(sort([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}]),:);   
    n_subj=n_subj(sort([NotconOnlywithin{phases}; NotconOnlybetween{phases};conOnly{phases}]),:);   
    %For each study: Proportion of participants with nan and not-nan at any given voxel
%     prop_nan_study_level=n_nan./n_subj;
%     prop_not_nan_study_level=n_not_nan./n_subj;
    
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
%todo find out when this brainmasklogical50 is saved in the pipeline, so it
%can be referred fromhere
mask_img_path=fullfile(mask_path,'brainmask_logical_50.nii');
dfv_masked.(strcat(phase(phases) ,"_brainmask3d"))=vector2img(mask_exvoxels,mask_img_path);
%todo save this mask_exvoxels out in the intermedpath so we can use it
%later in the pTFCE analysis
%see also MZ's B_mask_missing_voxels script
print_image(mask_exvoxels,mask_img_path,fullfile(intermedpath,['full_masked_10_percent_' phase{phases}]))


end
%% Part 3. - Winsorizing

target_sd=3;
p_low=(normcdf(target_sd*-1,0,1))*100;
p_high=(normcdf(target_sd,0,1))*100;
% cons={'pain_placebo','pain_control','placebo_minus_control'}
for phases=1:length(phase)    
    for cons = 1:length(consforwinsorizing)
        winsorized.(strcat(phase(phases) ,consforwinsorizing{cons}))=cell(size(df,1),1);
    end
end
for phases=1:length(phase) 
    for j = 1:length(consforwinsorizing)
        for i = 1:length(dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})))
            curr_matrix=dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})){i};
            if ~isempty(curr_matrix)
                curr_upper_prctile=prctile(curr_matrix(:),p_high);
                curr_lower_prctile=prctile(curr_matrix(:),p_low);
                winsorized.(strcat(phase(phases) ,consforwinsorizing{j})){i}=(curr_matrix>curr_upper_prctile) + (curr_matrix<curr_lower_prctile);
                curr_matrix(curr_matrix>curr_upper_prctile)=curr_upper_prctile;
                curr_matrix(curr_matrix<curr_lower_prctile)=curr_lower_prctile;
                dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})){i}=curr_matrix;
            end
        end
    end
end
save(fullfile(intermedpath,['vectorized_images_full_masked_10_percent.mat']),'dfv_masked','-v7.3');
