function Apply_NPS_BK(datapath,marker)
%TODO define the path for the canlabcore and the masks which we want to use
%in the function arguments

%addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
%addpath(genpath('~/Documents/MATLAB/CanlabPatternMasks/MasksPrivate/'));
addpath(genpath('~/Documents/PICO_DATA/originaldatastructure/pattern_masks'))
%% Set IO paths
%todo add the path which contains the canlab masks used by the
%apply_all_signatures function
% p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
% [p,~,~]=fileparts(p);
% splitp=strsplit(p,'/');
% maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
% addpath(maskdir);
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

% contrasts={'pain_placebo',...
%            'pain_control',...
%            'pain_placebo_minus_control',...
%            'pain_placebo_and_control'};
contrasts={'anticip_placebo',...
           'anticip_control',...
           'anticip_placebo_minus_control',...
           'anticip_placebo_and_control'};

% contrasts={'pain_placebo'};

n=size(df,1);
h = waitbar(0,'Calculating NPS, studies completed:');          
for i=1:n
    for j=1:length(contrasts)
        studytbl=df.(contrasts{j}){i};
        normimgexist=~cellfun(@isempty,studytbl.norm_img);
        allsubj=nan(size(studytbl,1),1);
        if any(normimgexist)
            
            nsubj=sum(normimgexist);%size(studytbl,1);
            in_img=cell(nsubj,1);
            for k=1:nsubj%size(df.subjects{i},1)
                if ~isempty(studytbl(k,:)) %~isempty(df.subjects{i}.(contrasts{j}){k})
    %             in_img(k)= df.subjects{i}.(contrasts{j}){k}.norm_img;
    %             in_img{k,:}= studytbl(normimgexist,:).norm_img{:};
                in_img=studytbl(normimgexist,:).norm_img;
        
        %         fprintf(in_img{1});
                else
                    fprintf('ez a kephianyzik:%i',k)
                    
                end
            end
            %added by BK
            %todo specify maki and save it for later checking if it is
            %necessary...
            studyimgs=fmri_data(fullfile(datapath, in_img));
            %todo: it seems that the nps is not available in the 
            [maki,NPS_value]=apply_all_signatures(studyimgs,'image_set',marker);
            % Apply NPS, get NPS values and sub-region estimates
    %         [NPS_value, image_name, data_object, NPSpos_exp_by_region, NPSneg_exp_by_region, clpos, clneg] = ...
    %             apply_nps(fullfile(datapath, in_img),'notables','noverbose' );
            if strcmp(marker,'nps')
                    allsubj(normimgexist)=NPS_value{:}.NPS_dotproduct_none;
%                     df.(contrasts{j}){i}.NPS=allsubj;
            elseif strcmp(marker,'siips')
                    allsubj(normimgexist)=NPS_value{:}.SIIPS_dotproduct_none;
                    
            end
            df.(contrasts{j}){i}.(marker)=allsubj;
        else
            df.(contrasts{j}){i}.NPS=allsubj;
        end
%         studytbl(normimgexist,:)=NPS_value{:}.NPS_dotproduct_none;
%         for k=1:size(df.subjects{i},1)
%             df.subjects{i}.(contrasts{j}){k}.NPS = maki.NPS{k,1};
%         end
        % Not feasible for single-study processing. Get separately, for all images
        % together
        % df.NPS_subr_info(i).pos.(contrasts{j})={clpos};
        % df.NPS_subr_info(i).neg.(contrasts{j})={clneg};
        % Get sub-region estimates, construct valid names 
%         NPS_pos=vertcat(NPSpos_exp_by_region{:});
%         NPS_pos_names=strcat('NPS_pos_',...
%                                strtrim({clpos.title}'),'_',...
%                                strtrim({clpos.shorttitle}'));
%         NPS_pos_names=matlab.lang.makeValidName(NPS_pos_names);
%         NPS_pos=array2table(NPS_pos,'VariableNames',NPS_pos_names);
% 
%         NPS_neg=vertcat(NPSneg_exp_by_region{:});
%         NPS_neg_names=strcat('NPS_neg_',...
%                                strtrim({clneg.title}'),'_',...
%                                strtrim({clneg.shorttitle}'));
%         NPS_neg_names=matlab.lang.makeValidName(NPS_neg_names);
%         NPS_neg=array2table(NPS_neg,'VariableNames',NPS_neg_names);

        % NaN for subregions with no global NPS-estimates
%         emptyimgs=cellfun(@isempty,NPS_value);
%         NPS_value(emptyimgs)={NaN};
%         NPS_pos{emptyimgs,:}=NaN;
%         NPS_neg{emptyimgs,:}=NaN;

%         if any(ismember(NPS_neg_names,...
%                         df.subjects{i}.(contrasts{j}){k}.Properties.VariableNames))
%             df.subjects{i}.(contrasts{j}){k}(:,NPS_pos_names)=NPS_pos{:};
%             df.subjects{i}.(contrasts{j}){k}(:,NPS_neg_names)=NPS_neg{:};
%         end
%         end
%      end
    
    end
    waitbar(i /n,h);
end
save(df_path,'df');
    
close(h)
end