function Schenk_et_al_2020_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Schenk et al.,2020 and
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
% 
% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Schenk2020\data';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'sub\d\d','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Schenk2020\data\behav\behavdaten.csv');
 

%  the used scale anchors:  (VAS) used to collect
% pain ratings (ranging from 0 = no pain to 100 = maximum tolerable
% pain).
% 
% The beahvior data is an SPSS file, so I converted to csv with R. The
% table has many columns. The abbrevioations which are intereseting to us mean the following:
% SHAREID(1-colnumber), age(2), sex(3)
% Placfirst(6)-placebo condition is first run(second)
% Plactop(7) - placebocondition is proximal skinpatch(distal)
% Temp(8) - it is multiplied by 10
% Pcg1-12: pain ratings placebo conditioning(observation phase),
% participant rated how much pain the observed guy feel
% Pcb1-12: pain rating control conditioning(observationl phase)
% Ptg1-12: pain rating placebo testphase
% Ptb1-12: pain rating control testphase
% Utg1-12: unpleasentness Plac
% Utb1-12: unpleasentness control
% ExpG: expectancy rating treatment
% ExpB: expectancy rating control 
% we only use the pain ratings and some demog data
painratings=readtable(xls_path,'VariableNamingRule','preserve');
allcolnames=painratings.Properties.VariableNames;
allpaincolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'Pt\w\w') )));
controlcolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'Ptb') )));
placebocolnms=allcolnames(~cellfun(@isempty, (regexp(allcolnames,'Ptg') )));
painratings=painratings(:,[allpaincolnms allcolnames([1 2 3 6 7 8]+1)]);



% There is no additional informaiton about the meaning of the different ß
% iamges. Based on the SPM files I concluded the followings:
% session1-2 for the observational phase
% {'Sn(1) MDcuep*bf(1)' }
% {'Sn(1) MDpainp*bf(1)'}
% {'Sn(1) vasPOp*bf(1)' }
% {'Sn(1) vasSp*bf(1)'  }
% {'Sn(2) MDcuec*bf(1)' }
% {'Sn(2) MDpainc*bf(1)'}
% {'Sn(2) vasPOc*bf(1)' }
% {'Sn(2) vasSc*bf(1)'  }
% session3-4 for the test phase
% {'Sn(3) cuep*bf(1)'   } anticipation placebo 9
% {'Sn(3) painp*bf(1)'  } pain placebo 10
% {'Sn(3) vasPp*bf(1)'  } pain rating placebo
% {'Sn(3) vasUp*bf(1)'  } unpleasentness rating placebo

% {'Sn(4) cuec*bf(1)'   } anticipation control 13
% {'Sn(4) painc*bf(1)'  } pain control 14
% {'Sn(4) vasPc*bf(1)'  } pain rating control
% {'Sn(4) vasUc*bf(1)'  } unpleasentness rating control

 
interestingimages=[
    'beta_0009' % anticipation placebo 
    'beta_0010' % pain placebo
    
    'beta_0013' % anticipation control
    'beta_0014' % pain control
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
 
    
    numbofsessions=length(SPM.Sess);
    regrinonesess=(length(SPM.xX.name)-numbofsessions)/numbofsessions;
    for conditionrank=1:height(interestingimages)
        betimgnum=str2num(interestingimages(conditionrank,end-1:end));
        sessionnum=(((length(SPM.xX.name)-numbofsessions)/numbofsessions)*3<betimgnum)+3; % this is specific for this study(4sessions)
        img{subjrank,conditionrank}=fullfile(studydir,['sub' ind_subjonedigit0start{1}],'functional\', strcat(interestingimages(conditionrank,:),'.nii'));
        if any([9 13] == betimgnum) %anticipation
            condnnum=1;
        elseif any([10 14] == betimgnum) %pain
            condnnum=2;
        end
        i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
        n_imgs(subjrank,conditionrank)=xLength;
        x_span(subjrank,conditionrank)=xSpanRaw(betimgnum);
        con_span(subjrank,conditionrank)=length(x_span); %it is always 1 as we use the ß images,we need to calculate the mean later on
        n_blocks(subjrank,conditionrank)=length(SPM.Sess(sessionnum).U(condnnum).ons); 
        imgs_per_stimulus_block(subjrank,conditionrank)=mean(SPM.Sess(sessionnum).U(condnnum).dur);
        i_condition_in_sequence(subjrank,conditionrank)=sessionnum;
        if betimgnum==14  % the control
            cond{subjrank,conditionrank}="control";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=0;
            
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, controlcolnms},'omitnan');
        
        elseif betimgnum==10 % the placebo
            cond{subjrank,conditionrank}="placebo";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, placebocolnms},'omitnan');
        elseif betimgnum==13 % anticipation control
            cond{subjrank,conditionrank}="anticipation_control";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=mean(painratings{painratings.SHAREID==ind_subjID, controlcolnms},'omitnan');
        elseif betimgnum==9 % anticipation placebo
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
gend=repmat(painratings.sex,height(interestingimages),1);
age=repmat(painratings.age,height(interestingimages),1);
temps=repmat(painratings.Temp/10,height(interestingimages),1); %they shared the 10x of the temperatures
placebo_first=repmat(painratings.Placfirst,height(interestingimages),1);
 
% %% Collect all Variables in Table
schenk2020=table(img);
schenk2020.img=img;
schenk2020.study_ID=repmat({'schenk20'},size(schenk2020.img));
schenk2020.sub_ID=subjID;
schenk2020.male=gend; %1 is male and 2 is female (based on the numbers reported in the manuscript)
schenk2020.age=age; 
schenk2020.healthy=ones(size(schenk2020.img));
schenk2020.pla=pla;
schenk2020.pain=pain;
schenk2020.anticipation=anticipation;
schenk2020.predictable=ones(size(schenk2020.img)); %there were two separate stimulation site and the placebo and control trials were performed in different runs
schenk2020.real_treat=zeros(size(schenk2020.img));  %
schenk2020.cond=cond;
schenk2020.stim_side=repmat({'NA'},size(schenk2020.img)); % todo double check with Lieven where they stimulate
schenk2020.placebo_first=placebo_first;
schenk2020.i_condition_in_sequence=i_condition_in_sequence;
schenk2020.rating=rating;  %
schenk2020.rating101=rating; % they used VAS100, see anchors above
schenk2020.stim_intensity=temps;
schenk2020.imgs_per_stimulus_block = imgs_per_stimulus_block;
schenk2020.n_blocks      =n_blocks; % According to SPM
schenk2020.n_imgs      =n_imgs; % Images per Participant (in total from the four,but we only use two sessions here(the test session))
schenk2020.x_span        =x_span;
schenk2020.con_span      =con_span; %beta images are used

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'schenk20')),'raw'}={schenk2020};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
