function A_apply_tissuemasks_anticip(intermedpath,contrasts,varargin)
% % --------------------------------------------------------------------
% This is a modification of MZ's original function to screen for outlier
% images. It uses the CanLabCore functions to calculate individual values
% of grey, white, csf, brain and no-brain masks.
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
% Balint Kincses 2022
% balint.kincses@uk-essen.de

% addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
maskpath=strcat('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\','pattern_masks\');
maskfile={'grey',...
          'white',...
          'csf',...
          'brainmask',...
          'inverted_brainmask'};

df_path=fullfile(intermedpath,'data_frame.mat');
load(df_path,'df');

n=size(df,1);
h = waitbar(0,'Calculating tissue mask averages, studies completed:');
tmpmask.grey=0;
tmpmask.white=0;
tmpmask.csf=0;
tmpmask.brainmask=0;
tmpmask.inverted_brainmask=0;
%%
for studyid=1:n %loop over studies
    for condition=1:length(contrasts) %loop over conditions
        for masktype=1:length(maskfile)
                df.(contrasts{condition}){studyid}.(maskfile{masktype})=repmat(NaN,height(df.(contrasts{condition}){studyid}),1);
        end
        for subjectid=1:size(df.(contrasts{condition}){studyid},1) %Loop over subjects
            
            if ~isempty(df.(contrasts{condition}){studyid}.norm_img{subjectid})
                in_img= fmri_data(fullfile(intermedpath,df.(contrasts{condition}){studyid}.norm_img{subjectid}),...
                                    [fullfile(maskpath,maskfile{4}),'.nii']);
                for masktype=1:length(maskfile)
                    [tmpmask.(maskfile{masktype}),~]=apply_mask(in_img,[fullfile(maskpath,maskfile{masktype}),'.nii'],'pattern_expression','ignore_missing');
                    df.(contrasts{condition}){studyid}(subjectid,:).(maskfile{masktype})=tmpmask.(maskfile{masktype});
                end

            end
        end
    save(df_path,'df');
    end
    waitbar(studyid / n,h);
end
    
close(h)
end