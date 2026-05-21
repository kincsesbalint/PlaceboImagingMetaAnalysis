function [curr_tbl,expression,derivedimg]=singlecondsumm_globals(dftmp,studyname,subj,condition)
% This function aims to contain the studywise information, which has to
% be predefined to calculate the individual condition summaries, for
% placebo, control and placebo-control. The placebo+control condition is
% simple, the summary of the placebo and control condition (if there is only
% control image than we use only that) for the pain stimulation. 
%
% It is based on MZ's individual summarize_[studyname] functions.
% We have to specify study by study if the calculation of the placebo or
% control images are necessary. However, in many studies simple refer to
% the column of placebo and control (which are dummy coded) to select
% the images. In some studies(see eg Kong06) the indexing of all the images
% hinder the possibility to use the dummy codes. 
% outputs:
%   curr_tbl - a table containg all the interesting images, it can be one
%       ß/con image OR multiply ß image. If it is more than 1 img, and
%       additional calculation is needed the derivedimg code that(see below)
%   expression - the arithmetic expression used to calculate a derived img.
%       usually is simple a mean of eg earl and late pain imgs.
%   derivedimg - dummy code of the necessity to calculate a derived
%       img(when more than one img is in the curr_tbl output see above)
%
% Balint Kincses 
% 2022
% balint.kincses@uk-essen.de

%% Placebo pain condition
if strcmp(condition,"pain_placebo")
    if strcmp(studyname,"atlas")
        %summary of three images
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                        (strcmp(dftmp.cond,'StimHiPain_Open_Stimulation')...
                        |strcmp(dftmp.cond,'StimHiPain_Open_RemiConz')...
                        |strcmp(dftmp.cond,'StimHiPain_Open_ExpectationPeriod')),:);
        expression='sum(X)';
%         condcode=struct('pla',1,'pain',1,'real_treat',1);
        derivedimg=1;
    elseif strcmp(studyname,"bingel06")
        %mean of two images, delivered on left and right side
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)'; %som participant has missing image for one condition(left-right)
        derivedimg=1;
    elseif any(strcmp(studyname,["bingel11", ...
                                 "ellingsen", ...
                                 "elsenbruch", ...
                                 "freeman", ... %BUT X.*-1 arithemtic for the high minus low pain
                                 "lui", ...
                                 "theysohn", ...
                                 "wager04b_michigan",...
                                 "fehse",...
                                 "schenk20"]))
        %this is one b image 
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression=''; %it has no meaning as we do not calculate any images. 
        derivedimg=0;
    elseif strcmp(studyname,"choi")
        %average of two images(but there are additional two images from exp2 which should not be included)
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                     (~cellfun(@isempty,regexp(dftmp.cond,'Exp1_1potent_pain_beta.*'))...
                     |~cellfun(@isempty,regexp(dftmp.cond,'Exp1_100potent_pain_beta.*'))),:);
        expression='nanmean(X)';
        derivedimg=1;
    elseif strcmp(studyname,"eippert")
        %early and late are averaged, two groups were used(but here we only interested in the within subject stuff)
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=1;

    elseif strcmp(studyname,"geuter")
        %mean of 4 imgs (early-late and waek and strong placebo)
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=1;        
    elseif strcmp(studyname,"kessner")
        % this is one b image
        %between subject design, no summary script as 1ß image always represent the different contrasts
        %the positive treatment group has the placebo condition and the
        %negativ treatment gorup has the control condition
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'.*pos'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=0;        
    elseif strcmp(studyname,"kong06") %no anticipation 
        % this is one b image
        % many images included in the df.raw, but only one is needed for the
        % placebo
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'.*high_pain'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif  strcmp(studyname,"kong09") %no anticipation
        % this is one b image
        % many images included in the df.raw, but only on is needed for the
        % placebo
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'pain_post*.'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=0;        

    elseif strcmp(studyname,"ruetgen") % anticipation and pain stimuli were modeled as one
        % this is one b image
        %between subject design, no summary script as 1ß image always represent the different contrasts
        %the positive treatment group has the placebo condition and the
        %negativ treatment gorup has the control condition
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...                        
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=0;  
    elseif strcmp(studyname,"schenk") 
        % the mean of two images, there are two conditions ,one with
        % lidocain and one without lidocaine treatment
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=1;

    elseif strcmp(studyname,"wager04a_princeton") 
    % NO placebo condition as only contrast images were shared
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;

    elseif strcmp(studyname,"wrobel") 
        % the mean of two images, early-late
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=1;
    elseif strcmp(studyname,"zeidan") 
        % NO placebo condition as only contrast images were shared
        curr_tbl=table();
        expression='nanmean(X)'; % it has no meaning
        derivedimg=0;
    elseif strcmp(studyname,"hartmann") 
        % here there was two different runs and ß images are calcualted
        % spearately for that. We should calculate the mean.
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"meulen") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"schenk17") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"koban")
        % they only shared the contrast imgs between control and placebo.
        % no individual control and pain maps are avialable.
        curr_tbl=table();
        expression='nanmean(X)'; 
        derivedimg=0;
            
    end
%% Control pain condition
elseif strcmp(condition , "pain_control")
    if strcmp(studyname,"atlas")
        %summary of three images
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                        (strcmp(dftmp.cond,'StimHiPain_Hidden_Stimulation')...
                        |strcmp(dftmp.cond,'StimHiPain_Hidden_RemiConz')...
                        |strcmp(dftmp.cond,'StimHiPain_Hidden_ExpectationPeriod')),:);
        expression='sum(X)';
%         condcode=struct('pla',1,'pain',1,'real_treat',1);
        derivedimg=1;
    elseif strcmp(studyname,"bingel06")
        %mean of two images, delivered on left and right side
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; %som participant has missing image for one condition(left-right)
        derivedimg=1;
    elseif strcmp(studyname,"bingel11")
        %this is one b image 
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0 & ...
                        dftmp.real_treat==1,:); %this is necessary as they used an infusion and measured a baslein which was indexed by MZ
        expression=''; %it has no meaning as we do not calculate any images. 
        derivedimg=0;
    elseif strcmp(studyname,"choi")
        
        % this is one image
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                     ~cellfun(@isempty,regexp(dftmp.cond,'Exp1_control_pain_beta.*')),:);
        expression=''; %no use
        derivedimg=0;
    elseif strcmp(studyname,"eippert")
        %early and late are averaged, two groups were used(but here we only interested in the within subject stuff)
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=1;
    elseif strcmp(studyname,"ellingsen")
        %this is one b images
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"elsenbruch")
        %this is one b images
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"freeman")
        %this is one b image
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        ~cellfun(@isempty,regexp(dftmp.cond,'pain_post_control.*')),:);
        expression='nanmean(X)';
        derivedimg=0;
%         expression='nanmean(X)'; %BUT X.*-1 for the high minus low pain
    elseif strcmp(studyname,"geuter")
        %mean of 4 imgs (early-late and waek and strong placebo)
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=1;        
    elseif strcmp(studyname,"kessner")
        % this is one b image
        %between subject design, no summary script as 1ß image always represent the different contrasts
        %the positive treatment group has the placebo condition and the
        %negativ treatment gorup has the control condition
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'.*neg'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==1,:);
        expression='nanmean(X)';
        derivedimg=0;        
    elseif strcmp(studyname,"kong06") %no anticipation 
        % this is one b image
        % many images included in the df.raw, but only one is needed for the
        % control
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'pain_post_control_high_pain'))),:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif  strcmp(studyname,"kong09") %no anticipation
        % this is one b image
        % many images included in the df.raw, but only on is needed for the
        % control
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'pain_post*.'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;        
    elseif strcmp(studyname,"lui") 
        % this is one b image
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"ruetgen") % anticipation and pain stimuli were modeled as one
        % this is one b image
        %between subject design, no summary script as 1ß image always represent the different contrasts
        %the positive treatment group has the placebo condition and the
        %negativ treatment gorup has the control condition
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;  
    elseif strcmp(studyname,"schenk") 
        % the mean of two images, there are two conditions ,one with
        % lidocain and one without lidocaine treatment
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=1;
    elseif strcmp(studyname,"theysohn")
        % this is one b image
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"wager04a_princeton") 
        % this is one b image
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'intense-none'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    elseif strcmp(studyname,"wager04b_michigan") 
        % this is one b images
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"wrobel") 
        % the mean of two images, early-late
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==2 | dftmp.pain==3) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=1;
    elseif strcmp(studyname,"zeidan") 
        % this is one b images, based on MZ's table
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; % it has no meaning
        derivedimg=0;
    elseif strcmp(studyname,"fehse")
        %this is one b images
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"hartmann") 
        % here there was two different runs and ß images are calcualted
        % spearately for that. We should calculate the mean.
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"meulen") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"schenk17") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (dftmp.pain==1) & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; 
        derivedimg=1;
    elseif strcmp(studyname,"schenk20")
        %this is one b images
        curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)';
        derivedimg=0;
    elseif strcmp(studyname,"koban")
        % they only shared the contrast imgs between control and placebo.
        % no individual control and pain maps are avialable.
        curr_tbl=table();
        expression='nanmean(X)'; 
        derivedimg=0;
    end
%% Placebo-minus control condition
% In some studies only contrast images were provided. 
elseif strcmp(condition , "pain_placebo_minus_control")
    if strcmp(studyname,"wager04a_princeton")
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                         (~cellfun(@isempty,regexp(dftmp.cond,'\(intense-none\)control-placebo'))),:);
        expression='X.*-1';
        derivedimg=1;
    elseif strcmp(studyname,"zeidan")
        %this is one
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'Pla>Control within painful series'))),:);
        expression='nanmean(X)'; % it has no meaning
        derivedimg=0;
    elseif strcmp(studyname,"koban")
        % they only shared the contrast imgs between control and placebo.
        % no individual control and pain maps are avialable.
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                         (~cellfun(@isempty,regexp(dftmp.cond,'control-placebo'))),:);
        expression='X.*-1'; 
        derivedimg=1;
            
    else
        %all the other studies
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
%% pain placebo and control condition
elseif condition == "pain_placebo_and_control"
    if strcmp(studyname,"atlas")
% For Atlas et al, the placebo-meta analysis is performed with remifentanil
% effects underlying pain_placebo and pain_control. However, given the
% strong remifentanil effect we definitely do not want to have remifentanil
% in the placebo_and_control (= pain) contrast. We use the
% Hi_pain condition (mean of open and hidden but without remifentanil and expectation period) instead.
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                        (strcmp(dftmp.cond,'StimHiPain_Open_Stimulation')...
                        |strcmp(dftmp.cond,'StimHiPain_Hidden_Stimulation')),:);
        expression='sum(X)';

        derivedimg=1;
    elseif strcmp(studyname,"wager04a_princeton")
% for contrast-only studies(Wager04a_princeton and Zeidan) the "pain vs baseline" contrasts were already loaded
% into control_baseline. In both cases, these contrasts represent pain
% controlled for placebo and control effects. So they are not fully
% comparable to the other mean(control_pain,placebo_pain)
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'intense-none'))) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    elseif strcmp(studyname,"zeidan")
        %this is one
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        dftmp.pain==1 & ...
                        dftmp.pla==0,:);
        expression='nanmean(X)'; % it has no meaning
        derivedimg=0;
    elseif strcmp(studyname,"koban")
        % they only shared the contrast imgs between control and placebo.
        % no individual control and pain maps are avialable.
        curr_tbl=table();
        expression='nanmean(X)'; 
        derivedimg=0;
            
    else
        %all the other studies
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
%% Anticipation placebo condition
elseif condition== "anticip_placebo"
    if any(dftmp.anticipation)
        if strcmp(studyname,"atlas")
            %summary of three images
            curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                            (strcmp(dftmp.cond,'AnticHiPain_Open')...
                            |strcmp(dftmp.cond,'AnticHiPain_Open_RemiConz')...
                            |strcmp(dftmp.cond,'AnticHiPain_Open_ExpectationPeriod')),:);
            expression='sum(X)';
    %         condcode=struct('pla',1,'pain',1,'real_treat',1);
            derivedimg=1;
        elseif strcmp(studyname,"bingel06")
            %mean of two images, delivered on left and right side
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)'; %som participant has missing image for one condition(left-right)
            derivedimg=1;
        elseif any(strcmp(studyname,["bingel11", ...
                                     "eippert", ... %this has early and late pain, but obviously only one anticipation period                                
                                     "lui", ...
                                     "theysohn", ...
                                     "wager04b_michigan",...
                                     "wrobel", ... %this has early and late pain, but obviously only one anticipation period
                                     "fehse",...
                                     "meulen" ... %this has early and late pain, but obviously only one anticipation period
                                     "schenk17", ... %this has early and late pain, but obviously only one anticipation period
                                     "schenk20",... %this has early and late pain, but obviously only one anticipation period
                                     % "elsenbruch" ... %this has no anticipation available right now, but based on the manuscript it seems they modeled. Check the extHD for more info
                                     ]))
            %this is one b image 
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression=''; %it has no meaning as we do not calculate any images. 
            derivedimg=0;
        elseif strcmp(studyname,"choi")
            %average of two images(but there are additional two images from exp2 which should not be included)
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                         (~cellfun(@isempty,regexp(dftmp.cond,'Exp1_1potent_pain_anticipation_beta.*'))...
                         |~cellfun(@isempty,regexp(dftmp.cond,'Exp1_100potent_pain_anticipation_beta.*'))),:);
            expression='nanmean(X)';
            derivedimg=1;

    
        elseif strcmp(studyname,"geuter")
            %mean of 2 imgs (weak and strong placebo anticipation)
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=1;        
        elseif strcmp(studyname,"kessner")
            % this is one b image
            %between subject design, no summary script as 1ß image always represent the different contrasts
            %the positive treatment group has the placebo condition and the
            %negativ treatment gorup has the control condition
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            (~cellfun(@isempty,regexp(dftmp.cond,'.*pos'))) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=0;        
     
        elseif strcmp(studyname,"schenk") 
            % the mean of two images, there are two conditions ,one with
            % lidocain and one without lidocaine treatment
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=1;
    
        elseif strcmp(studyname,"wager04a_princeton") 
        % NO placebo condition as only contrast images were shared
            curr_tbl=table();
            expression='nanmean(X)'; %it has no meaning, 
            derivedimg=0;
      
        elseif strcmp(studyname,"hartmann") 
            % here there was two different runs and ß images are calcualted
            % spearately for that. We should calculate the mean.
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            (dftmp.pain==0) & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)'; 
            derivedimg=1;
        end

    else %when there is no anticipation condition available
        %all the other studies including:
        % "ellingsen"
        % "elsenbruch" BUT they modeled(see above)
        % "freeman"
        % "konag06"
        % "kong09"
        % "ruetgen"
        % "zeidan"
        % "koban"
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
%% Anticipation control condition
elseif condition== "anticip_control"
    if any(dftmp.anticipation)
        if strcmp(studyname,"atlas")
            %summary of three images
            curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                            (strcmp(dftmp.cond,'AnticHiPain_Hidden')...
                            |strcmp(dftmp.cond,'AnticHiPain_Hidden_RemiConz')...
                            |strcmp(dftmp.cond,'AnticHiPain_Hidden_ExpectationPeriod')),:);
            expression='sum(X)';
    %         condcode=struct('pla',1,'pain',1,'real_treat',1);
            derivedimg=1;
        elseif strcmp(studyname,"bingel06")
            %mean of two images, delivered on left and right side
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==0 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)'; %som participant has missing image for one condition(left-right)
            derivedimg=1;
        elseif strcmp(studyname,"bingel11")
            %this is one b image 
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==0 & ...
                            dftmp.real_treat==1 & ... %this is necessary as they used an infusion and measured a baslein which was indexed by MZ
                            dftmp.anticipation==1,:); 
            expression=''; %it has no meaning as we do not calculate any images. 
            derivedimg=0;
        elseif any(strcmp(studyname,["eippert", ... %this has early and late pain, but obviously only one anticipation period                                    
                                     "lui", ...
                                     "theysohn", ...
                                     "wager04b_michigan",...
                                     "wrobel", ... %this has early and late pain, but obviously only one anticipation period
                                     "fehse",...
                                     "meulen" ... %this has early and late pain, but obviously only one anticipation period
                                     "schenk17", ... %this has early and late pain, but obviously only one anticipation period
                                     "schenk20",... %this has early and late pain, but obviously only one anticipation period
                                     % "elsenbruch" ... %this has no anticipation available right now, but based on the manuscript it seems they modeled. Check the extHD for more info
                                     ]))
            %this is one b image 
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==0 & ...
                            dftmp.anticipation==1,:);
            expression=''; %it has no meaning as we do not calculate any images. 
            derivedimg=0;
        elseif strcmp(studyname,"choi")
            %only one image(but there are additional images from exp2 which should not be included)
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                         ~cellfun(@isempty,regexp(dftmp.cond,'Exp1_control_pain_anticipation_beta.*')),:);
            expression=''; %no use
            derivedimg=0;

    
        elseif strcmp(studyname,"geuter")
            %mean of 2 imgs (weak and strong placebo anticipation)
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==0 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=1;        
        elseif strcmp(studyname,"kessner")
            % this is one b image
            %between subject design, no summary script as 1ß image always represent the different contrasts
            %the positive treatment group has the placebo condition and the
            %negativ treatment gorup has the control condition
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            (~cellfun(@isempty,regexp(dftmp.cond,'.*neg'))) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==1 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=0;        
     
        elseif strcmp(studyname,"schenk") 
            % the mean of two images, there are two conditions ,one with
            % lidocain and one without lidocaine treatment
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            dftmp.pain==0 & ...
                            dftmp.pla==0 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)';
            derivedimg=1;
    
        elseif strcmp(studyname,"wager04a_princeton") 
        % NO placebo condition as only contrast images were shared
            % this is one b image
            curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            (~cellfun(@isempty,regexp(dftmp.cond,'antint'))) & ...
                        dftmp.anticipation==2,:);
            expression='nanmean(X)'; %it has no meaning, 
            derivedimg=0;      
        elseif strcmp(studyname,"hartmann") 
            % here there was two different runs and ß images are calcualted
            % spearately for that. We should calculate the mean.
            curr_tbl = dftmp(strcmp(dftmp.sub_ID,subj) & ...
                            (dftmp.pain==0) & ...
                            dftmp.pla==0 & ...
                            dftmp.anticipation==1,:);
            expression='nanmean(X)'; 
            derivedimg=1;
        end

    else %when there is no anticipation condition available
        %all the other studies including:
        % "ellingsen"
        % "elsenbruch" BUT they modeles(see above)
        % "freeman"
        % "konag06"
        % "kong09"
        % "ruetgen"
        % "zeidan"
        % "koban"
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
%% Anticipation placebo minus control
elseif condition == "anticip_placebo_minus_control"
    if strcmp(studyname,"wager04a_princeton")
        %todo double check if this is the proper anticipation what we look
        %for
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                         (~cellfun(@isempty,regexp(dftmp.cond,'antint\(control-placebo\)'))),:);
        expression='X.*-1';
        derivedimg=1;
          
    else
        %all the other studies
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
elseif condition == "anticip_placebo_and_control"
    if strcmp(studyname,"atlas")
% For Atlas et al, the placebo-meta analysis is performed with remifentanil
% effects underlying pain_placebo and pain_control. However, given the
% strong remifentanil effect we definitely do not want to have remifentanil
% in the placebo_and_control (= pain) contrast. We use the
% Hi_pain condition (mean of open and hidden but without remifentanil and expectation period) instead.
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...% current subject
                        (strcmp(dftmp.cond,'AnticHiPain_Open')...
                        |strcmp(dftmp.cond,'AnticHiPain_Hidden')),:);
        expression='sum(X)';

        derivedimg=1;
    elseif strcmp(studyname,"wager04a_princeton")
% for contrast-only studies(Wager04a_princeton) the "pain vs baseline" contrasts were already loaded
% into control_baseline. In both cases, these contrasts represent pain
% controlled for placebo and control effects. So they are not fully
% comparable to the other mean(control_pain,placebo_pain)
        curr_tbl=dftmp(strcmp(dftmp.sub_ID,subj) & ...
                        (~cellfun(@isempty,regexp(dftmp.cond,'antint'))) & ...
                        dftmp.anticipation==2,:);
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;

            
    else%when there is no anticipation condition available
        %all the other studies including:
        % "ellingsen"
        % "elsenbruch" BUT they modeles(see above)
        % "freeman"
        % "konag06"
        % "kong09"
        % "ruetgen"
        % "zeidan"
        % "koban"
        curr_tbl=table();
        expression='nanmean(X)'; %it has no meaning, 
        derivedimg=0;
    end
end
curr_tbl.derivedimg=repmat(derivedimg,height(curr_tbl),1);


end
