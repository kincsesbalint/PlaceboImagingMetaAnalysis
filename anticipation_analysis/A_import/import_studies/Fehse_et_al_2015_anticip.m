function Fehse_et_al_2015_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Fehse et al.,2015 and
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
% it seems all the subject has the same contrast defined, the order in the SPM.xCon are the same 
% (based on the SPM.mat files).
% Some participants (s20,s21,s30) only have two sessions in total(see
% behavior table comment for more info, too much pain??). It seems one
% before and one after the  intevention. Subjects have 36 ß images (except
% s20,s21,s30 - who have 18). We can use both the ß images and the contrast
% images (which are the mean of the two sessions).
% Three subjects data (s09, s12, s27) is in the dropout folder. Most
% probably they were exlcuded(no info in the manuscript), so I would NOT
% include them (s09, s12, s27) as well. In the original behav table I found
% the following infos:
%   -s09: no behavior data at all
%   -s12: no behavior data at all
%   -s27: "wegen technischer Probleme rausnehmen, Hypersensibilisiert wegen
%   Kälte"
%   
% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Fehse2015/analysis/ersteRechnung/1st/';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'s\d\d','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Fehse2015\analysis\behavioral\pain.xls');
% the used scale anchors:  "from 0 to 100 (NRS, 0 being no pain and 100 the
% worst unbearable pain)."
% Some participants have missing data:s21 does not have 1B,s20 does not
% have 2B, s28 most porbably has no 2B(see below),s30 does not have 1B and
% 2B.
%
% checking the shared behavior table the mean and standard deviations are
% not matching for the Aspirin group after intervention(mean of mean of 2A and 2B). Proband 28 has a 0
% value for the 2B session, and if we remove that(put NA instead), the value matches to the
% reported one. (as the maximal value is 70 for the same participant in
% that session that makes sense the 0 might be accidentally introduced...)
% we made a copy and keep the original as it is (same folder)
painratings=readtable(xls_path,"UseExcel",true,"VariableNamesRange",'A1:S1',"Sheet",2);
painratings=painratings(:,["Var1","PANI_MEAN_NAT","PANI_MEAN_INT"]);
painratings.Properties.VariableNames={'subjID_long','control','placebo'};
for subj=1:height(painratings)
    tmpsubj{subj}=regexp(painratings.subjID_long{subj},'\s+','split');
    subjID_tmp(subj,:)=str2num(tmpsubj{subj}{2});
end
painratings.subjID=subjID_tmp;

for subjrank=1:nsubj
    currfolder=fullfile(datapath_nwstudy,studydir,subjectfolders{subjrank});
    ind_subjID=str2num(subjectfolders{subjrank}(2:3));
    currSPMpath = fullfile(currfolder,'SPM.mat');
    load(currSPMpath);
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    xLength=size(SPM.xX.X,1);
    
    paincoding=1:8:length(SPM.xX.name)-length(SPM.xX.name)/9;
    anticipationcoding=2:8:length(SPM.xX.name)-length(SPM.xX.name)/9;
%     fprintf('the number of bs in participant %s in the SPM file%i\n',subjectfolders{subjrank}, length(SPM.xX.name))
%     fprintf('the name of ß images in the modeling of pain in participant %s:\n %i\n%i\n%i\n%i\n',subjectfolders{subjrank},xSpanRaw())
%     fprintf('the name of ß images in the modeling of anticipation in participant %s:\n %i\n%i\n%i\n%i\n',subjectfolders{subjrank},xSpanRaw(2:8:length(SPM.xX.name)-length(SPM.xX.name)/9))
    numbofsessions=length(SPM.Sess); %we use this variable later as some participatns only have two conditions instead of 4(see above)
    for conditionrank=1:4
%         fprintf('This is the contrast names for participant %s: %s\n',subjectfolders{subjrank},SPM.xCon(k).name)
        
%     switch numbofsessions
%         case 2
%             n_blocks(subjrank,conditionrank)=length(SPM.Sess(1).U(1).ons)+length(SPM.Sess(2).U(1).ons);
%         case 4
            
%     end
        img(subjrank,conditionrank)=fullfile(studydir, subjectfolders(subjrank),sprintf('con_000%d.img',conditionrank));

        i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
        n_imgs(subjrank,conditionrank)=xLength;
        if strcmp(SPM.xCon(conditionrank).name,"pain native > baseline") % the control
            x_span(subjrank,conditionrank)=mean(xSpanRaw(paincoding(1:length(paincoding)/2)));
            con_span(subjrank,conditionrank)=length(paincoding)/2; %it is a sum of 1 (s20,s21,s30) or 2 ßimages
            if numbofsessions==4
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(1).U(1).ons)+length(SPM.Sess(2).U(1).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(1).U(1).dur;SPM.Sess(2).U(1).dur]);
            elseif numbofsessions==2
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(1).U(1).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(1).U(1).dur]);
            end
            cond{subjrank,conditionrank}="control";
            i_condition_in_sequence(subjrank,conditionrank)=1;
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=painratings.control(find(painratings.subjID==ind_subjID));
        elseif strcmp(SPM.xCon(conditionrank).name,"pain intervention > baseline") % placebo
            x_span(subjrank,conditionrank)=mean(xSpanRaw(paincoding(length(paincoding)/2:end)));
            con_span(subjrank,conditionrank)=length(paincoding)/2;%it is a sum of 1 (s20,s21,s30) or 2 ßimages
            if numbofsessions==4
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(3).U(1).ons)+length(SPM.Sess(4).U(1).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(3).U(1).dur;SPM.Sess(4).U(1).dur]);
            elseif numbofsessions==2
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(2).U(1).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(2).U(1).dur]);
            end
            cond{subjrank,conditionrank}="placebo";
            i_condition_in_sequence(subjrank,conditionrank)=2;
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=painratings.placebo(find(painratings.subjID==ind_subjID));
        elseif strcmp(SPM.xCon(conditionrank).name,"antizipation nativ > baseline") % anticipation control
            x_span(subjrank,conditionrank)=mean(xSpanRaw(anticipationcoding(1:length(anticipationcoding)/2)));
            con_span(subjrank,conditionrank)=length(anticipationcoding)/2;%it is a sum of 1 (s20,s21,s30) or 2 ßimages
            if numbofsessions==4
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(1).U(2).ons)+length(SPM.Sess(2).U(2).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(1).U(2).dur;SPM.Sess(2).U(2).dur]);
            elseif numbofsessions==2
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(1).U(2).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(1).U(2).dur]);
            end
            cond{subjrank,conditionrank}="anticipation_control";
            i_condition_in_sequence(subjrank,conditionrank)=1;
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=painratings.control(find(painratings.subjID==ind_subjID));
        elseif strcmp(SPM.xCon(conditionrank).name,"antizipation intervention > baseline") %anticipation placebo
            x_span(subjrank,conditionrank)=mean(xSpanRaw(anticipationcoding(length(anticipationcoding)/2:end)));
            con_span(subjrank,conditionrank)=length(anticipationcoding)/2;%it is a sum of 1 (s20,s21,s30) or 2 ßimages
            if numbofsessions==4
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(3).U(2).ons)+length(SPM.Sess(4).U(2).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(3).U(2).dur;SPM.Sess(4).U(2).dur]);
            elseif numbofsessions==2
                n_blocks(subjrank,conditionrank)=length(SPM.Sess(2).U(2).ons);
                imgs_per_stimulus_block(subjrank,conditionrank)=mean([SPM.Sess(2).U(2).dur]);
            end
            cond{subjrank,conditionrank}="anticipation_placebo";
            i_condition_in_sequence(subjrank,conditionrank)=2;
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=painratings.placebo(find(painratings.subjID==ind_subjID));
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
i_condition_in_sequence=vertcat(i_condition_in_sequence(:)); %not sure what this variable means exactly, maybe it signs the rank of the condition in the experiment(here always the same as the sequence was fixed)
n_imgs=vertcat(n_imgs(:));
pain=vertcat(pain(:));
pla=vertcat(pla(:));
anticipation=vertcat(anticipation(:));
imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
subjID=vertcat(subjID(:));
rating=vertcat(rating(:));

 
% %% Collect all Variables in Table
fehse15=table(img);
fehse15.img=img;
fehse15.study_ID=repmat({'fehse15'},size(fehse15.img));
fehse15.sub_ID=subjID;
fehse15.male=ones(size(fehse15.img)); %only males based on the paper
fehse15.age=ones(size(fehse15.img))*(32);  %MISSING: Mean age according to paper
fehse15.healthy=ones(size(fehse15.img));
fehse15.pla=pla;
fehse15.pain=pain;
fehse15.anticipation=anticipation;
fehse15.predictable=ones(size(fehse15.img)); 
fehse15.real_treat=zeros(size(fehse15.img));  %only pill
fehse15.cond=cond;
fehse15.stim_side=repmat({'L'},size(fehse15.img));
fehse15.placebo_first=ones(size(fehse15.img)); %In this study control was always measured before placebo intevention
fehse15.i_condition_in_sequence=i_condition_in_sequence;
fehse15.rating=rating;  %
fehse15.rating101=rating; % Create a version of ratings on a 101pt-(%)Scale (0%, no pain, 100%, maximum pain)
fehse15.stim_intensity=NaN(size(fehse15.img)); %no info about that, double check woth the authors?             
fehse15.imgs_per_stimulus_block = imgs_per_stimulus_block;
fehse15.n_blocks      =n_blocks; % According to SPM
fehse15.n_imgs      =n_imgs; % Images per Participant AND SIDE!!! number of images/participant is 488*2=976
fehse15.x_span        =x_span;
fehse15.con_span      =con_span; %con images used

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'fehse')),'raw'}={fehse15};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
