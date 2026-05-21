function A_check_coverage_and_alignment_anticip(datapath,intermedpath)
% % --------------------------------------------------------------------
% This is a modification of MZ's original function to check brain coverage.
% A) Check coverage across all studies (full sample)
% Note 1: Use mean_pla_con contrasts as these cover all images for placebo
% and control studies
% Note 2: use raw image (.img), as norm_img are already masked.-->
% IMPORTANT!!! one has to run this step before image normalization, as the
% normalization overwrites the original image in many cases, to spare
% storage space.
% % --------------------------------------------------------------------
% Inputs:
%   -intermedpath: the path to the intermediate files 
%   -contrast: the conditions(which are separet columns in the data_frame)
%   
%  
% 
% 
% 
% %%%
% Outputs:
% -data_frame.mat with updated columns of mask values. 
% 
% 
% % --------------------------------------------------------------------
% Balint Kincses 2023
% balint.kincses@uk-essen.de
df_path=fullfile(intermedpath,'data_frame.mat');
load(df_path,'df');

%todo for anticipation
df_all_imgs=vertcat(df.pain_placebo_and_control{17:end}); %2:end
in_imgs={};
for subj=1:height(df_all_imgs)
    if df_all_imgs.derivedimg(subj)
        in_imgs(subj,1)=fullfile(intermedpath,df_all_imgs.img(subj));
    else 
        in_imgs(subj,1)=fullfile(datapath,df_all_imgs.img(subj));
    end
end
mkdir(fullfile(intermedpath,'zz_imgs/coverage'));
outfile='check_coverage_full_sample_pla_and_con.nii';
volume_coverage(in_imgs,fullfile(intermedpath,'zz_imgs/coverage',outfile))

% B) Check coverage for each study (full sample)
 for i=1:size(df,1)
     if ~strcmp(df.study_ID(i),'koban') %the koban study only have placebo-control condition.
    in_imgs={};
    curr_contrast_df=vertcat(df.pain_placebo_and_control{i});
    for subj=1:height(curr_contrast_df)
        if curr_contrast_df.derivedimg(subj)
            in_imgs(subj,1)=fullfile(intermedpath,curr_contrast_df.img(subj));
        else 
            in_imgs(subj,1)=fullfile(datapath,curr_contrast_df.img(subj));
        end
    end
    
    volume_coverage(in_imgs,fullfile(intermedpath,'/zz_imgs/coverage/',['coverage_',df.study_ID{i},'.nii']))
     end
 end
 
% Descriptive summary:

% 1.) For the FSL studies (Choi, Ellingsen, Zeidan), coverage is larger than
% the MNI152 brain template. It seems like as if brain & skull are covered.
% However, this is not due to false normalization ("inflated brains"), since
% the 2nd level SPM pain>baseline analysis clearly shows that the main
% activations are clearly within the skull and at the expected places
% (insula, sII), while estimates in the periphery are negligible.
% 2.) Similarly, coverage/registration for Atlas and Freeman have to be
% checked looking at the pain>baseline analysis, as the coverage includes
% the FOV, not just the brains.
% 3.) Wager_Michigan excluded white matter.
% 4.) In several studies some participants are missing the most superior
% part of the brain (likely limited FOV, e.g. see Geuter) and some participants
% are missing the orbitofrontal cortex (likely signal extinction artifacts, e.g.
% see: Theysohn et al.)
end