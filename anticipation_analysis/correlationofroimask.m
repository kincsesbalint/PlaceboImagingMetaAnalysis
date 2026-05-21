%load dfv
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent.mat')
% %load df
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\data_frame.mat')
% vectorizeddptfceboostnegcorr=v_masked_BK('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\anticip\rndm\anticip_diff_r_ptfce_neg.nii');
% signifmask=vectorizeddptfceboostnegcorr>4.37;
% within_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'within') & df.anticipismodeled==1);
% between_nonCon=find(df.contrast_imgs_only==0 & strcmp(df.study_design,'between') & df.anticipismodeled==1);
% conOnly=find(df.contrast_imgs_only==1 & df.anticipismodeled==1);
% 
% n_studies=length([within_nonCon; conOnly]');
% hamm(n_studies).n=[];
% hamm(n_studies).r=[];
% hamm(n_studies).g=[];
% hamm(n_studies).se_g=[];
% hamm(n_studies).delta=[];
% hamm(n_studies).r_external=[];
% hamm(n_studies).n_r_external=[];
% 
% 
% i=1;
% for studyrank=[within_nonCon; conOnly]'
%     h(i)=subplot(4,5,i);
%     
%     myhist(i)=subplot(4,5,i);
%     if ismember(studyrank,within_nonCon)
%         
%         hamm(studyrank)=summarize_within_BK(dfv_masked.anticip_placebo{studyrank,1}(:,signifmask),dfv_masked.anticip_control{studyrank,1}(:,signifmask));
% %     scatter(mean((dfv_masked.anticip_placebo{studyrank,1}(:,signifmask)-dfv_masked.anticip_control{studyrank,1}(:,signifmask)),2), ...
% %         df.GIV_stats_rating101(studyrank,1).delta)
% %IMPORTANT: here a minus sign is added to the ratingdifference, so
%         scatter(h(i),mean(hamm(studyrank).delta,2,'omitnan'),-df.GIV_stats_rating101(studyrank,1).delta)
%         voxelwisecorvals{i}=fastcorrcoef_BK(hamm(studyrank).delta,-df.GIV_stats_rating101(studyrank,1).delta,'exclude_nan');
%         activity=hamm(studyrank).delta;
%         ratings=df.GIV_stats_rating101(studyrank,1).delta; %
% 
%         hist(myhist(i),voxelwisecorvals{i})
%         fprintf('The (across voxels) mean of correlation values:%f\n', mean(voxelwisecorvals{i}))
%         fprintf('The correlation of mean activation:%f\n',fastcorrcoef_BK(mean(hamm(studyrank).delta,2),df.GIV_stats_rating101(studyrank,1).delta,'exclude_nan'))
%     else
% %         pla=dfv.(cons{3}).(df.study_ID{studyrank});
%         impu_r=mean([hamm.r],'omitnan');
%         hammok=dfv_masked.anticip_placebo_minus_control{studyrank,1}(:,signifmask);
%         hamm(studyrank)=summarize_within_BK(hammok,impu_r);
%         
%         scatter(h(i),mean(hammok,2),-df.GIV_stats_rating101(studyrank,1).delta)
%     end
%     hamm(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
%     hamm(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
%                                      isnan(ratings)));
%     lsline(h(i))
%     title(h(i), df.study_ID{studyrank}+"-study")
%     hold on
% 
% %     end
% i=i+1;
% end

% summarize_within_BK(dfv_masked.anticip_placebo{studyrank,1}(:,signifmask),dfv_masked.anticip_control{studyrank,1}(:,signifmask))
% 
% 
% % check the mean standardaized correlation across the significant voxels
% mean(anticip_diffcontr.r_external.random.summary(signifmask(dfv_masked.anticip_brainmask)))


% summaryy=GIV_summary_BK(hamm,{'r_external'});

%% when I save the stats function from the original run and load it
% load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\placebostats_forcorrvis.mat')
load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\vectorized_images_full_masked_10_percent.mat')
vectorizeddptfceboostnegcorr=v_masked_BK('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\zz_imgs\anticip\rndm\anticip_diff_r_ptfce_neg.nii');
signifmask=vectorizeddptfceboostnegcorr>4.37;
i=1;

allratingsnorm=[];
allbrainactivitynorm=[];
for studyrank=1:length(placebo_stats) %stats
    
    if ~isempty(placebo_stats(studyrank).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        % with this condition we should only exclude between subject studies (2of them)
%         h(i)=subplot(4,5,i);
        %IMPORTANT here the sign of the behavior variable is flipped as in
        %the wholebrain paper
        RGB = [255 153 i*12]/256;
        %scatter(h(i),mean(placebo_stats(studyrank).delta(:,signifmask(dfv_masked.anticip_brainmask)),2,'omitnan'),-df.GIV_stats_rating101(studyrank).delta)
        ratings=df.GIV_stats_rating101(studyrank).delta; %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script. 
        ratings=-ratings; %ratings originally show placebo-control(see previous row comment), and now we change so higher values mean higher placebo analgesia
        ratingsnormalized=(ratings-mean(ratings))/std(ratings);

        brainacitvity=mean(placebo_stats(studyrank).delta(:,signifmask(dfv_masked.anticip_brainmask)),2,'omitnan');
        brainacitvitynormalized=(brainacitvity-mean(brainacitvity))/std(brainacitvity);

        allratingsnorm=vertcat(allratingsnorm,ratingsnormalized);
        allbrainactivitynorm=vertcat(allbrainactivitynorm,brainacitvitynormalized);
%         scatter(brainacitvitynormalized,ratings,[],RGB)
        scatter(brainacitvitynormalized,ratingsnormalized,[],RGB)
        calccorr=fastcorrcoef_BK(placebo_stats(studyrank).delta(:,signifmask(dfv_masked.anticip_brainmask)),-df.GIV_stats_rating101(studyrank).delta,'exclude_nan');
        fprintf("previously calculated correlation in %s study:%f\n",df.study_ID{studyrank},mean(placebo_stats(studyrank).r_external(:,signifmask(dfv_masked.anticip_brainmask)),2,'omitnan'))
        fprintf("newly calculated correlation in %s study:%f\n",df.study_ID{studyrank},mean(calccorr,'omitnan'))
%         h(i)=lsline;
        
%         set(h(i),'color','r')
        

        coracrossvoxels=-mean(placebo_stats(studyrank).r_external(:,signifmask(dfv_masked.anticip_brainmask)),2,'omitnan');
%         title(h(i), df.study_ID{studyrank}+"-study"+string(coracrossvoxels))
        hold on
%         activity=placebo_stats(studyrank).delta; %this is also placebo-control delta, as it was specified in this order above in the summary_within arguments.
%         ratings=df.GIV_stats_rating(studyrank).delta(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments.
%         placebo_stats(studyrank).r_external=fastcorrcoef_BK(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
%         placebo_stats(studyrank).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
%                                              isnan(ratings))); % AND non nan-ratings
%     else
%         stats(studyrank).r_external=[];%NaN(1,n_voxel);
%         stats(studyrank).n_r_external=[];%NaN(1,n_voxel);
    
    i=i+1;
    end
    
    
end
%lsline()
%% save output image

% printImage_BK(anticip_diffcontr.r_external.random.summary,mask_path,dfv_masked,[intermedpath '\zz_imgs\anticip\rndm\anticip_diff_r_rndm_summary'])