function Koban_et_al_2017_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Koban et al.,2017 and
% the interested variables in the PICo project.
% % --------------------------------------------------------------------
% It creates a table in which each row contains information from an image
% (from all participants each condition) which was shared by the authors
% (IMPORTANT: not all the shared images are listed in this table). We
% mainly focus on ß/con maps reflecting brain activation to a painful
% stimulation and its anticipation phase in placebo and control conditions.
%
% % --------------------------------------------------------------------
% Balint Kincses 2022
% balint.kincses@uk-essen.de
% clear all

%% Load images paths
% and extract/assign experimental conditions from/to image names
% Leonie shared with me Path a images from the mediation analysis, which is
% equal to "corresponding to a contrast pre>post intervention". That is the
% control-placebo. No inidivudal ß images are available. This is similar to
% the wager04a_princeton study, in which they also only provided contrast
% images (and calculated X(-1) of those images).
% They did not share SPM.mat files.
% They included two groups, one control and placebo group. The placebo
% group has before intervention and after intervention measurement so we
% can use that group as a within subject design. However, all demogprahical
% data in the paper describes the whole sample and not only the
% subsample.(therefore all of the demographical included as NAs)
% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Koban2017\Mediation_PathA\Med_PhysPain_PathA_indiv';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'S*_DPSP_\d\d.img','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Koban2017\Behavior\DPSP_NPS_painratings.xlsx');
 

% They used affect ratings(so they are comparable to the social pain part
% of the design). 5 point scale (from 1 ⫽ very bad to 5 ⫽ very good).
% These cannot really be used as they are affect ratings and not intensity
% ratings(as all the other studies). --> most probably exlclude from the
% correlation analysis.
%
% 
painratings=readtable(xls_path,"UseExcel",true,"Sheet","Sheet1");
% painratings = [];%painratings(strcmp(painratings.target, 'self') & strcmp(painratings.intensity, 'pain'), :);

% for subj=1:height(painratings)
%     tmpsubj{subj}=painratings.id{subj}(end-1:end);
%     subjID_tmp(subj,:)=str2num(tmpsubj{subj});
% end
% painratings.subjID=subjID_tmp;
interestingimages=[
     'control-placebo' %they only have one interesting image per subject:control-placebo
    ];

placebogroup_IDs=painratings(strcmp(painratings.Group, 'P'), "DPSP_ID");

for subjrank=1:nsubj
    
    ind_subjID=string(subjectfolders{subjrank}(end-10:end-4)); % subject ID,based on the second number in the image file
    if any(strcmp(ind_subjID,table2array(placebogroup_IDs)))
        for conditionrank=1:height(interestingimages)
            img{subjrank,conditionrank}=fullfile(studydir,subjectfolders{subjrank});
    
            i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
            cond{subjrank,conditionrank}='control-placebo';
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=-1;
            anticipation(subjrank,conditionrank)=0;
%             rating(subjrank,conditionrank)='Na';
            
            
        end
    end
    subjID{subjrank,conditionrank}=ind_subjID(1,1);
    
    
%     fprintf('---------------------------------------------------\n')
end

img=vertcat(img(:));

% x_span=vertcat(x_span(:));
% con_span=vertcat(con_span(:));
% n_blocks=vertcat(n_blocks(:));
cond=vertcat(cond(:));
% i_condition_in_sequence=vertcat(i_condition_in_sequence(:)); %not sure what this variable means exactly, 
% maybe it signs the rank of the condition in the experiment(here we
% differentiate the images from different runs,but within a run it was
% randmoized so we simple give1 to beta images in the first run and 2 to
% bet images in the second run
% n_imgs=vertcat(n_imgs(:));
pain=vertcat(pain(:));
pla=vertcat(pla(:));
anticipation=vertcat(anticipation(:));
% imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
subjID=cellstr(vertcat(subjID{:}));
% rating=vertcat(rating(:));
% 
 
%  NaN(size(wager_princeton.img))
% %% Collect all Variables in Table
koben17=table(img);
koben17.img=img;

koben17.study_ID=repmat({'koban17'},size(koben17.img));
koben17.sub_ID=subjID;
koben17.male=NaN(size(koben17.img)); %see above todo: double check with Leonie
koben17.age=NaN(size(koben17.img));  %see above todo: double check with Leonie
koben17.healthy=ones(size(koben17.img));
koben17.pla=pla;
koben17.pain=pain;
koben17.anticipation=anticipation;
koben17.predictable=ones(size(koben17.img)); %control was always followed by placebo(they get rid of the time effect as they aplied a control group with no placebo induction with suggestion)
koben17.real_treat=zeros(size(koben17.img));  %
koben17.cond=cond;
koben17.stim_side=repmat({'L'},size(koben17.img)); 
koben17.placebo_first=ones(size(koben17.img)); 
koben17.i_condition_in_sequence=NaN(size(koben17.img));
koben17.rating=NaN(size(koben17.img));  % no pain intensity ratings, only affect ratings
koben17.rating101=NaN(size(koben17.img)); % no pain intensity ratings, only affect ratings
koben17.stim_intensity=NaN(size(koben17.img)); %todo double check with Leonie             
koben17.imgs_per_stimulus_block = NaN(size(koben17.img)); %todo souble check with Leonie
koben17.n_blocks      =NaN(size(koben17.img)); % NO SPM.mat file is available
koben17.n_imgs      =NaN(size(koben17.img)); % NO SPM.mat file is available
koben17.x_span        =NaN(size(koben17.img)); % NO SPM.mat file is available
koben17.con_span      =NaN(size(koben17.img)); % NO SPM.mat file is available
koben17(cellfun(@isempty,koben17.img),:)=[]; % Delete missing sessions

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'koban')),'raw'}={koben17};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
