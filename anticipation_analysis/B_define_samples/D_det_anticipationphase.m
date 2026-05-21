function D_det_anticipationphase(intermedpath,varargin)
df_path=fullfile(intermedpath,'data_frame.mat');
load(df_path,'df');
nstudy=height(df);
isTableCol = @(t, thisCol) ismember(thisCol, t.Properties.VariableNames);
if ~isTableCol(df,'modeled_anticipationphase')
    for studyrank=1:nstudy
        if exist(fullfile(intermedpath,df.anticip_placebo_minus_control{studyrank}.norm_img{1}),'file')==2 %todo, that does not handle the Kessner study right now...
            df.modeled_anticipationphase(studyrank)=1;
        else
            df.modeled_anticipationphase(studyrank)=0;
        end
    end
end

save(fullfile(intermedpath,'data_frame.mat'),'df');