function C_contrast_placebo_minus_control_BK(datapath,datanewpath,intermedpath, varargin)
% % --------------------------------------------------------------------
% This is a modification of MZ's original function to get the images which
% later used in the meta-anylsis. This is needed as some studies only
% provided contrast images (placebo-control), therefore has to be added
% her. In the rest of the studies, we calculate the difference of the
% previously defined two images (see A_equalize_image_size_and_mask_BK)
% 
% todo: describe what the funciton exaclty does. 
% % --------------------------------------------------------------------
% Inputs:
%   -datapath: the path to the data collected in 2015
%   -datanewpath: the path to the data collected in 2021 (it is separated
%   from the previous one bc in the 2015 data, the derived and intermediate
%   files are sinked there, while here we save them in a separate folder).
%   -intermedpath: the path for saving the intermediate files (see comment for 
%  the previous input)
%   
%  
% 
% OPTION: argument 'noimcalc' skips actual calculation of images and just
% updates the df
% 
% 
% %%%
% Outputs:
% -data_frame.mat with updated columns (the column names so far can be
% placebo, control, placebo-control). Each condition (column) contains study level
% information. In one cell, there is one table, which has columns with the keys variable names(see
% below). The table's rows contains information from one image (from all participants each condition).
%
% It calucaltes and save intermediate images to the intermediate folder
% (eg: average of early and late pain...). However, images which are not
% derived from other images are not copied. At a later point
% (A_equalize_image_size_and_mask_BK), all non-derived images will be
% copied to the intermediate folder (and equlized in images size).
% 
% f
% % --------------------------------------------------------------------
% Balint Kincses 2022
% balint.kincses@uk-essen.de



%% Create contrast images for placebo and control conditons (placebo-control)
% for within-subject studies & add images to data-frame
df_path=fullfile(intermedpath,'data_frame.mat');
load(df_path,'df');
nstudy=height(df);
isTableCol = @(t, thisCol) ismember(thisCol, t.Properties.VariableNames);
if ~isTableCol(df,'placebo_minus_control')
    df.placebo_minus_control=cell(nstudy,1);
end
wager_MI_studyid=find(strcmp(df.study_ID,'wager04b_michigan'));
%% Loop through studies and create contrasts
for studyrank=1:nstudy
    %Get current study as table
    
    % For all studies add empty contrast-array
    
    if (~logical(df.contrast_imgs_only(studyrank))) && strcmp(df.study_design(studyrank),'within')
        % studies where only contrasts are available, are treated
        % separately, below the loop.
        % & no contrasts will be calculated for between-group designs.        
        % Define outpath
%         study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
        nsubj=height(unique(df.raw{studyrank}(:,"sub_ID")));
        outpath=fullfile(intermedpath,df.study_dir{studyrank});
        
        for subjrank=1:nsubj
            pla_df=df.placebo{studyrank}(subjrank,:);
            con_df=df.control{studyrank}(subjrank,:);
            if df.datofdatacollection(studyrank)==2021
                pathtoimg=datanewpath;
            elseif df.datofdatacollection(studyrank)==2015
                pathtoimg=datapath;
            end
            % Prepare creation of contrast images with SPMs jobmanager
            if pla_df.derivedimg
                infilepath_pla=fullfile(intermedpath,pla_df.img);
            else 
                infilepath_pla=fullfile(pathtoimg,pla_df.img);
            end
            if con_df.derivedimg
                infilepath_con=fullfile(intermedpath,con_df.img);
            else 
                infilepath_con=fullfile(pathtoimg,con_df.img);
            end
            outfilename{subjrank}=char(strcat(string(df.placebo{studyrank}{subjrank,"sub_ID"}),'_placebo-control.nii'));
            matlabbatch{subjrank}.spm.util.imcalc.input = [infilepath_pla;...
                                                    infilepath_con
                                                    ];
            matlabbatch{subjrank}.spm.util.imcalc.output = outfilename{subjrank};
            matlabbatch{subjrank}.spm.util.imcalc.outdir = cellstr(outpath);
            matlabbatch{subjrank}.spm.util.imcalc.expression = 'i1-i2';
            matlabbatch{subjrank}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{subjrank}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{subjrank}.spm.util.imcalc.options.mask = 0;
            matlabbatch{subjrank}.spm.util.imcalc.options.interp = 1;
            matlabbatch{subjrank}.spm.util.imcalc.options.dtype = 4;

            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.img={fullfile(df.study_dir{studyrank},outfilename{subjrank})};
            new_con_tbl.cond={'placebo-control'};
            
            new_con_tbl.rating=pla_df.rating-con_df.rating;
            new_con_tbl.rating101=pla_df.rating101-con_df.rating101;
            new_con_tbl.x_span=nanmean([pla_df.x_span,...
                                        con_df.x_span]);
            if studyrank==wager_MI_studyid
                % For wager michigan beta images are available but for
                % behavior we have contrasts only.
                new_con_tbl.rating = df.placebo{wager_MI_studyid}(subjrank,:).rating*-1; % Ratings inverted! control>placebo
                new_con_tbl.rating101 = df.placebo{wager_MI_studyid}(subjrank,:).rating101*-1; % Ratings inverted! control>placebo
            end
            new_con_tbl.derivedimg=1;
            % Add new subject-level contrast table to subject
            df.placebo_minus_control{studyrank}(subjrank,:)=new_con_tbl;
            % Put modified study-level table back  to subject
        end 
        % Actually create contrast images
        if ~any(strcmp(varargin,'noimcalc'))
            spm_jobman('run', matlabbatch);
        end
        matlabbatch=[];
        
    end
end
save(fullfile(intermedpath,'data_frame.mat'),'df');
%% Manually add contrast-only studies - it has already done in the previous funciton
% (there are no within-subject contrasts for between-group studies) Kessner
% and Ruetgen!!


end