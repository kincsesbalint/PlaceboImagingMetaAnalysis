function A_equalize_image_size_and_mask_anticip(datapath,datnewpath,intermedpath,contrasts,varargin)
% % --------------------------------------------------------------------
% This is a modification of MZ's original function to register images to a standard template.
% It uses the data_matrix (filled in the previous step of the pipeline),
% and apply registration to all the images in the specified
% contrasts/conditions (eg:placebo, anticip_placebo...)
%
% The script read the image column from each condition, and use that
% image to specify it path (use the info of the date of data collection and
% if the image was derived or provided by original authors). The table will
% be updated with a norm_image, which always saved in the intermediate
% folder. This image is normalized to the mask defined at the beginning.
% Therefore, all the resulting image will be in the same space.
%
% describe what the funciton exaclty does. 
% % --------------------------------------------------------------------
% Inputs:
%   -datapath: the path to the data collected in 2015
%   -datanewpath: the path to the data collected in 2021 (it is separated
%   from the previous one bc in the 2015 data, the derived and intermediate
%   files are sinked there, while here we save them in a separate folder).
%   -intermedpath: the path for saving the intermediate files (see comment for 
%  the previous input)
%   -contrast: the conditions(which are separet columns in the data_frame)
%   
%  
% 
% OPTION: argument 'noimcalc' skips actual calculation of images and just
% updates the df
% 
% 
% %%%
% Outputs:
% -data_frame.mat with updated condition columns. The registered image is calculated 
% and saved in the intermediate folder.
% 
% 
% % --------------------------------------------------------------------
% Balint Kincses 2022
% balint.kincses@uk-essen.de

%% Load target images as df
df_path=fullfile(intermedpath,'data_frame.mat');
load(df_path,'df');
%% Create logical mask from SPM's brainmask at 50% brain probability
%Load mask
%maskheader=spm_vol('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask.nii');

maskheader=spm_vol(strcat('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\','pattern_masks\brainmask.nii'));
mask=spm_read_vols(maskheader);
mask=mask>0.5;
% maskpath=strcat('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\','pattern_masks\brainmask_logical.nii');
maskpath=fullfile(intermedpath,'brainmask_logical_50.nii');
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);

% contrasts={'pain_placebo',...
%            'pain_control',...
%            'placebo_minus_control',...
%            'placebo_and_control'};

% contrasts={'placebo',...
%             'control',...
%             'placebo_minus_control'};
%     ,...
%            'pain_control',...
%            'placebo_minus_control',...
%            'placebo_and_control'};

% 
% ,...
%            'hi_pain',...
%            'lo_pain',...
%            'med_pain',...
%            'nomed_pain'

%% Loop through studies, create 2x2x2 images, add to table 
tic
h = waitbar(0,'Calculating masked images, studies completed:');
for i=1:size(df,1) % Loop over studies
    for k=1:length(contrasts) % Loop over target contrasts
        df.(contrasts{k}){i}.norm_img=repmat({''},height(df.(contrasts{k}){i}),1);
        for j=1:size(df.(contrasts{k}){i},1) %Loop over subjects
            
            curr_tbl=df.(contrasts{k}){i}(j,:);
%             curr_tbl=df.subjects{i}.(contrasts{k}){j};
        if ~strcmp("NA",curr_tbl.img{:})
            infilename=curr_tbl.img{:};
            if df.dateofdatacollection(i)==2015
                pathtofile=datapath;
            elseif df.dateofdatacollection(i)==2021
                pathtofile=datnewpath;
            end

            if curr_tbl.derivedimg
                infilepath=fullfile(intermedpath,infilename);
            else 
                infilepath=fullfile(pathtofile,infilename);
            end
            %Construct output-path for resized/masked images and add to table
            [path,filename,ext]=fileparts(infilename);
            outfilename=fullfile(path,strcat(filename,ext));
            if length(strfind(outfilename, '\')) >1
                index=strfind(outfilename, '\');
                newoutfilenm=outfilename;
                for kkk=2:length(index)
                    perjel=index(kkk);
                    newoutfilenm = [newoutfilenm(1:perjel - 1), '_', newoutfilenm(perjel + length('\'):end)];
                end
                outfilename=newoutfilenm;
            end
            if j==2 || j==4 || j==7
                fprintf('%s\n',outfilename)
            end

            norm_img={outfilename};
            %df.(contrasts{k}){i}(j,:)=curr_tbl;
            sub_ID=table2cell(df.(contrasts{k}){i}(j,'sub_ID'));
            df.(contrasts{k}){i}(j,:).norm_img=norm_img;
            matlabbatch{1}.spm.util.imcalc.input = {
                                                    maskpath
                                                    infilepath
                                                    };
            matlabbatch{1}.spm.util.imcalc.output = fullfile(intermedpath,outfilename);
            matlabbatch{1}.spm.util.imcalc.outdir = {};
            % Image re-slicing to 2x2x2 mm is a side effect of masking, as
            % imcalc always re-slices to the first image entered (the
            % mask).
            matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
            if ~any(strcmp(varargin,'noimcalc'))
                spm_jobman('run', matlabbatch);
            end
        end
        end
    end
    h = waitbar(i / height(df));
    %% Save updated df
    save(df_path,'df');
end
close(h)
end
