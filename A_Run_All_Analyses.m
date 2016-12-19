%% Script running all analyses of the placebo-meta-analysis,
% printing out all numerical results for the paper.

%% Import required functions

% SPM required
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/spm12/'))
% All custom meta-analysis functions required
addpath(genpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/'))

%% A Run Imports
% will create one .mat file in ./Datasets for each study. Each .mat file
% contains a df (dataframe, table) with paths to images and the respective
% behavioral/demografic/imaging data

run('./A_Import/A_Run_All_Single_Imports.m')
run('./A_Import/B_Collect_All_Data_Tables.m') % Collects all data-tables in one big df

%% B Create one big matrix holding all image data for (inclusive) analysis
% and a corresponding df

% Will create a copy of each image with size and resolution of SPM's brainmask
% [WILL DOUBLE THE SIZE OF ORIGINAL DATA]
run('./B_Prepro_Images/A_Equalize_Image_Size_and_Mask.m')

% Will create an un-masked matrix + corresponding df for each study
% >> only performed when alignment in single images looks suspicions
%run('./B_Prepro_Images/B_Create_Y_Unmasked_SingleStudy.m')

% Will create an umasked matrix + corresponding df for all data in inclusive analysis
% [WILL APPROCIMATELY DOUBLE THE SIZE OF ORIGINAL DATA]
run('../B_Prepro_Images/C_Create_Y.m')

%% Apply all Masks (NPS, MHE, Tissue Probability-Maps, Brain-Masks)

addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CAN/'))
run('./C_Apply_NPS/A_Apply_NPS_Single_Study.m') %Apply NPS study-wise, add to df, save new df as study_NPS
run('./C_Apply_NPS/B_Apply_MHE_Single_Study.m') %Apply MHE (whole brain-version of NPS from Zunhammer et al. 2016) study-wise, add to df, save new df as study_NPS_MHE
run('./C_Apply_NPS/C_Apply_NOTBRAIN_Single_Study.m') %Calculate relative tissue-signal levels study-wise analog to other masks, add to df, save new df as study_NPS_MHE_NOBRAIN
run('./C_Apply_NPS/C_Apply_NOTBRAIN_Abs.m') %Calculate relative ABSOLUTE tissue-signal levels study-wise analog to other masks, add to df, save new df as study_NPS_MHE_NOBRAIN
run('./C_Apply_NPS/D_Collect_All_Data_Tables_NPS.m')            %Collect all study_NPS_MHE_NOBRAIN tables in one big df (./Datasets/AllData_w_NPS_MHE_NOBRAIN.mat)
rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CAN/')) % avoid conflict-messages with SPM
%% Quality control and demographic results

% Check brain coverage and alignment
% Create a global coverage image including all files >> visual coverage check
run('./D_Exploratory_Analyses/A_Check_Image_Alignment/A_Check_Coverage.m')
% Create a coverage image for each study separately >> visual realignment check
run('./D_Exploratory_Analyses/A_Check_Image_Alignment/B_Check_Registrations_single_study.m')
% Calculate coverage of NPS based on global coverage image and NPS-mask
run('./D_Exploratory_Analyses/A_Check_Image_Alignment/C_Check_Coverage_NPS.m') 

% Study-level: Plot relative signal intensities for white/gray, csf/gray, nobrain/brain (for painful images)
run('./D_Exploratory_Analyses/B_Outlier_Search/A_by_study_tissue_signal_outlier_detection.m') 
% Subject-level (within studies): Plot relative signal intensities for white/gray, csf/gray, nobrain/brain (for painful images)
run('./D_Exploratory_Analyses/B_Outlier_Search/B_by_subject_tissue_signal_outlier_detection.m') 
% File in which the excluded subjects (for responder analysis) are defined
run('./D_Exploratory_Analyses/C_Mark_Excluded_Subjects.m') 

% Calculate overall demographic and behavioral results for tabulation
run('./D_Exploratory_Analyses/E_demographics.m')

%Note: Pain ratings were imported from each study as supplied by the
%investigators. Since scaling for these pain ratings (and especially pain
%thresholds) differ the identification of participants with very small pain
%ratings was performed by hand on a single-study basis in the original
%tables

%% NPS based meta-analysis (also MHE)

% Inclusive Ratings
run('./E_NPS_Meta_Analysis/A_MetaAnalysis_Ratings_Inclusive.m')
% Inclusive NPS
run('./E_NPS_Meta_Analysis/B_MetaAnalysis_NPS_Inclusive.m')
% Responder NPS
run('./E_NPS_Meta_Analysis/C_MetaAnalysis_NPS_Responder.m')

% Auxiliary findings NPS (all inclusive)
% Pain vs baseline
run('./E_NPS_Meta_Analysis/D_MetaAnalysis_NPS_Pain_vs_Baseline_Inclusive.m')
% High pain vs low pain
run('./E_NPS_Meta_Analysis/E_MetaAnalysis_NPS_High_vs_Low_Pain.m')
% Medications (NPS)
run('./E_NPS_Meta_Analysis/F_MetaAnalysis_NPS_Medication_Effects.m')
% Medications (Ratings)
run('./E_NPS_Meta_Analysis/F2_MetaAnalysis_Rating_Medication_Effects.m')



%% Whole brain analysis
