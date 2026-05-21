function D_thresholdsforFDR(intermedpath,varargin)
    individualfile=uigetfile(intermedpath);
    [~,filename,~]=fileparts(individualfile);
    fprintf("We loaded the following file:%s\n",filename)
    fileinfos=strsplit(filename,'_');
    load(fullfile(intermedpath,individualfile));
    
    


    if strcmp(fileinfos{4},"diff")
        fprintf("The threshold for correlation is:%f\n", ...
            round(prctile(max([summaryy.permres.r.rnd.zmaxvals; -summaryy.permres.r.rnd.zminvals]),95),2))
        fprintf("The threshold for effect size is:%f\n", ...
            round(prctile(max([summaryy.permres.g.rnd.zmaxvals; -summaryy.permres.g.rnd.zminvals]),95),2))        
    elseif strcmp(fileinfos{4},"sum")
        fprintf("The threshold for effect size is:%f\n", ...
            round(prctile(max([summaryy.permres.g.rnd.zmaxvals; -summaryy.permres.g.rnd.zminvals]),95),2))
    end