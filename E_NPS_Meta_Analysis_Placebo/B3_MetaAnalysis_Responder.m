%% Meta-Analysis & Forest Plot
% Difference compared to "basic":

% Atlas: None 
% Bingel06: None
% Bingel11: None
% Choi: 100potent AND 1potent vs baseling + First Session + Second (unpublisher) Session
% Eippert: Late + Early and Saline + Naloxone
% Ellingsen: None (non-painful placebo conditions not relevant)
% Elsenbruch: None (50% placebo condition relevant but unavailable)
% Freeman: None
% Geuter: Late + Early Pain, Weak + Strong Placebo
% Huber: None
% Kessner: None
% Kong06: High + Low Pain
% Kong09: None
% R?tgen: None
% Schenk: No Lidocaine & Lidocaine
% Theysohn: None
% Wager06a: None
% Wager06b: None
% Wrobel: Early + Late Pain, Haldol + Saline
% Zeidan: None

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A3_Responder_Sample.mat')

% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period)| heat';...
% 			'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			'Bingel et al. 2011: No vs positive expectations | heat';...
% 			'Choi et al. 2011: No vs low & high effective placebo drip infusion (Exp1 and 2) | electrical';...
% 			'Eippert et al. 2009: Control vs placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs weak & strong placebo cream | heat (early & late)';...
%             'Huber et al. 2013: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocain) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group) | heat*';...
%             };

studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:*';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };
%% Meta-Analysis Ratings
v=find(strcmp(df_resp.variables,'rating'));
for i=1:length(df_resp.studies) % Calculate for all studies except...
    if df_resp.consOnlyRating(i)==0 %...data-sets where both pla and con is available
        if df_resp.BetweenSubject(i)==0 %Within-subject studies
           stats.rating(i)=withinMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        elseif df_resp.BetweenSubject(i)==1 %Between-subject studies
           stats.rating(i)=betweenMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_resp.consOnlyRating==1);
impu_r=nanmean([stats.rating.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.rating(i)=withinMetastats(df_resp.pladata{i}(:,v),impu_r);
end

%% Meta-Analysis NPS
v=find(strcmp(df_resp.variables,'NPSraw'));
for i=1:length(df_resp.studies) % Calculate for all studies except...
    if df_resp.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
        if df_resp.BetweenSubject(i)==0 %Within-subject studies
           stats.NPS(i)=withinMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        elseif df_resp.BetweenSubject(i)==1 %Between-subject studies
           stats.NPS(i)=betweenMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_resp.consOnlyNPS==1);
impu_r=nanmean([stats.NPS.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.NPS(i)=withinMetastats(df_resp.pladata{i}(:,v),impu_r);
end

%% Meta-Analysis MHE
v=find(strcmp(df_resp.variables,'MHEraw'));
for i=1:length(df_resp.studies) % Calculate for all studies except...
    if df_resp.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
        if df_resp.BetweenSubject(i)==0 %Within-subject studies
           stats.MHE(i)=withinMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        elseif df_resp.BetweenSubject(i)==1 %Between-subject studies
           stats.MHE(i)=betweenMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_resp.consOnlyNPS==1);
impu_r=nanmean([stats.MHE.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.MHE(i)=withinMetastats(df_resp.pladata{i}(:,v),impu_r);
end

%% One Forest plot per variable
varnames=fieldnames(stats)
nicevarnames={'Pain ratings',...
              'NPS-score',...
              'VAS-score'};
for i = 1:numel(varnames)
    summary.(varnames{i})=ForestPlotter(stats.(varnames{i}),...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1);
    %hgexport(gcf, ['B3_Meta_Resp_',varnames{i},'.svg'], hgexport('factorystyle'), 'Format', 'svg'); 
    pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
    hgexport(gcf, fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.png']));
    close all;
end

%% Obtain Bayesian Factors
disp('BAYES FACTORS RATINGS')
effect=abs(summary.rating.g.random.summary);
SEeffect=summary.rating.g.random.SEsummary;
bayesfactor(effect,SEeffect,0,[0,0.5,2])

disp('BAYES FACTORS NPS')
effect=abs(summary.NPS.g.random.summary);
SEeffect=summary.NPS.g.random.SEsummary;

bayesfactor(effect,SEeffect,0,[0,0.5,2]) % Bayes factor for normal (two-tailed) null prior placing 95% probability for the mean effect being between -1 and 1
bayesfactor(effect,SEeffect,0,[0,0.5,1]) % "Enthusiast" Bayes factor for normal (one-tailed) null prior placing 95% probability for the mean effect being between -1 and 0
bayesfactor(effect,SEeffect,0,[abs(summary.rating.g.random.summary),...
                               summary.rating.g.random.SEsummary,2]) % Bayes factor for normal null prior identical with overall behavioral effect
