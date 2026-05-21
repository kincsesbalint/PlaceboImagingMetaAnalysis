function ZZ_checkimageorientationinfo_anticip(datapath,datnewpath,intermedpath,contrasts,varargin)
% % --------------------------------------------------------------------
% This is a helper function to explore a bit the different studies image space.
% Issue to explore: some studies might used different standards for registration and therefore the resclicing is not a proper "registration".
%
% The script read the first participant's, one contrast image (we do not need more as theoretically all are in the same space in one study)
% in each study and compare the header of that to our target space.
%
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

maskpath=fullfile(intermedpath,'brainmask_logical_50.nii');
if exist(maskpath, 'file') == 2
    disp('Mask exists already ');
else
    maskheader=spm_vol(strcat('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\','pattern_masks\brainmask.nii'));
    mask=spm_read_vols(maskheader);
    mask=mask>0.5;
    % maskpath=strcat('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\','pattern_masks\brainmask_logical.nii');
    
    outheader=maskheader;
    outheader.fname=maskpath;
    spm_write_vol(outheader,mask);
end

%% Loop through studies, create 2x2x2 images, add to table 
tic

goodstuds=0;
for i=1:size(df,1) % Loop over studies
    for k=1:length(contrasts) % Loop over target contrasts, just specify one
        df.(contrasts{k}){i}.norm_img=repmat({''},height(df.(contrasts{k}){i}),1);
        for j=1 %go with the first subject
            
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
           
                
            affdiff=compareheaders(maskpath,infilepath);
            if affdiff==0
                goodstuds=goodstuds+1;
            end
            checkcoverage(maskpath,infilepath)

        end
        end
    end

end
disp('the number of good studies')
disp(goodstuds)
end


function affine_diff=compareheaders(file1,file2)

    
    V1 = spm_vol(file1);
    V2 = spm_vol(file2);
    
    disp('--- File 1 ---');
    disp(V1.fname);
    disp(V1.dim);        % matrix size
    disp(V1.mat);        % voxel->world affine (orientation/position/voxel size)
    disp(V1.dt);         % datatype
    
    disp('--- File 2 ---');
    disp(V2.fname);
    disp(V2.dim);
    disp(V2.mat);
    disp(V2.dt);
    disp('--- affine difference: ---');
    affine_diff = V2.mat - V1.mat;
    disp(affine_diff);
    
    fprintf('Max abs diff in mat: %.6f\n', max(abs(affine_diff(:))));
    
end

function checkcoverage(file1,file2)
    V1 = spm_vol(file1);
    V2 = spm_vol(file2);
    
    bb1 = spm_get_bbox(V1);   % 2x3: [min; max] in mm
    bb2 = spm_get_bbox(V2);
    
    disp('BB1 (mm):'); disp(bb1);
    disp('BB2 (mm):'); disp(bb2);
end
