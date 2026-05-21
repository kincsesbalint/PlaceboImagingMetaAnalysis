function A_meta_analysis_markeranaticip(intermedpath,forsetplotpath) %
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
df_name='data_frame.mat';
load(fullfile(intermedpath,df_name),'df');
    
%% Meta-Analysis
% note that standardized effect sizes are based on 
% the between-subject SD of summarized signal (summarized
% across images) at each voxel, not single-image SD (as within-subject
% images were not collected)
% df=df(1:20,:);

variable_select={'rating','rating101'};%,'NPS','stim_intensity'}; %'MHEraw','SIIPS',
ratingvars={'rating','rating101'};
imagingvars={'nps','siips'};
for vars=1:length(variable_select)
    if any(strcmp(['GIV_stats_' variable_select{vars}],df.Properties.VariableNames))
        fprintf("WARNING!! The %s colum exist, imputing contast rating studies will be affected!!!\n",['GIV_stats_' variable_select{vars}])
        fprintf("One consider to uncomment the following two lines and rerun the analysis:\n df.GIV_stats_rating=[]\n df.GIV_stats_rating101=[]\n")
%         df.GIV_stats_rating=[];
%         df.GIV_stats_rating101=[];
    end
end

% Loop for studies where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_placebo=df.pain_placebo{i};
%         df_placebo=vertcat(df_placebo{:});
        df_control=df.pain_control{i};
%         df_control=vertcat(df_control{:});
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df.contrast_ratings_only(i)==1);
%         img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df.contrast_imgs_only(i)==1);
        if  ~rating_var_and_con_only %&& ~img_var_and_con_only % where both pla and con is available.
            if strcmp(df.study_design{i},'within') %Use withinMetastats for within-subject studies
               df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),df_control.(currvar));
            elseif strcmp(df.study_design{i},'between') %Use betweenMetastats for between-subject studies
               df.(['GIV_stats_',currvar])(i)=summarize_between([df_placebo.(currvar)],[df_control.(currvar)]);
            end
        end
    end
end

%% For some (within-subject) studies  pla>con contrasts are available, only.
% % For these studies within-subject correlations have to be imputed (mean of
% % within-subject correlation of all other studies is used).
% 
% Loop for studies with contrast-only ratings
for j=1:length(ratingvars)
    currvar=ratingvars{j};
    impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
%     impu_r=nanmean([df_mz.df.(['GIV_stats_',currvar]).r]);
    for i=find(df.contrast_ratings_only==1)'
%         if i~=20
        df_placebo=df.pain_placebo_minus_control{i};
%         df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
%         end
    end
end

% Loop for studies with contrast-only imaging data
% for j=1:length(imagingvars)
%     currvar=imagingvars{j};
%     impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
%     for i=find(df.contrast_imgs_only==1)'
%         df_placebo=df.subjects{i}.placebo_minus_control;
%         df_placebo=vertcat(df_placebo{:});
%         df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
%     end
% end


%% One Forest plot per variable

if ~exist(forsetplotpath, 'dir')
   mkdir(forsetplotpath)
end
varnames={'rating'};
%           'NPS'};
nicevarnames={'Pain ratings'};%,...
%               'NPS response'};
summary=[];
for i = 1:numel(varnames)
    dataforplotting=[df.(['GIV_stats_',varnames{i}])];
    dataforplotting=dataforplotting(~isnan(vertcat(dataforplotting(:).mu)));
    summary.(varnames{i})=forest_plotter(dataforplotting,...
                  'study_ID_texts',df.study_citations(1:25),... %must rule out the Koban study here...
                  'outcome_labels',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',0,... %'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0,...
                  'X_scale',2);
%     hgexport(gcf, fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
%     hgexport(gcf, fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.eps']), hgexport('factorystyle'), 'Format', 'eps');
    hgexport(gcf, fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.png']));
end
close all;
%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    summary.(varnames{i})=forest_plotter([df.(['GIV_stats_',varnames{i}])],...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...%'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(forsetplotpath,['B1_Meta_All_',varnames{i},'.png']));
end

close all
%% Obtain Bayes Factors
disp('BAYES FACTORS RATINGS')
effect=abs(summary.rating.g.random.summary);
SEeffect=summary.rating.g.random.SEsummary;
bayes_factor(effect,SEeffect,0,[0,0.5,2])

% disp('BAYES FACTORS NPS')
% effect=abs(summary.NPS.g.random.summary)
% SEeffect=summary.NPS.g.random.SEsummary

bayes_factor(effect,SEeffect,0,[0,0.5,2]) % Bayes factor for normal (two-tailed) null prior placing 95% probability for the mean effect being between -1 and 1
bayes_factor(effect,SEeffect,0,[0,0.5,1]) % "Enthusiast" Bayes factor for normal (one-tailed) null prior placing 95% probability for the mean effect being between -1 and 0
bayes_factor(effect,SEeffect,0,[abs(summary.rating.g.random.summary),...
                               summary.rating.g.random.SEsummary,2]) % Bayes factor for normal null prior identical with overall behavioral effect
save(fullfile(intermedpath,'data_frame.mat'), 'df');
end