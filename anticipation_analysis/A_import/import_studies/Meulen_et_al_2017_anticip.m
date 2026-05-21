function Meulen_et_al_2017_anticip(datapath_nwstudy,intermedpath)
% % --------------------------------------------------------------------
% The function creates a mapping between the study of Meulen et al.,2017 and
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
% Information shared by author:
% con_0002.img : pain stimulation during the control condition
% con_0003.img : pain stimulation during the placebo condition
% con_0006.img : early pain in control condition (first 10 seconds of the 20s pain stimulus)
% con_0007.img : early pain stimulation during the placebo condition
% con_0008.img : late pain in control condition (last 10s)
% con_0009.img : late pain stimulation during the placebo condition 
% con_0023.img : anticipation period in control condition
% con_0024.img : anticipation period in placebo condition
% con_0027.img : pain rating phase 
% I would stick with the individual early and late placebo/control contrast
% images(which basically only one ß img) bc based on the SPM.mat, they add
% up the early and late and not calculate the mean of them (contrast:1 1,
% instead of 0.5 0.5)

% datapath_nwstudy='C:\Users\lenov\Documents\PICO_DATA\';
studydir= 'study-Meulen2017\contrast images';
studyfolder=dir(fullfile(datapath_nwstudy,studydir));
studyfolder={studyfolder.name};
subjectfolders=studyfolder(~cellfun(@isempty,regexp(studyfolder,'suj\d*','match')));
nsubj=length(subjectfolders);
img={};
%% Ratings
xls_path=fullfile(datapath_nwstudy,  'study-Meulen2017\behavioural data.xls');
 

% " 100-point VAS rating scales were presented ... first for pain intensity
% (ranging from "no pain" to "unbearable pain”)"
%
% 
painratings=readtable(xls_path,"UseExcel",true,"Sheet","overview","DataRange",'A3:G32',"VariableNamesRange",'A2:G2');
% painratings = painratings(strcmp(painratings.target, 'self') & strcmp(painratings.intensity, 'pain'), :);
% for subj=1:height(painratings)
%     tmpsubj{subj}=painratings.id{subj}(end-1:end);
%     subjID_tmp(subj,:)=str2num(tmpsubj{subj});
% end
% painratings.subjID=subjID_tmp;

interestingimages=[
'con_0006' % early pain in control condition (first 10 seconds of the 20s pain stimulus)
'con_0007' % early pain stimulation during the placebo condition
'con_0008' % late pain in control condition (last 10s)
'con_0009' % late pain stimulation during the placebo condition 
'con_0023' % anticipation period in control condition
'con_0024' % anticipation period in placebo condition
    ];


for subjrank=1:nsubj
    currfolder=fullfile(datapath_nwstudy,studydir,subjectfolders{subjrank});
    ind_subjID=str2num(subjectfolders{subjrank}(4:end));
    currSPMpath = fullfile(currfolder,'SPM.mat');
    load(currSPMpath);
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    xLength=size(SPM.xX.X,1);
 
    
    numbofsessions=length(SPM.Sess);
    regrinonesess=(length(SPM.xX.name)-numbofsessions)/2;
    for conditionrank=1:height(interestingimages)
        condimgnum=str2num(interestingimages(conditionrank,end-1:end));
        if any([6 8 23] == condimgnum) %there are two session here, one is the control and one is the placebo. 
            sessionnum=1;
        elseif any([7 9 24] == condimgnum)
            sessionnum=2;
        end
        % condnnum will help us to find and read the appropriate condition
        % in the SPM file
        %there are four conditions modelled per run(placebo/control). and we are interested in three(anticipation,early,late pain)
        if any([23 24] == condimgnum) %anticipation
            condnnum=1;
        elseif any([6 7] == condimgnum) %early pain
            condnnum=2;
        elseif any([8 9] == condimgnum) %late pain
            condnnum=3;
        end
        % the modelling of them is alway like the first session is the
        % control, and the second one is the placebo.however,the data was
        % acquired counterbalanced across subjects
        img{subjrank,conditionrank}=fullfile(studydir,subjectfolders{subjrank}, strcat(interestingimages(conditionrank,:),'.img'));

        i_sub(subjrank,conditionrank)=subjectfolders(subjrank);
        n_imgs(subjrank,conditionrank)=xLength;
        x_span(subjrank,conditionrank)=xSpanRaw(condnnum+regrinonesess*(sessionnum-1));
        con_span(subjrank,conditionrank)=length(x_span); %it is always 1 as one ß images as used to calculate this contrast
        n_blocks(subjrank,conditionrank)=length(SPM.Sess(sessionnum).U(condnnum).ons); %2or3or4 depending on the anticipation, early or late pain condition
        imgs_per_stimulus_block(subjrank,conditionrank)=mean(SPM.Sess(sessionnum).U(condnnum).dur);
        i_condition_in_sequence(subjrank,conditionrank)=sessionnum;
        if condimgnum==6 || condimgnum==8 % the control (early and late)
            cond{subjrank,conditionrank}="control";
            pain(subjrank,conditionrank)=1; %Matthias coded this as 2 and 3 for early and late pain,however, as we do not analyse separately them,and always calculate the mean of the two. I simple code them her as 1
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=0;
            
            rating(subjrank,conditionrank)=painratings{painratings.ID==ind_subjID, "control"};
        
        elseif condimgnum==7 || condimgnum==9 % the placebo
            cond{subjrank,conditionrank}="placebo";
            pain(subjrank,conditionrank)=1;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=0;
            rating(subjrank,conditionrank)=painratings{painratings.ID==ind_subjID, "placebo"};
        elseif condimgnum==23 % anticipation control 
            cond{subjrank,conditionrank}="anticipation_control";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=0;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=painratings{painratings.ID==ind_subjID, "control"};
        elseif condimgnum==24 % anticipation placebo
            cond{subjrank,conditionrank}="anticipation_placebo";
            pain(subjrank,conditionrank)=0;
            pla(subjrank,conditionrank)=1;
            anticipation(subjrank,conditionrank)=1;
            rating(subjrank,conditionrank)=painratings{painratings.ID==ind_subjID, "placebo"};
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
% maybe it signs the rank of the condition in the experiment(here we two
% conditions a placebo and control which order was counterbalanced across
% subjects)
n_imgs=vertcat(n_imgs(:));
pain=vertcat(pain(:));
pla=vertcat(pla(:));
anticipation=vertcat(anticipation(:));
imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
subjID=vertcat(subjID(:));
rating=vertcat(rating(:));

 
 
% %% Collect all Variables in Table
meulen17=table(img);
meulen17.img=img;
meulen17.study_ID=repmat({'meulen17'},size(meulen17.img));
meulen17.sub_ID=subjID;
meulen17.male=ones(size(meulen17.img)); %todo read the painratings file here
meulen17.age=ones(size(meulen17.img))*(32);  %todo read the painratings file here
meulen17.healthy=ones(size(meulen17.img));
meulen17.pla=pla;
meulen17.pain=pain;
meulen17.anticipation=anticipation;
meulen17.predictable=ones(size(meulen17.img)); 
meulen17.real_treat=zeros(size(meulen17.img));  %no additional drug was used
meulen17.cond=cond;
meulen17.stim_side=repmat({'L'},size(meulen17.img));
meulen17.placebo_first=ones(size(meulen17.img)); %todo ask for Marian to share this info as the order was counterbalanced across partiicpants
meulen17.i_condition_in_sequence=i_condition_in_sequence;
meulen17.rating=rating;  %
meulen17.rating101=rating; % they used VAS100, see anchorw above
meulen17.stim_intensity=NaN(size(meulen17.img)); %todo contact with Marian?
meulen17.imgs_per_stimulus_block = imgs_per_stimulus_block;
meulen17.n_blocks      =n_blocks; % According to SPM
meulen17.n_imgs      =n_imgs; % Images per Participant and run/session(2x)
meulen17.x_span        =x_span;
meulen17.con_span      =con_span; %con images used

%% Save in data_frame
load(fullfile(intermedpath,'data_frame.mat'));
df{find(strcmp(df.study_ID,'meulen')),'raw'}={meulen17};
save(fullfile(intermedpath,'data_frame.mat'),'df');
end
