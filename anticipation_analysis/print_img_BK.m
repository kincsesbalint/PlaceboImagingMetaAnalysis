function print_img(outpath,stat,suffix,threshold_index)    
    if ~exist('threshold_index','var')
        threshold_index=ones(size(stat)); % if not threshold_index is supplied, the threshold will be set so high, that it will not apply
    end
    
    if ismember(suffix,{'p_map','p_map_perm','p_map_perm_FWE'})
        outimg=ones(size(statmask)); % For p-maps the default should be values of 1, as very low p-values are sometimes printed as plain 0's.
    else
        outimg=zeros(size(statmask));
    end
    
    outimg(statmask)=stat.*threshold_index;
    print_image(outimg,mask_path,fullfile(outpath,[label,suffix]));
end