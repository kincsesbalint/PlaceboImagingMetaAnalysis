%Mediation script for testing putamen and pain rating correlation in more
%detaile. Is that something which was mediated by the NPS or SIIPS
%expression during the pain rating?
% Also including age and gender as additional covariates in the equation.

load('C:\Users\lenov\Documents\PICO_DATA\originaldatastructure\intermediatefiles\data_frame.mat')

idx=0;
allsubj=0;
for studyrank=1:height(df) %stats
        if ~isempty(df.GIV_stats_rating(studyrank).delta) && df.anticipismodeled(studyrank) && ~isempty(df.putamensctivation{studyrank}) %%~isempty(stats(studyrank).pla)% necessary as "sum" returns 0 for [] for some stupid reason
            idx=idx+1;
            % collecting study wise metainfo
            nsubj=sum(~isnan((df.GIV_stats_rating(studyrank).delta)));
            studysubj(idx)=nsubj;
            allsubj=allsubj+nsubj;
            allstudyrank(idx)=studyrank;
            %this was specified by the F_additionalanalysis/putamenrole.mlx
            putplacact_x=df.putamensctivation{studyrank}; %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.

            signatureresponse_m=df.pain_placebo_minus_control{studyrank,1}.NPS;
%             signatureresponse_m=df.pain_placebo_minus_control{studyrank,1}.siips;
            rating_behav_y=df.GIV_stats_rating(studyrank).delta;%(~ex_subj,:); %this is placebo-control delta, as it was the order in the summary_within arguments in the A_meta_analysis_placebo_all_BK script.
            
%             if dozscore
%                 zscore(putplacact_x, 0, 'omitnan')
%             end
            %update: the previous rating difference represented
            %placebo-control--> change to control-placebo so higher vlaues
            %would mean higher behavior analgesi
            rating_behav_y=-rating_behav_y;
            [paths, stats] = mediation(putplacact_x, rating_behav_y, signatureresponse_m,'plots', 'verbose')
%             mod1=fitlm(putplacact_x,signatureresponse_m);
%             a_est=mod1.Coefficients("x1",:).Estimate;
%             a_est_se=mod1.Coefficients("x1",:).SE;
%         
%             mod2=fitlm(horzcat(putplacact_x,signatureresponse_m),rating_behav_y);
%             b_est=mod2.Coefficients("x2",:).Estimate;
%             b_est_se=mod2.Coefficients("x2",:).SE;
% 
%             all_a_est(idx)=a_est;
%             all_b_est(idx)=b_est;
%                varratio=(sqrt(a_est_se)./sqrt(b_est_se));
%                 ab_stand(idx)=a_est.*b_est.*varratio;
% 
%                 se_ab=sqrt(((a_est.^2).*(b_est_se.^2))+((b_est.^2).*(a_est_se.^2)));
%                 se_ab_aroian=sqrt(((a_est.^2).*(b_est_se.^2))+((b_est.^2).*(a_est_se.^2))+(a_est_se.^2).*(b_est_se.^2));
%                 se_stand_sobel(idx)=varratio.*se_ab;
%                 z_ab_sobel(idx)=(a_est.*b_est)./se_ab;
%                 z_ab_Aroian(idx)=(a_est.*b_est)./se_ab_aroian;
%                 ab_weight(idx)=sqrt(nsubj);

        end
end