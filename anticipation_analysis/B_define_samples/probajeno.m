wager_PR_studyid=find(strcmp(df.study_ID,'wager04a_princeton'));
%Select contrast images from df raw
wager_princeton=df.raw{wager_PR_studyid};
i_pla=~cellfun(@isempty,regexp(wager_princeton.cond,'\\(intense-none\)placebo-control'));
%Select contrasts variables
contrast_level_vars=df.placebo{wager_PR_studyid}.Properties.VariableNames;
wager_princeton=wager_princeton(i_pla,contrast_level_vars(1:end-1));
wager_princeton.derivedimg=1;
%Add to table
for j=1:height(unique(df.raw{wager_PR_studyid}(:,"sub_ID")))
    df.placebo_minus_control{wager_PR_studyid}(j,:)=wager_princeton(j,:);
end


readtable(xls_path,"UseExcel",true,"Sheet",'BetaSummary',"DataRange",'D2:D25')

for i=1:20
    fprintf('%s',df.study_ID{i})
    fprintf("The rating from my df:%f, and the rating from MZ's table:%f\n",df.GIV_stats_rating(i,1).mu,maki.df.GIV_stats_rating(i,1).mu)
    if df.GIV_stats_rating(i,1).mu==maki.df.GIV_stats_rating(i,1).mu
        fprintf('they are the same\n')
    end
end