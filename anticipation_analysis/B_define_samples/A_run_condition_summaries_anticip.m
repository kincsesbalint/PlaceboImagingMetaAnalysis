function A_run_condition_summaries_anticip(datapath,datanewpath,intermedpath,condition,studyrank,varargin)
% % --------------------------------------------------------------------
% This is a modification of MZ's original functions (first two functions
% from B_define_sample folder) to identify and/or calculate the images
% which later used in the meta-analysis. Some provided images can already
% be used, however, some needs to be derived from the provided ones. The
% derived images are saved to the intermediate folder, specified by the
% user. This function only focuses on placebo and control conditions (in
% each phases: pain/anticipation), the sum and difference are hanlded by a
% different function.
%
%
% Detailed performance: creates new columns in the main data_frame(called
% as the 'condition'). It uses the raw column in the main table. It
% calculates condition specific images (eg:mean of early and late pain) OR
% save the path to the raw image if it is already fulfills a condition.
% The placebo and control columns are only populated here (EXCEPT in
% some studies the sum and difference of them, as only those contrasts were
% provided by those studies). Therefore, in most cases the sum and
% difference conditions are calculated in a subsequent script (see
% B_diff_contrast_anticip). It calculates and save intermediate images in
% the intermediate folder (eg: average of early and late pain...). However,
% images which are not derived from other images are not copied. At a later
% point (A_equalize_image_size_and_mask_anticip), when image sizes are
% equalized, all non-derived images will be copied to the intermediate
% folder (and equlized in images size). 
%
% IMPORTANT!!! this script MUST run before the B_diff_contrast_anticip
% script.
%  
%  
% % --------------------------------------------------------------------
% Inputs:
%   -datapath: the path to the data collected in 2015
%   -datanewpath: the path to the data collected in 2021 (it is separated
%       from the previous one bc in the 2015 data, the derived and intermediate
%       files are sinked together, while here we save intermediate files in a
%       separate folder. The aim would be to keep together the folder which was
%       shared by the original aouthors).
%   -intermedpath: the path for saving the intermediate files (see comment for 
%       the previous input)
%   -condition: the condition of interest in which we want to calculate the
%       derived images/define the important images. Here, only those
%       conditions are calculated (mainly placebo and control) which were
%       derived from the originally shared images. However, sometimes only
%       contrast images are available, so the eg:
%       placebo_minus_control_pain condition can direclty derived from the
%       original images.
%   -studyrank: define the studies (using their rank) in which we calculate
%   (eg:1:26)(it can be used to speed up and use only a subset of studies)
% % --------------------------------------------------------------------
% Outputs:
%   -data_frame.mat with updated columns (the column names are specified in
%       the 'condition' input). Each condition (column) contains study level
%       information. In one cell, there is one table, which has columns with the
%       keys variable names(see  below). The table's rows contains information
%       from one image (from all participants each condition). 
% % --------------------------------------------------------------------
% Balint Kincses 2022
% balint.kincses@uk-essen.de

tblpath=fullfile(intermedpath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work with relative paths, THIS IS THE OUTPUT OF PREVIOUS SCRIPTS OF THE PIPELINE:
load(tblpath);
% define the type of condition in which we are interested in. We use dummy
% coding of the following five different columns in df.raw(healtyh, pla,pain,anticipation,predictable,real_treat). This coding has
% to be specified study wise individually(see: A_run_all_single_condition_summaries_anticip). I do it for the placebo and the control for
% painful stimulation(pain=1-the painful stimulation is modeled, pla=1/0).
% And also for the anticipation (anticipation=1, pla=1/0).

% MZ did a great job and included a lot of additional information in the
% output table. However, I reduced the number of variables
% which we want to keep condition wise. These are different
% from study to study a bit eg: some study has summary placebo intervetion
% from the left and right side so the mean is L&R. We neglect most of these
% information, except these below:
keys={'sub_ID','male','age',...
        'img','cond','rating','rating101', 'x_span',...
        'derivedimg'};
emptytblformissingsubj=table({'NA'},[0],[0],{'NA'},{'NA'},[NaN],[NaN],[0],[0],'VariableNames',keys);
%these might be also interesting...but we skip for now
%       'study_ID', ,
%       'predictable','real_treat','placebo_first','stim_intensity','imgs_per_stimulus_block',...
%       'n_blocks','n_imgs','con_span'};

for conditionrank=1:length(condition)
    for i=studyrank 
        studynm=df.study_ID(i);
        dftmp = df.raw{strcmp(df.study_ID,studynm),1};
        [~,~,~]=mkdir(intermedpath,df.study_dir{strcmp(df.study_ID,studynm),1});
        outpath=fullfile(intermedpath,df.study_dir{strcmp(df.study_ID,studynm),1});
        subjects=unique(dftmp.sub_ID);
        cond_tbl=table();
        clear matlabbatch;
        for j=1:length(subjects)
            
            
            outfilename_pla{j}=strcat(subjects{j},'_',condition(conditionrank),'.nii');
            % The raw table was selected study-wise and provided for the 
            % function below. The study Id was also provided, so only
            % arithmetic defined for that specific study is done. The
            % subject ID is provided, therefore, the correct subject is
            % selected. 
            [curr_tbl,exp,derivedimg]=singlecondsumm_globals(dftmp, ...
                                                            cell2mat(studynm), ...
                                                            subjects(j), ...
                                                            condition(conditionrank)); %coding conditions: placebo (0-control condition,1-placebo condiiton), pain (0-no painful stimulation,1 - pain stimulation), anticipation(0-no anticipitaion period, 1- anticipation period)
            if ~height(curr_tbl)
                fprintf("We do not have %s condition for subject %s in study %s\n",condition(conditionrank),subjects{j},studynm{:})
                cond_tbl(j,:)=emptytblformissingsubj;
% cell2table(cell(1,length(keys)), 'VariableNames', keys);
%                 curr_tbl(:,1:length(keys));
            else
%                 if j==2 || j==3 || j==7
%                     fprintf("This image is calculated from %i original images in study %s\n",height(curr_tbl),studynm{:})
%                 end
                % Here, we create a new table (cond_tbl). This is condition
                % specific and contains all the participant, no matter if
                % that participant has
                cond_tbl(j,:)=curr_tbl(1,keys);
                cond_tbl(strcmp(cond_tbl.sub_ID,subjects(j)),:).cond{1}=condition(conditionrank);
                %todo the new studies rating
                cond_tbl=singlestudratings_globals(cond_tbl, ...
                                                   curr_tbl, ...
                                                    cell2mat(studynm), ...
                                                    subjects(j), ...
                                                    condition(conditionrank));                 
            end
            
    
            if derivedimg
                maki=fullfile(df.study_dir{strcmp(df.study_ID,studynm)},'/',outfilename_pla{j});
                cond_tbl(strcmp(cond_tbl.sub_ID,subjects(j)),:).img{1}=maki{1}; % this is a weird solution, however, as maki always one file it should be fine.
                if df.dateofdatacollection(i)==2015
                    inputimgtmp=fullfile(datapath,curr_tbl.img);
                elseif df.dateofdatacollection(i)==2021
                    inputimgtmp=fullfile(datanewpath,curr_tbl.img);
                end
                matlabbatch{j}.spm.util.imcalc.input = inputimgtmp;
                matlabbatch{j}.spm.util.imcalc.output = convertStringsToChars(outfilename_pla{j});
                matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
                matlabbatch{j}.spm.util.imcalc.expression = exp;
                matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
                matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
                matlabbatch{j}.spm.util.imcalc.options.mask = 0;
                matlabbatch{j}.spm.util.imcalc.options.interp = 1;
                matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
            elseif ~derivedimg && height(curr_tbl)
                %cond_tbl.img{j}=curr_tbl.img;
    
                %copyfile(string(fullfile(datapath,curr_tbl.img)),strcat(outpath,'\',outfilename_pla{j}))
            end
            
            
           
            
    
            
        end
        if height(curr_tbl)~=1 && ~derivedimg
                fprintf("Study has more than one image per condition, but we did not specify how derive that image\n")
        end
        
        if derivedimg && ~any(strcmp(varargin,'noimcalc')) %&& exist(fullfile(cellstr(outpath),outfilename_pla{j}),'file')==0
            spm_jobman('run', matlabbatch);
%             fprintf("The file is already exist,we only update the table\n")
        elseif ~any(strcmp(varargin,'noimcalc'))
            fprintf("We do not have to calculate any images, the %s condition is already one ß/contrast img in %s study\n" + ...
                "we copied the file into the intermediat folder\n",condition(conditionrank),studynm{:})
            
        end
    
    df.(condition(conditionrank)){i,1}=[cond_tbl];
    save(tblpath,'df');
    end
end
end