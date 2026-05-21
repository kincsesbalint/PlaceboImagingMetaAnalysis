function Hartmann_et_al_2020_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Hartmann et al.,2020 and
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
% Helene rerun the analysis and shared the ß images with me. However, that
% is different what they used in hteir main analysis.--> double check with
% her how she used these ß iamges in her main analysis (get the mean of the
% two runs and the sum of anticip and stimulation?)
% she also shared with me 74 participants data but they only used 45 in
% their analysis(exclude non-responders and individuals with too much
% motion), we need to decide if we include the additional guys...
% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Hartmann2020\data';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'pimb\d\d_\d\d','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Hartmann2020\pimb18_data.xlsx');
 

% % the used scale anchors:  " scale from 0 = not painful to 8 = extremely painful)"
% %
% 
painratings=readtable(xls_path,"UseExcel",true,"Sheet","pain ratings");
painratings = painratings(strcmp(painratings.target, 'self') & strcmp(painratings.intensity, 'pain'), :);

for subj=1:height(painratings)
    tmpsubj{subj}=painratings.id{subj}(end-1:end);
    subjID_tmp(subj,:)=str2num(tmpsubj{subj});
end
painratings.subjID=subjID_tmp;
interestingimages=[
    'beta_0005' %anticipation placebo run 1 srhp-self right hand pain
    'beta_0007' %anticipation control run 1 slhp-self left hand pain
    'beta_0013' %placebo pain run 1 - srhp -self right hand pain
    'beta_0015' %control pain run 1 - slhp-self left hand pain
    'beta_0030' %anticipation placebo run 2 srhp-self right hand pain
    'beta_0032' %anticipation control run 2 slhp-self left hand pain
    'beta_0038' %placebo pain run 2 - srhp -self right hand pain
    'beta_0040' %control pain run 2 - slhp-self left hand pain
    ];


for subjrank=1:nsubj
    currfolder=fullfile(datapath_nwstudy,studydir,subjectfolders{subjrank},'analysis\analysis_cb_meta\');
    ind_subjID=str2num(subjectfolders{subjrank}(8:9));
    currSPMpath = fullfile(currfolder,'SPM.mat');
    load(currSPMpath);
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    xLength=size(SPM.xX.X,1);
 
    
    numbofsessions=length(SPM.Sess);
    regrinonesess=(length(SPM.xX.name)-numbofsessions)/2;
    for conditionrank=1:height(interestingimages)
        betimgnum=str2num(interestingimages(conditionrank,end-1:end));
        sessionnum=floor(betimgnum/length(SPM.xX.name)/2)+1; %todo double check if it is working properly, see also Schenk2017 solution
        img{subjrank,conditionrank}=fullfile(studydir,subjectfolders{subjrank},'analysis\analysis_cb_meta\',strcat(interestingimages(conditionrank,:),'.nii'));

        i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
        n_imgs(subjrank,conditionrank)=xLength;
        x_span(subjrank,conditionrank)=xSpanRaw(betimgnum);
        con_span(subjrank,conditionrank)=length(x_span); %it is always 1 as we use the ß images,we need to calculate the mean later on
        n_blocks(subjrank,conditionrank)=length(SPM.Sess(sessionnum).U(mod(betimgnum,regrinonesess)).ons);
        imgs_per_stimulus_block(subjrank,conditionrank)=mean(SPM.Sess(sessionnum).U(mod(betimgnum,regrinonesess)).dur);
        i_condition_in_sequence(subjrank,conditionrank)=sessionnum;
        if betimgnum==15 || betimgnum==40 % the control
            cond{subjrank,conditionrank}="control";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=0;
            
            rating(subjrank,conditionrank)=str2double(painratings{strcmp(painratings.hand, 'control') & painratings.subjID==ind_subjID, "sp_mean"});
        
        elseif betimgnum==13 || betimgnum==38 % the placebo
            cond{subjrank,conditionrank}="placebo";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=str2double(painratings{strcmp(painratings.hand, 'placebo') & painratings.subjID==ind_subjID, "sp_mean"});
        elseif betimgnum==7 || betimgnum==32 % anticipation control
            cond{subjrank,conditionrank}="anticipation_control";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=str2double(painratings{strcmp(painratings.hand, 'control') & painratings.subjID==ind_subjID, "sp_mean"});
        elseif betimgnum==5 || betimgnum==30 % anticipation placebo
            cond{subjrank,conditionrank}="anticipation_placebo";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=str2double(painratings{strcmp(painratings.hand, 'placebo') & painratings.subjID==ind_subjID, "sp_mean"});
        end
    n_imgs(subjrank,conditionrank)=xLength; 
    subjID(subjrank,conditionrank)=subjectfolders(subjrank);
    end
    
    
%     fprintf('---------------------------------------------------\n')
end

img=vertcat(img(:));
sub=vertcat(i_sub(:));
x_span=vertcat(x_span(:));
con_span=vertcat(con_span(:));
n_blocks=vertcat(n_blocks(:));
cond=vertcat(cond(:));
i_condition_in_sequence=vertcat(i_condition_in_sequence(:)); %not sure what this variable means exactly, 
% maybe it signs the rank of the condition in the experiment(here we
% differentiate the images from different runs,but within a run it was
% randmoized so we simple give1 to beta images in the first run and 2 to
% bet images in the second run
n_imgs=vertcat(n_imgs(:));
pain=vertcat(pain(:));
pla=vertcat(pla(:));
anticipation=vertcat(anticipation(:));
imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
subjID=vertcat(subjID(:));
rating=vertcat(rating(:));
% 
% 
% % Create a version of ratings on a 101pt-(%)Scale (0%, no pain, 100%, maximum pain)
% %  values for very painful (rating of 7 on a scale from 0 = not painful to 8 = extremely painful), medium
% painful (rating of 4) and not painful, but perceivable (rating of 1)
% discussing with Helena it means that...
rating101=(rating-1)*100/7;
rating101(rating101<0)=0;
 
 
% %% Collect all Variables in Table
hartmann20=table(img);
hartmann20.img=img;
hartmann20.study_ID=repmat({'hartmann20'},size(hartmann20.img));
hartmann20.sub_ID=subjID;
hartmann20.male=ones(size(hartmann20.img)); %only males based on the paper todo
hartmann20.age=ones(size(hartmann20.img))*(32);  %MISSING: Mean age according to paper todo
hartmann20.healthy=ones(size(hartmann20.img));
hartmann20.pla=pla;
hartmann20.pain=pain;
hartmann20.anticipation=anticipation;
hartmann20.predictable=ones(size(hartmann20.img)); 
hartmann20.real_treat=zeros(size(hartmann20.img));  %
hartmann20.cond=cond;
hartmann20.stim_side=repmat({'L'},size(hartmann20.img)); %todo
hartmann20.placebo_first=ones(size(hartmann20.img)); %todo
hartmann20.i_condition_in_sequence=i_condition_in_sequence;
hartmann20.rating=rating;  %
hartmann20.rating101=rating101; % Create a version of ratings on a 101pt-(%)Scale (0%, no pain, 100%, maximum pain)
hartmann20.stim_intensity=NaN(size(hartmann20.img)); %todo             
hartmann20.imgs_per_stimulus_block = imgs_per_stimulus_block;
hartmann20.n_blocks      =n_blocks; % According to SPM
hartmann20.n_imgs      =n_imgs; % Images per Participant (in total from the two session)
hartmann20.x_span        =x_span;
hartmann20.con_span      =con_span; %con images used

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'hartmann')),'raw'}={hartmann20};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
