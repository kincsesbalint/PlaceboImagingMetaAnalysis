function [cond_tbl] = singlestudratings_globals(cond_tbl,curr_tbl,studyname,subj,condition)
%SINGLESTUDRATINGS_GLOBALS Summary of this function goes here
%   Detailed explanation goes here
if any(strcmp(condition,["pain_placebo","pain_control","anticip_placebo","anticip_control"]))
    if strcmp(studyname,"atlas") 
        %summary of three images
        
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=sum(curr_tbl.rating);
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=sum(curr_tbl.rating101);
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span);
    elseif strcmp(studyname,"bingel06") % maybe later include here all the studies where we mean the rating from different images: any(strcmp(studyname,["bingel06","atlas"]))
        %mean of two images
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"bingel11")
        %this is one b image, we simple copy the ratings and the x_span
    elseif strcmp(studyname,"choi")
        %average of two images(but there are additional two images from exp2 which should not be included)
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"eippert")
        %early and late are averaged, two groups were used(but here we only interested in the within subject stuff)
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"ellingsen")
        %this is one b image
    elseif strcmp(studyname,"elsenbruch")
        %this is one b image
    elseif strcmp(studyname,"freeman")
        %this is one b image
    elseif strcmp(studyname,"geuter")
        %mean of 4 imgs (early-late and waek and strong placebo)
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"kessner")
        %between subject design, no summary script as 1ß image always represent the different contrasts
        %this is one b image
    elseif strcmp(studyname,"kong06") %no anticipation
        %this is one b image
    elseif  strcmp(studyname,"kong09") %no anticipation
        %this is one b image
    elseif strcmp(studyname,"lui") 
        %this is one b image
    elseif strcmp(studyname,"ruetgen") % anticipation and pain stimuli were modeled as one
        % this is one b image
    elseif strcmp(studyname,"schenk")
        % the mean of two images, there are two conditions ,one with
        % lidocain and one without lidocaine treatment
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"theysohn")
        % this is one b images
    elseif strcmp(studyname,"wager04a_princeton") 
        % NO placebo condition as only contrast images were shared
    elseif strcmp(studyname,"wager04b_michigan") 
        % this is one b images
    elseif strcmp(studyname,"wrobel") 
        % the mean of two images, early-late
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"zeidan") 
        % NO placebo condition as only contrast images were shared
    elseif strcmp(studyname,"fehse")
        %this is one b images        
    elseif strcmp(studyname,"hartmann") 
        % here there was two different runs and ß images are calcualted
        % spearately for that. We should calculate the mean.
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"meulen") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"schenk17") 
        % early and late pain were modelled separately, however, I did not
        % use different dummy coding as we anyway sum up them
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"schenk20")
        %this is one b images
    elseif strcmp(studyname,"koban")
        % no intensity rating is available, only affect ratings 
    end
    
elseif any(strcmp(condition,["pain_placebo_minus_control","anticip_placebo_minus_control"]))
    if strcmp(studyname,"wager04a_princeton")
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=curr_tbl.rating.*-1;
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=curr_tbl.rating101.*-1;
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"koban")
        % no intensity rating is available, only affect ratings
    end
elseif any(strcmp(condition,["pain_placebo_and_control","anticip_placebo_and_control"]))
    if strcmp(studyname,"atlas") 
        %summary of three images
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating=mean(curr_tbl.rating,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).rating101=mean(curr_tbl.rating101,'omitnan');
        cond_tbl(strcmp(cond_tbl.sub_ID,subj),:).x_span=mean(curr_tbl.x_span,'omitnan');
    elseif strcmp(studyname,"wager04a_princeton") 
        %it is NaN as data not available
    elseif strcmp(studyname,"zeidan")
        %it is the value of the control condition
    elseif strcmp(studyname,"koban")
        % no intensity rating is available, only affect ratings
    end



end
end

