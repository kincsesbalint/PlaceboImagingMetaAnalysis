function printImage_anticip(stats,maskpath,logicalmask,outbasename,phase)
% Modified version of MZ script to visualize results.
% inputs: 
%   - stats: the statistics we want to visualize
%   - maskpath: path to a mask which header we can use for saving the data
%   - logicalmask: the output of the vectorized and mask missing voxels
%   scripts (contains the brainmask and the brainmask3d structures)
%   -the name of the output file, containing the path as well
% 
if strcmp(phase,"pain")
    masked_stats=zeros(size(logicalmask.pain_brainmask));
    masked_stats(logicalmask.pain_brainmask)=stats;
elseif strcmp(phase,"anticip")
    masked_stats=zeros(size(logicalmask.anticip_brainmask));
    masked_stats(logicalmask.anticip_brainmask)=stats;
elseif strcmp(phase,"both")
    masked_stats=zeros(size(logicalmask.both_brainmask));
    masked_stats(logicalmask.both_brainmask)=stats;
end


% Backtransform to image
maskheader=spm_vol(maskpath);
mask=logical(spm_read_vols(maskheader));
masking=mask(:);
outImg=zeros(size(mask));

% Print Pain all
outImg(masking)=masked_stats;
% outpath=fullfile([outbasename,'.nii']);
outpath=strcat(outbasename,'.nii');
outheader=maskheader;
outheader.fname=outpath;
outheader.dt=[4,0]; %data_type (see: spm_type) should be at least int16 to allow for negative values
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
outheader.descrip='spm - algebra';
spm_write_vol(outheader,outImg);

% if any(sum(masked_stats<0)) %if the picture contains positive and negative values
%     % Print Pain positive effects only
%     outImg(masking)=masked_stats;
%     outImg(outImg<0)=0;
%     outpath=fullfile([outbasename,'_pos.nii']);
%     outheader=maskheader;
%     outheader.fname=outpath;
%     outheader.dt=[4,0]; %data_type (see: spm_type) should be at least int16 to allow for negative values
%     outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
%     spm_write_vol(outheader,outImg);
% 
%     % Print Pain negative effects only
%     outImg(masking)=masked_stats.*-1;
%     outImg(outImg<=0)=0;
%     outpath=fullfile([outbasename,'_neg.nii']);
%     outheader=maskheader;
%     outheader.fname=outpath;
%     outheader.dt=[4,0]; %data_type (see: spm_type) should be at least int16 to allow for negative values
%     outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
%     spm_write_vol(outheader,outImg);
% end
end