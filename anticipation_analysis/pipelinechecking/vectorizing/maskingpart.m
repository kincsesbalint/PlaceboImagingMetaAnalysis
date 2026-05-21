n_nan=NaN(size(df,1),size(dfv.anticip_placebo{1},2));
n_subj=NaN(size(df,1),1);
for i=1:size(df,1) % Calculate for all studies except...
    if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
        if strcmp(df.study_design{i},'within') %Calculate for within-subject studies
           cdata=mean(cat(3,dfv.anticip_placebo{i},dfv.anticip_control{i}),3); %if either pla or con image is nan, voxel is marked as nan
        elseif strcmp(df.study_design{i},'between') %Calculate between-group studies
           cdata=[dfv.anticip_placebo{i};dfv.anticip_control{i}];
        end
    end
    n_nan(i,:)=sum(isnan(cdata));
    n_not_nan(i,:)=sum(~isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end

% Extra loop for (within-subject) studies where only
% pla>con contrasts are available (con_img is filled with nans)
conOnly=find(df.contrast_imgs_only==1);
for i=conOnly'
    cdata=dfv.anticip_placebo_minus_control{i};
    n_nan(i,:)=sum(isnan(cdata));
    n_not_nan(i,:)=sum(~isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end
       
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


%  hist(prop_nan_overall,50);
%  hold on
%  vline(null_trshld);
%  hold off
 
mask_exvoxels=prop_nan_overall<null_trshld;

dfv_masked=dfv;