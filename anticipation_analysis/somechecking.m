for i=1:20
    subjs=unique(matthiasorigdf.raw{i,1}.sub_ID);
    onsubj=subjs{1};

    majom=matthiasorigdf.raw{i,1}((strcmp(matthiasorigdf.raw{i,1}.sub_ID,onsubj)) & ...
        (cellfun(@isempty,regexp(matthiasorigdf.raw{i,1}.img,'.*summarized_for_meta.*'))),:);

    numofimagesinthedfrawtbl=length(unique(majom.img));
    fprintf('There are %i raw images per subject from %s study in MZs table\n',numofimagesinthedfrawtbl,matthiasorigdf.study_ID{i})
    if all(cellfun(@isempty,matthiasorigdf.subjects{i,1}.hi_pain))
        fprintf('Study %s has NO high pain condition\n',matthiasorigdf.study_ID{i})
    else
        fprintf('Study %s has high pain condition\n',matthiasorigdf.study_ID{i})
    end

    if all(cellfun(@isempty,matthiasorigdf.subjects{i,1}.lo_pain))
        fprintf('Study %s has NO low pain condition\n',matthiasorigdf.study_ID{i})
    else
        fprintf('Study %s has low pain condition\n',matthiasorigdf.study_ID{i})
    end

    if all(cellfun(@isempty,matthiasorigdf.subjects{i,1}.med_pain))
        fprintf('Study %s has NO med pain condition\n',matthiasorigdf.study_ID{i})
    else
        fprintf('Study %s has high med condition\n',matthiasorigdf.study_ID{i})
    end
    
    if all(cellfun(@isempty,matthiasorigdf.subjects{i,1}.nomed_pain))
        fprintf('Study %s has NO nomedpain condition\n',matthiasorigdf.study_ID{i})
    else
        fprintf('Study %s has nomedpain condition\n',matthiasorigdf.study_ID{i})
    end
    fprintf('----------------------------------------------------\n\n')
end