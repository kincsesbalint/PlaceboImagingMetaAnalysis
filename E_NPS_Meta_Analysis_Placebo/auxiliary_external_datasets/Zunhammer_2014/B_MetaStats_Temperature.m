%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
clear
% Path to add Forest Plots to:
% Add folder with Generic Inverse Variance Methods Functions
load('../../../../../Oxytocin_NPS/Oxytocin_Zunhammer_2014_NPS_SIIPS.mat')

% Labels for Forest Plots
studyIDtexts={};

% For meta_analysis only non-oxytocin results from Zunhammer et al. are
% used as for comparion
df=zunhammer_results(zunhammer_results.oxytocin==0,:);
df.temp=categorical(df.temp);
%% Meta-Analysis
temp_steps={
           sprintf('44.7 vs 45.5%cC',char(176))
           sprintf('45.5 vs 45.9%cC',char(176))
           sprintf('45.9 vs 46.3%cC',char(176))
           sprintf('46.3 vs 46.7%cC',char(176))
           sprintf('46.7 vs 47.1%cC',char(176))
           sprintf('47.1 vs 47.5%cC',char(176))
           };

zun_stats.rating(1)=withinMetastats(df.rating(df.temp=='44.7'),df.rating(df.temp=='45.5'));
zun_stats.rating(2)=withinMetastats(df.rating(df.temp=='45.5'),df.rating(df.temp=='45.9'));
zun_stats.rating(3)=withinMetastats(df.rating(df.temp=='45.9'),df.rating(df.temp=='46.3'));
zun_stats.rating(4)=withinMetastats(df.rating(df.temp=='46.3'),df.rating(df.temp=='46.7'));
zun_stats.rating(5)=withinMetastats(df.rating(df.temp=='46.7'),df.rating(df.temp=='47.1'));
zun_stats.rating(6)=withinMetastats(df.rating(df.temp=='47.1'),df.rating(df.temp=='47.5'));

zun_stats.NPS(1)=withinMetastats(df.NPS(df.temp=='44.7'),df.NPS(df.temp=='45.5'));
zun_stats.NPS(2)=withinMetastats(df.NPS(df.temp=='45.5'),df.NPS(df.temp=='45.9'));
zun_stats.NPS(3)=withinMetastats(df.NPS(df.temp=='45.9'),df.NPS(df.temp=='46.3'));
zun_stats.NPS(4)=withinMetastats(df.NPS(df.temp=='46.3'),df.NPS(df.temp=='46.7'));
zun_stats.NPS(5)=withinMetastats(df.NPS(df.temp=='46.7'),df.NPS(df.temp=='47.1'));
zun_stats.NPS(6)=withinMetastats(df.NPS(df.temp=='47.1'),df.NPS(df.temp=='47.5'));

save('Zunhammer_2014_NoOxytocin_Session_Rating.mat','zun_stats');

%% One Forest plot for ratings and NPS
% Do not calculate random-effects GIV summary... all conditions are from
% the same study, therefore this is not the appropriate model!
ForestPlotter([zun_stats.rating],...
                  'studyIDtexts',temp_steps,...
                  'outcomelabel','Rating difference (Hedges'' g)',...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Zunhammer_2014_NoOxytocin_Session_Rating.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Zunhammer_2014_NoOxytocin_Session_Rating.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Zunhammer_2014_NoOxytocin_Session_Rating.png');

ForestPlotter([zun_stats.NPS],...
                  'studyIDtexts',temp_steps,...
                  'outcomelabel','NPS difference (Hedges'' g)',...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Zunhammer_2014_NoOxytocin_Session_NPS.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Zunhammer_2014_NoOxytocin_Session_NPS.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Zunhammer_2014_NoOxytocin_Session_NPS.png');