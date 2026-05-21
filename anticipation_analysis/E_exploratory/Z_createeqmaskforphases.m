function Z_createeqmaskforphases(intermedpath,phasetype,mycontrast,varargin)
% This function aims to contrast the anticipation and pain delivery phase.
%
% Inpust:
%   - intermedpath: the directory for outputs
%   - phasetype: anticip and pain
%   - mycontrast: the different contast images as placebo, control,
%   placebo_minus_control, and placebo_and_control
% 
% 
% 
% 
% s
if any(strcmp(fieldnames(varargin{1}),'pain_placebo')) && any(strcmp(fieldnames(varargin{1}),'anticip_placebo'))
    dfv_masked=varargin{1};
else
    load_a=load(fullfile(intermedpath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
    dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor

end
% masked_stats_pain=zeros(size(dfv_masked.pain_brainmask));
% masked_stats_anticip=zeros(size(dfv_masked.anticip_brainmask));
masked_stats_both=(dfv_masked.pain_brainmask+dfv_masked.anticip_brainmask);
dfv_masked.both_brainmask=(masked_stats_both==2);
for phases=1:length(phasetype)
%     masked_stats=zeros(size(dfv_masked.(strcat(phasetype(phases),"_brainmask"))));
%     masked_stats_pain(dfv_masked.pain_brainmask)=stats;
    for contrast=1:length(mycontrast)
        for studyrank=1:length(dfv_masked.(strcat(phasetype(phases) ,mycontrast(contrast))))
            if ~isempty(dfv_masked.(strcat(phasetype(phases) ,mycontrast(contrast))){studyrank,1})
                studystat=dfv_masked.(strcat(phasetype(phases) ,mycontrast(contrast))){studyrank,1};
                stats=dfv_masked.(strcat(phasetype(phases) ,mycontrast(contrast))){studyrank,1};
                masked_stats=zeros(height(studystat),length(dfv_masked.(strcat(phasetype(phases),"_brainmask"))));
                masked_stats(:,dfv_masked.(strcat(phasetype(phases),"_brainmask")))=stats;
                masked_byboth=masked_stats(:,dfv_masked.both_brainmask);
                dfv_masked.(strcat(phasetype(phases) ,mycontrast(contrast))){studyrank,1}=masked_byboth;
            end
        end



    end
end
mask_img_path=fullfile(intermedpath,'brainmask_logical_50.nii');
dfv_masked.both_brainmask3d=vector2img(dfv_masked.both_brainmask,mask_img_path);
print_image(dfv_masked.both_brainmask, ...
    mask_img_path,fullfile(intermedpath,['full_masked_10_percent_both']))

save(fullfile(intermedpath,['vectorized_images_full_masked_10_percent_equal.mat']),'dfv_masked','-v7.3');