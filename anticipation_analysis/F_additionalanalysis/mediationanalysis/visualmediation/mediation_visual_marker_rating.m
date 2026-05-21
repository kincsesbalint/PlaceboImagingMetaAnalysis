% intermedpath='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles'; 
% load(fullfile(intermedpath,'data_frame'),'df');
% 
% % load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent_equalmask.mat')
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent_equal.mat')
% %select the image which we focus on now:
% % img='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\anticip\anticip_diff_r_rnd_pos_ptfce.nii.gz'; %correlation
% img='C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\anticip\anticip_diff_g_rnd_neg_ptfce.nii.gz'; %difference
% %select the corresponding threshold
% %anticip_diff(check my notes from 03.03.2024)
% % correlation (pla-contr vs rating diff)
% %       two-sided:4.62
% %       one-sided(pos):4.44
% %       one-sided(neg):4.45
% %
% % difference (pla-contr)
% %       two-sided:4.68
% %       one-sided(pos):4.52
% %       one-sided(neg):4.49 - this was used in the most recent solution (01.04.2026-14 voxels)
% 
% thresholdfrommaxstat=4.45;%4.62; %4.7 for the placebo-control contrast and 4.62 for the correlation between brain activity and behavior contrast
% vectorizedimg=v_masked_BK(img);
% % vectorizedimg_masked=vectorizedimg(dfv_masked.both_brainmask); this was
% % here but was too lazy to load in
% vectorizedimg_masked=vectorizedimg(dfv_masked.anticip_brainmask);
% signifmask=vectorizedimg_masked>thresholdfrommaxstat;
% % find(signifmask);
% sum(signifmask)

%it seems that the deactivation in the visual area means, that, activation
%in the control condition, is decreased (dissappear, equals to zero, i.e.
%one chacek the simple anticipation image)(one can imagein is always a
%deactivation, but more deactivaiton in the placebo, however, that is not
%the case)
activity=[];
counter=1;
for studyrank=1:height(df)
    if ~isempty(dfv_masked.anticip_placebo{studyrank,1})
        activity.antplac(counter)=avgnormalize(dfv_masked.anticip_placebo{studyrank,1}(:,signifmask));
        activity.antcontr(counter)=avgnormalize(dfv_masked.anticip_control{studyrank,1}(:,signifmask));
        activity.painplac(counter)=avgnormalize(dfv_masked.pain_placebo{studyrank,1}(:,signifmask));
        activity.paincontr(counter)=avgnormalize(dfv_masked.pain_control{studyrank,1}(:,signifmask));
        activity.studynm(counter)=df.study_ID(studyrank);
        counter=counter+1;
    end
end

data = [activity.antplac', activity.antcontr',  activity.painplac',activity.paincontr'];
figure()
% Create a boxplot
boxplot(data, 'Labels', {'Anticip placebo',  'Anticip control', 'Pain placebo','Pain control'});
title('Standardised effect size over the negative cluster');
xlabel('condition x phase');
ylabel('Cohens d');
hold on;  % Allow multiple plots on the same axes

% Plot individual data points as an overlay
numGroups = size(data, 2);
for i = 1:numGroups
    x = i + randn(size(data, 1), 1) * 0.1;  % Add jitter for visibility
    plot(x, data(:, i), 'r.', 'MarkerSize', 10);
end
numGroups = size(data, 1);
colors = colormap(lines(numGroups));
for i = 1:size(data, 1)
    lineColors = colors(i, :);
    plot([1, 2, 3 ,4], [data(i, 1), data(i, 2),data(i, 3),data(i, 4)], '-','Color', lineColors);  % Connect Group 1 and Group 2
end


hold off

for studyrank=1:height(df)
    if ~isempty(dfv_masked.anticip_placebo{studyrank,1}) && strcmp(df.study_design{studyrank},'within') && ~df.contrast_imgs_only(studyrank)

        df.visualdeactivation{studyrank}=mean(dfv_masked.anticip_placebo{studyrank,1}(:,signifmask)-dfv_masked.anticip_control{studyrank,1}(:,signifmask),2,'omitnan');

    elseif isempty(dfv_masked.anticip_placebo{studyrank,1}) && strcmp(df.study_design{studyrank},'within') && df.contrast_imgs_only(studyrank) && df.anticipismodeled(studyrank)
        df.visualdeactivation{studyrank}=mean(dfv_masked.anticip_placebo_minus_control{studyrank,1}(:,signifmask),2,'omitnan');

    end
end



function meancohend=avgnormalize(data)
    meancohend=mean(mean(data,2,'omitnan')./std(data,0,2,'omitnan'),'omitnan');
end