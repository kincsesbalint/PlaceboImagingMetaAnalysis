function Schenk_et_al_2017_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Schenk et al.,2017 and
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
% We do have two folders per subject. Lieven sent a basic processing of the
% data and the one what he used in the publication. Discussing with Tamas the two
% is similar but not the same. (eg: convolving with the HRF causes differences)
% I would suggest to use the one which was used in the publication.
% Based on the mean age, the group 1 is the treatment context, while group
% 2 is the stimulus context. Also the placebo grp is the group 1, and the
% contrgrp is the group 2 in the table.
% todo double chekc with Lieven about the groups(Is group 1 really the
% placebo group what I want to include).
% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Schenk2017\data3';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'sub\d\d','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Schenk2017\data3\behav\behavdaten.csv');
 

% % the used scale anchors:  " visual analog scale (VAS; 0 –100)" 
%  VAS (0 –100; end points labeled with “no pain at all”
% and "unbearable pain," 8 s).
% 
% The beahvior data is an SPSS file, so I converted to csv with R. The
% table has many columns. The abbrevioation which are interested to us means the following:
% PRTc1-9: pain rating treatment conditioning
% PRCc1-9: pain rating control conditioning
% PRTt1-9: pain rating treatment testphase
% PRCt1-9: pain rating control testphase
% ERTc1-9: expectancy rating treatment conditioning
% ERCc1-9: expectancy rating control conditioning
% ERTt1-9: expectancy rating treatment testphase
% ERCt1-9: expectancy rating control testphase
% We should use only the pain rating from the testphase in group 1/placgrp
painratings=readtable(xls_path,'VariableNamingRule','preserve');
allcolnames=painratings.Properties.VariableNames;
allpaincolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'PR\wt') )));
controlcolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'PRCt') )));
placebocolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'PRTt') )));
painratings=painratings(painratings.placgrp==1,[allpaincolnms allcolnames([2 85 87 90 92])]);


% based on the txt file sent by Lieven, the participants performed two runs
% in the scanner. A conditioning and a test phase. In each run 9-9 trial were performed, the placebo and control respectively.
% The conditioning is not interesting to us but was similar as the test only they received
% decreased temperatures (especially:  Of each set of these nine stimuli, two had a slightly lower
% temperature and two a slightly higher temperature (⫾0.2°C) in a pseudorandomized order.) 
% todo check if this is the same for the test session or there they
% received fixed temps.
% In the test phase the order of stimuli was randomized. In the
% modelling(based on the attached txt, the first is the placebo and the
% second is the control condition.(visualizing these it is clear the order
% was randomized).
% checking subj4 and subj9 SPM file the ß images correspond to the
% following:
% {'Sn(2) Anti1*bf(1)' } 19
% {'Sn(2) Pain1E*bf(1)'} 20
% {'Sn(2) Pain1L*bf(1)'} 22
% {'Sn(2) Anti2*bf(1)' } 27
% {'Sn(2) Pain2E*bf(1)'} 28
% {'Sn(2) Pain2L*bf(1)'} 30
% Lieven wrote that (txt file) in the modeling first is the placebo and the second is
% the control. todo double check with him that  bc it does not seem to be
% solid.
interestingimages=[
    's6wbeta_0019' % anticipation placebo 
    's6wbeta_0020' % early pain placebo
    's6wbeta_0022' % late pain placebo

    's6wbeta_0027' % anticipation control
    's6wbeta_0028' % early pain control
    's6wbeta_0030' % late pain control
    ];

nsubj=height(painratings);
for subjrank=1:nsubj
    ind_subjID=painratings.SHAREID(subjrank);
    ind_subjonedigit0start=cellfun(@(x) sprintf('%02d',x),{ind_subjID},'UniformOutput',false);
    currfolder=fullfile(datapath_nwstudy,studydir,['sub' ind_subjonedigit0start{1}],'functional\');
    
    currSPMpath = fullfile(currfolder,'SPM.mat');
    load(currSPMpath);
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    xLength=size(SPM.xX.X,1);
 
    nparametricmodulatorspersession=4; % they used the prediction errors as parametric modulators in the early and late pain separately in the control and placebo ocndition
    % using parametric modulators in the modelling seems to change the structure of the SPM.mat somewhere
    numbofsessions=length(SPM.Sess);
    regrinonesess=(length(SPM.xX.name)-numbofsessions)/numbofsessions;
    for conditionrank=1:height(interestingimages)
        betimgnum=str2num(interestingimages(conditionrank,end-1:end));
        sessionnum=((length(SPM.xX.name)-numbofsessions)/numbofsessions<betimgnum)+1; % this suggest a "symmetrical" modelling of two sessions,it does not work with more than 2 sessions
        img{subjrank,conditionrank}=fullfile(studydir,['sub' ind_subjonedigit0start{1}],'functional\', strcat(interestingimages(conditionrank,:),'.nii'));
        if any([19 27] == betimgnum) %anticipation
            condnnum=3;
        elseif any([20 28] == betimgnum) %early pain
            condnnum=4;
        elseif any([22 30] == betimgnum) %late pain
            condnnum=5;
        end
        i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
        n_imgs(subjrank,conditionrank)=xLength;
        x_span(subjrank,conditionrank)=xSpanRaw(betimgnum);
        con_span(subjrank,conditionrank)=length(x_span); %it is always 1 as we use the ß images,we need to calculate the mean later on
        n_blocks(subjrank,conditionrank)=length(SPM.Sess(sessionnum).U(condnnum).ons); %we read out the anticipation occurence as it is supposed to be 9 always
        % this is suboptimal and only be used for this study(the issue is that they used parametric modulation of the early pain,
        % which changes the relation of the beta img number and the SPM.Sess.U.nameing relation eg: we have 16 regressors per session but only 12 rows in SPM.Sess.U.name....)
        imgs_per_stimulus_block(subjrank,conditionrank)=mean(SPM.Sess(sessionnum).U(condnnum).dur);
        i_condition_in_sequence(subjrank,conditionrank)=sessionnum;
        if betimgnum==28 || betimgnum==30 % the control
            cond{subjrank,conditionrank}="control";
            pain(subjrank,conditionrank)=1; %Matthias coded this as 2 and 3 for early and late pain,however, as we do not analyse separately them,and always calculate the mean of the two. I simple code them her as 1
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=0;
            
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, controlcolnms},'omitnan');
        
        elseif betimgnum==20 || betimgnum==22 % the placebo
            cond{subjrank,conditionrank}="placebo";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, placebocolnms},'omitnan');
        elseif betimgnum==27 % anticipation control
            cond{subjrank,conditionrank}="anticipation_control";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, controlcolnms},'omitnan');
        elseif betimgnum==19 % anticipation placebo
            cond{subjrank,conditionrank}="anticipation_placebo";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, placebocolnms},'omitnan');
        end
    n_imgs(subjrank,conditionrank)=xLength; 
    subjID(subjrank,conditionrank)=ind_subjonedigit0start;
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
%demogdata
gend=repmat(painratings.Geschlecht,height(interestingimages),1);
age=repmat(painratings.Alter,height(interestingimages),1);
temps=repmat(painratings.Temperatur,height(interestingimages),1);
 
% %% Collect all Variables in Table
schenk2017=table(img);
schenk2017.img=img;
schenk2017.study_ID=repmat({'schenk17'},size(schenk2017.img));
schenk2017.sub_ID=subjID;
schenk2017.male=gend; %1 is male and 2 is female (based on the numbers reported in the manuscript)
schenk2017.age=age; 
schenk2017.healthy=ones(size(schenk2017.img));
schenk2017.pla=pla;
schenk2017.pain=pain;
schenk2017.anticipation=anticipation;
schenk2017.predictable=zeros(size(schenk2017.img)); %the order of placebo and control trials in the test condition was random, there were one stimulation site
schenk2017.real_treat=zeros(size(schenk2017.img));  %
schenk2017.cond=cond;
schenk2017.stim_side=repmat({'L'},size(schenk2017.img)); % as they claim in the manuscript htey applied the TENS on the left arm, most probably they stimulated that site
schenk2017.placebo_first=ones(size(schenk2017.img)); %todo find out what is this variable, the see info about the ordering of the placebo and control trials
schenk2017.i_condition_in_sequence=i_condition_in_sequence;
schenk2017.rating=rating;  %
schenk2017.rating101=rating; % they used VAS100, see anchorw above
schenk2017.stim_intensity=temps;
schenk2017.imgs_per_stimulus_block = imgs_per_stimulus_block;
schenk2017.n_blocks      =n_blocks; % According to SPM
schenk2017.n_imgs      =n_imgs; % Images per Participant (in total from the two sessions,but we only use one session here(the test session))
schenk2017.x_span        =x_span;
schenk2017.con_span      =con_span; %beta images are used

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'schenk17')),'raw'}={schenk2017};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
