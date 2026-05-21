%% This is a modification of Matthias Zunhammer A_run_all script.
% 
% The pipeline creates a table which contains meta-data from all studies,
% path to the relevant images, path to the processed images, stimuli rating.
% 
% The following functions has to be called one after the other. After
% function, I detail what is the aim of the function, what it does, what are the arguments(if it needs specification) and
% what are the main outputs,and additional comments.
%
% AIM: 
% FUNCTIONING:
% OUTPUT: 
% COMMENT:
%
%
% Balint Kincses
% balint.kincses@uk-essen.de
% 2023

%% Define paths
%I wanted to keep MZ's data strucutre, but I also did not want to save the
%intermediate files as MZ saved, so one has to specify the original
%datastructure, the path to the new studies and also a location for
%intermediatefiles (everything is saved there. most importantly: the data_frame.mat(mother of all tables), study wise
%images, output of the results of the permutation for statistical inference
%and also the combined image)
intermedpath='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles'; %sinking intermediate files here
datapathorig='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\Datasets'; %parent folder with the dataset files from the collection2015
datpathnew='C:\Users\lenov\Documents\PICO_DATA\'; %parent folder with the dataset files from the collection2021

%% A) import raw data and image paths into data-frame: 165.716988 seconds.
A_create_study_overview_table_anticip(intermedpath);
% AIM: create the mother of all tables
% FUNCTIONING:  Fill with the table with metadata (hardcoded in the function).
% OUTPUT: the table without the path to the data (.raw column).
% COMMENT: NOTE that, the file is overwrittenby rerunning this function.

B_run_all_single_imports_anticip(datapathorig,datpathnew,intermedpath);
% AIM: update the table with the '.raw' colum
% FUNCTIONING: study-by study it updates the table with study specific information(see the function for the exact information)specified l
% OUTPUT: update table
% COMMENT:-->double check indiviudal imports for age and gender! (25.03.2026)

%% B) define sample - elapsed time : 279.7 seconds
% Different contrasts are calculated in this step and for each, a new column is
% created in the data_frame (the name of the contrast is the column name).
% Study-wise information about the images from that contrast(eg: path,rating...).. The image can be 
%   1. one provided ß/con image from the authors of the original study
%   2. an arithemtic combination of the ß/con images (eg:sum,*-1,...) (it receives the flag of derived in the table)
%   3. a derived image from the pla,cont images(ie. sum or difference) (it receives the flag of derived in the table)
% If it is a derived image, the new image will be saved in the intermeidate
% folder.
contrasts_img=["pain_placebo","pain_control","pain_placebo_minus_control","pain_placebo_and_control",...
    "anticip_placebo","anticip_control","anticip_placebo_minus_control","anticip_placebo_and_control"];
% todo include pain-anticipation contrasts

A_run_condition_summaries_anticip(datapathorig,datpathnew,intermedpath,contrasts_img,[1:26]); %'noimcalc'
% it creates the new images (if necessary) and put them in the intermediate folder
% This function performs the first two points. (some has a path to the original place(what was
% shared and the derived are moved to the intermediatepath folder, so we do
% not overwrite anything in the original shared folders)
% Elapsed time is 279.7 seconds.

% All the four functions below can be called with 'noimcalc' option, so it
% will only update the table.
B_diff_contrast_anticip(datapathorig,datpathnew,intermedpath,'pain','diff');
B_diff_contrast_anticip(datapathorig,datpathnew,intermedpath,'pain','sum');
B_diff_contrast_anticip(datapathorig,datpathnew,intermedpath,'anticip','diff');
B_diff_contrast_anticip(datapathorig,datpathnew,intermedpath,'anticip','sum');
% Run the third point. It is easier to separate this two steps, as the
% pla/cont images sometimes have to be calculated first.
% Elapsed time is 340.5

%% C) preprocess images
% All the contrast images which were defined and/or calculated in the previous steps
% are now target to equalize image size. Add a new column to the contrast
% tables, which is the path to the image with equal size. It
% is always in the folder of the study found in the intermediate path.
% Elapsed time is 2830.327028 seconds
%todo check coverage for anticipation, it is important for publication.
A_check_coverage_and_alignment_anticip(datapathorig,intermedpath);
contrasts_eqimgsize={'pain_placebo','pain_control','pain_placebo_minus_control','pain_placebo_and_control',...
    'anticip_placebo','anticip_control','anticip_placebo_minus_control','anticip_placebo_and_control'};
ZZ_checkimageorientationinfo_anticip(datapathorig,datpathnew,intermedpath,'pain_placebo'); %'noimcalc'
%this is a helper function to check the orientation difference. However,
%this is something which we cannot really do much. Checking visually is the
%best thing what we can do, but maybe do a seprate analysis based on
%studeis which have the same affine?(it is 12 studies)
%
A_equalize_image_size_and_mask_anticip(datapathorig,datpathnew,intermedpath,contrasts_eqimgsize); %'noimcalc'
% AIM: To "register" images to one each other, so the voxels in different studies reflect the same location.
% FUNCTIONING: as we do not have registration matrices, but assume that the images are already in a relatively similar template,
%   which is supported by the coverage imagesm we reslice the original images to our template 
% OUTPUT: in the intermediate folder, a per subject per contrast file for each study, in the template space, that is a voxel in one study reflects
%   the same location as in another study
% COMMENT: note that the images in the intermediate folder are overwritten. That is images which are alreadz derived at the indiviudal level, 
% has been overwritten with the masking by the standard.
%  
% 
% exclude participants and add that info in the placebo column(it is only
% necessary to add it each phase).
A_apply_tissuemasks_anticip(intermedpath,contrasts_eqimgsize);
% AIM: calculate image wise values for different compartments to identify outliers
% FUNCTIONING: it uses som Canlab core function to calculate different values image wise
% OUTPUT: an updated data_frame with the additional values in the df.(condition) which can be used for outlier detection
% COMMENT:some todos:
%todo double check MZ solution for detection of tissue signal outliers to
%todo include exclusion for the 2021 collected data
%todo include in the anticipation phase
%define exlcuded participants. He uses Mahaboni distance on a study and
%indiivudal level. see the functions of
%A_by_study_tissue_signal_outlier_detection and B_by_subject_tissue_signal_outlier_detection
% note that these functions are not refactored and the exclusion are
% hardcoded in the upcoming function.
C_designate_excluded_anticip(intermedpath,["pain_placebo"]);

%% Get matlab structure (vectorized matricies) from images - creation of dfv
% we end up with a vectorized, masked format (get rid of voxels with too much missing values) of
% the inidivudal images. Also perform the winsorizing within this step.
% It saves the structure in the intermedpath.
consforwinsorizing={'_placebo','_control','_placebo_minus_control','_placebo_and_control'};
% mask_path; the mask should be saved in the intermediate path during image
% equalization.
A_vectorize(intermedpath,1:26,["pain","anticip"],consforwinsorizing,intermedpath); 
%elapsed time: Elapsed time is 231.8 here the saving of the vectorized data
% takes a lot of time.


A_meta_analysis_placebo_anticip(intermedpath,fullfile(intermedpath,'forestplots'));
contrasts={'_placebo','_control','_placebo_minus_control','_placebo_and_control'};
% AIM: Getting summary stat for ratings and visualize (forestplot)
% FUNCTIONING: GIV method implementation
% OUTPUT: a nice forest plot of ratings
% COMMENT: note that the GIV implementation uses MZ's original functions

% If one wants to contrast the pain delivery and anticipation phase, one must use the
% same masks for vectorizing. Howver, there is some differences between the masks, so with 
% the follwoing script we handle that and 
Z_createeqmaskforphases(intermedpath,["pain","anticip"],contrasts,dfv_masked);
% Elapsed time is 9.535396 seconds.

% Run the statistical inference for the two phases separately. The
% permutation should be 5000 and the phase should be specified:
% It takes some time as it is specified after the function...

%load dfv_masked:
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent.mat')
B_summary_and_statisticalinference(intermedpath,5000,'pain','diff',{'r_external'},dfv_masked)
B_summary_and_statisticalinference(intermedpath,5000,'pain','sum');%Elapsed time is 5836 seconds.
B_summary_and_statisticalinference(intermedpath,5000,'anticip','diff',{'g','r_external'},dfv_masked) % It takes ~ 6.5436 h.
B_summary_and_statisticalinference(intermedpath,5000,'anticip','sum',{'g','r_external'},dfv_masked); %Elapsed time is ~1h.
% here an alternative idea about the "correlation" between brain activity
% and behavior effect (now the behavior is considered to be a U-shaped
% profile), so a quadratic curve would capture both direction of pain modulation
B_summary_and_statisticalinference(intermedpath,500,'pain','diff',{'r_external'},dfv_masked,'quadratic')
B_summary_and_statisticalinference(intermedpath,500,'anticip','diff',{'r_external'},dfv_masked,'quadratic')
% to run the contrast between the two phases,  such as pain and
% anticipation

%load dfv_masked:
%load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent_equal.mat')
Z_summary_and_statisticalinference_phasediff(intermedpath,5000,'both','placebo',{'g','r_external'},dfv_masked);
Z_summary_and_statisticalinference_phasediff(intermedpath,5000,'both','control',{'g','r_external'},dfv_masked);
Z_summary_and_statisticalinference_phasediff(intermedpath,5000,'both','diff',{'g','r_external'},dfv_masked); %~5.5h
% follow up analyses:
%understand the role of the putamen. Correlate anticipation related brain
%activity in the putamen with activity seen during pain.
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent.mat')
B_summary_and_statisticalinference(intermedpath,5000,'pain','diff',{'r_external'},dfv_masked, 'putamen')

% create images for saving and values of thresholds
% the intermedpath and the masked vectorized structure need to be loaded in
% the environment.
%the dfv_masked shuold be the same as above(different for the sum/diff and
%both)
C_visualizationofresults(intermedpath,dfv_masked)
% maskheaderforsaving='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\pattern_masks\brainmask_logical_50.nii';
% print_image(dfv_masked.anticip_brainmask,maskheaderforsaving,fullfile(intermedpath,'full_masked_10_percent'))
% 
%to get the FDR thresholds for pTFCE.
D_thresholdsforFDR(intermedpath)

%% additional analysis to understand the results found in hte putamen:
% 1. exclude all the studies which show a postive correlation/or unknown(Choi) between the
% anticipation and pain regressor. Keep the negative and unkown ones.
B_summary_and_statisticalinference(intermedpath,0,'anticip','diff',{'g','r_external'},dfv_masked,'colinearity_neg')
% get rid off the follwoing stuides: lui, wager04a, fehse,hartmann:
B_summary_and_statisticalinference(intermedpath,5000,'anticip','diff',{'r_external'},dfv_masked,'corrhigherthen03')
%exclude studeis with high positive correlation 'excl_colinearity_highpos'
Z_summary_and_statisticalinference_phasediff(intermedpath,5000,'both','diff',{'g'},dfv_masked,'excl_colinearity_highpos');
%% additional analysis on mediation of the NPS(bring to SIPS Krakow)
%for pain
Apply_NPS_BK(intermedpath,'nps')
Apply_NPS_BK(intermedpath,'siips')
%for anticipation
Apply_NPS_BK(intermedpath,'nps')
Apply_NPS_BK(intermedpath,'siips')
%create forestplot about nps/siips anticipation phase
A_meta_analysis_markeranaticip(intermedpath,fullfile(intermedpath,'forestplots'));

