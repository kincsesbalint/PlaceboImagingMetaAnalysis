function C_designate_excluded_anticip(intermedpath,conditions)
% % --------------------------------------------------------------------
% This is a modification of MZ original function to index images with
% outlier behavior or imaging characteristics.
% We save the exclusion only in the df.placebo per subject. one has to look
% there for it...but we can save it to each place,but than it will be
% redundant.
% % --------------------------------------------------------------------
% % --------------------------------------------------------------------
% Balint Kincses 2022
% balint.kincses@uk-essen.de
%% Load Dataframe
df_name='data_frame.mat';
load(fullfile(intermedpath,df_name));

% Mark participants with pain ratings <5% VAS
atlasID=find(strcmp(df.study_ID,'atlas'));
% studies with contrast
wager_PR_ID=find(strcmp(df.study_ID,'wager04a_princeton'));
zeidanID=find(strcmp(df.study_ID,'zeidan'));
% studies with between subject design
kessnerID=find(strcmp(df.study_ID,'kessner'));
ruetgenID=find(strcmp(df.study_ID,'ruetgen'));
behavexclcir=5;
clear ratinglimit
for studyrank=1:height(df)
    for condrank=1:length(conditions)
        if studyrank==atlasID
            dftmp=df.raw{atlasID};
            for subjnum=1:length(unique(dftmp.sub_ID))
                subjects=unique(dftmp.sub_ID);
                ratinglimit(subjnum)=mean(dftmp(strcmp(dftmp.sub_ID,subjects(subjnum)) & ...% current subject
                    (strcmp(dftmp.cond,'StimHiPain_Open_Stimulation')...
                    |strcmp(dftmp.cond,'StimHiPain_Hidden_Stimulation')),:).rating101,'omitnan');    
            end
            df.(conditions(condrank)){studyrank}.excluded_low_pain = (ratinglimit<behavexclcir)';
        elseif studyrank==wager_PR_ID %|| studyrank==zeidanID
            df.(conditions(condrank)){studyrank}.excluded_low_pain = double(df.pain_control{studyrank}.rating101)<behavexclcir;
        elseif studyrank==ruetgenID || studyrank==kessnerID
%             ratinglimit
            tmp=df.pain_control{studyrank}.img=="NA";
            ratinglimit=ones(length(tmp),1);
            ratinglimit(tmp,:)=df.pain_placebo{studyrank}(tmp,:).rating101<behavexclcir;
            ratinglimit(~tmp,:)=df.pain_control{studyrank}(~tmp,:).rating101<behavexclcir;
            
            df.(conditions(condrank)){studyrank}.excluded_low_pain=ratinglimit;
            clear ratinglimit
        else
            df.(conditions(condrank)){studyrank}.excluded_low_pain = mean([df.pain_placebo{studyrank}.rating101,df.pain_control{studyrank}.rating101],2,'omitnan')<behavexclcir;
        end
        
    end
end

% Images identified as potential outliers according to 
% tissue signal estimates and visual screening.
ex_extreme_img_IDs={'bingel11_13','bingel11_14','choi_A','choi_D','choi_F',...
    'eippert_12','freeman_LIDCAP001','geuter_34','lui_28','theysohn_2136',...
    'theysohn_2145','wrobel_42'};
for studyrank=1:size(df,1)
    % Mark outlier images
    df.pain_placebo{studyrank}.excluded_image_quality=ismember(df.pain_placebo{studyrank}.sub_ID,...
                                            ex_extreme_img_IDs);
    df.pain_placebo{studyrank}.excluded = max(df.pain_placebo{studyrank}.excluded_image_quality,df.pain_placebo{studyrank}.excluded_low_pain);
end

save(fullfile(intermedpath,df_name), 'df')