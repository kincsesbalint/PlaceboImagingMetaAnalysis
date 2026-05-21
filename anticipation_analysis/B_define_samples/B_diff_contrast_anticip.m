function B_diff_contrast_anticip(datapath,datanewpath,intermedpath,phase,operation, varargin)
% % --------------------------------------------------------------------
% 
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
%   -phase: the pain or anticipation phase
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
% df=df(1,:);
% studyranks=1:nstudy;
isTableCol = @(t, thisCol) ismember(thisCol, t.Properties.VariableNames);
if any(strcmp(operation,'diff'))
    naminginf='-';
    colnmop='_minus_';
    operation_eq='i1-i2';
elseif any(strcmp(operation,'sum'))
    naminginf='_and_';
    operation_eq='(i1+i2)/2';
    colnmop='_and_';
end


if any(strcmp(phase,'pain'))
    
%     withinstds=studyranks(~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within'));
    withinstds=df.study_ID(~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within'));
    condvar={'pain_placebo','pain_control',['pain_placebo' colnmop 'control']};
    nmbase=['placebo' naminginf 'control'];
    outflnmbase=['_' nmbase '.nii'];
    if strcmp(operation,'sum')
%         withinstds=studyranks(~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within') & ~strcmp(df.study_ID,'atlas'));
        withinstds=df.study_ID(~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within') & ~strcmp(df.study_ID,'atlas'));
%         withinstds= withinstds(withinstds~=1);
        %we need to remove the Atlas study in case of summary, as they used remifentanil, and previously we define the placebo_and_control condition.
    end
    if ~isTableCol(df,condvar{3})
        df.(condvar{3})=cell(nstudy,1);
    end
elseif any(strcmp(phase,'anticip'))
    
%     withinstds=studyranks(logical(df.anticipismodeled) & ~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within'));
    withinstds=df.study_ID(logical(df.anticipismodeled) & ~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within'));
    condvar={'anticip_placebo','anticip_control',['anticip_placebo' colnmop 'control']};
    nmbase=['anticip_placebo' naminginf 'control'];
    outflnmbase=['_' nmbase '.nii'];
    if strcmp(operation,'sum')
%         withinstds=studyranks(logical(df.anticipismodeled) & ~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within') & ~strcmp(df.study_ID,'atlas'));
        withinstds=df.study_ID(logical(df.anticipismodeled) & ~logical(df.contrast_imgs_only) & strcmp(df.study_design,'within') & ~strcmp(df.study_ID,'atlas'));
%         withinstds= withinstds(withinstds~=1);
        %we need to remove the Atlas study in case of summary, as they used remifentanil, and previously we define the placebo_and_control condition.
    end
    if ~isTableCol(df,condvar{3})
        df.(condvar{3})=cell(nstudy,1);
    end
end

wager_MI_studyid=find(strcmp(df.study_ID,'wager04b_michigan'));
%% Loop through studies and create contrasts
for i_study=1:length(withinstds)
%     studyrank=withinstds(i_study);
    studyrank=find(strcmp(df.study_ID,withinstds(i_study)));
    %Get current study as table
    
    % For all studies add empty contrast-array
    
%     if (~logical(df.contrast_imgs_only(studyrank))) && strcmp(df.study_design(studyrank),'within')
        % studies where only contrasts are available, are treated
        % separately, below the loop.
        % & no contrasts will be calculated for between-group designs.        
        % Define outpath
%         study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
        nsubj=height(unique(df.raw{studyrank}(:,"sub_ID")));
        outpath=fullfile(intermedpath,df.study_dir{studyrank});
        
        for subjrank=1:nsubj
            pla_df=df.(condvar{1}){studyrank}(subjrank,:);
            con_df=df.(condvar{2}){studyrank}(subjrank,:);
            if df.dateofdatacollection(studyrank)==2021
                pathtoimg=datanewpath;
            elseif df.dateofdatacollection(studyrank)==2015
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
            outfilename{subjrank}=char(strcat(string(df.(condvar{1}){studyrank}{subjrank,"sub_ID"}),outflnmbase));
            matlabbatch{subjrank}.spm.util.imcalc.input = [infilepath_pla;...
                                                    infilepath_con
                                                    ];
            matlabbatch{subjrank}.spm.util.imcalc.output = outfilename{subjrank};
            matlabbatch{subjrank}.spm.util.imcalc.outdir = cellstr(outpath);
            matlabbatch{subjrank}.spm.util.imcalc.expression = operation_eq;
            matlabbatch{subjrank}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{subjrank}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{subjrank}.spm.util.imcalc.options.mask = 0;
            matlabbatch{subjrank}.spm.util.imcalc.options.interp = 1;
            matlabbatch{subjrank}.spm.util.imcalc.options.dtype = 4;

            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.img={fullfile(df.study_dir{studyrank},outfilename{subjrank})};
            new_con_tbl.cond={nmbase};
            if any(strcmp(operation,'diff'))
                new_con_tbl.rating=pla_df.rating-con_df.rating;
                new_con_tbl.rating101=pla_df.rating101-con_df.rating101;
            elseif any(strcmp(operation,'sum'))
                new_con_tbl.rating=mean([pla_df.rating,con_df.rating],'omitnan');
                new_con_tbl.rating101=mean([pla_df.rating101,con_df.rating101],'omitnan');
            end
            
            new_con_tbl.x_span=nanmean([pla_df.x_span,...
                                        con_df.x_span]);
            if studyrank==wager_MI_studyid && strcmp(operation,'diff')
                % For wager michigan beta images are available but for
                % behavior we have contrasts only.
                new_con_tbl.rating = df.pain_placebo{wager_MI_studyid}(subjrank,:).rating*-1; % Ratings inverted! control>placebo
                new_con_tbl.rating101 = df.pain_placebo{wager_MI_studyid}(subjrank,:).rating101*-1; % Ratings inverted! control>placebo
            end
            new_con_tbl.derivedimg=1;
            % Add new subject-level contrast table to subject
            df.(condvar{3}){studyrank}(subjrank,:)=new_con_tbl;
            % Put modified study-level table back  to subject
        end 
        % Actually create contrast images
        if ~any(strcmp(varargin,'noimcalc'))
            df.study_ID(studyrank)
            spm_jobman('run', matlabbatch);
        end
        matlabbatch=[];
        
%     end
end

%% Manually add contrast-only studies - it has already done in the previous funciton
% (there are no within-subject difference contrasts for between-group studies ) Kessner
% and Ruetgen!! BUT we have to the sum.
if strcmp(operation,'sum') 
    i=find(strcmp(df.study_ID,'kessner'));
    i_pla=strcmp(df.(condvar{2}){i}.img,'NA');

    df.(condvar{3}){i}(~i_pla,:)=df.(condvar{2}){i}(~i_pla,:);
    df.(condvar{3}){i}(i_pla,:)=df.(condvar{1}){i}(i_pla,:);
end
if strcmp(operation,'sum') && any(strcmp(phase,'pain'))
    i=find(strcmp(df.study_ID,'ruetgen'));
    i_pla=strcmp(df.pain_control{i}.img,'NA');
    df.pain_placebo_and_control{i}(~i_pla,:)=df.pain_control{i}(~i_pla,:);
    df.pain_placebo_and_control{i}(i_pla,:)=df.pain_placebo{i}(i_pla,:);
end
save(fullfile(intermedpath,'data_frame.mat'),'df');



end