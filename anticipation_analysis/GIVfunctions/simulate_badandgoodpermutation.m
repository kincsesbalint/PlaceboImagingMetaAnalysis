
plac = (80-30).*rand(100,1) + 30;
contr=(10).*rand(100,1)-5;
contr=plac+5+contr;

for i=1:5000
    relabel=logical(random('Discrete Uniform',2,100,1)-1);
    placp=vertcat(plac(relabel),contr(~relabel));
    contrp_gd=vertcat(contr(relabel),plac(~relabel));
    contrp_bd=vertcat(plac(~relabel),contr(relabel));
    teststat_gd(i)=summarize_within_BK(contrp_gd,placp);
    teststat_bd(i)=summarize_within_BK(contrp_bd,placp);
end

histogram(teststat_gd,'FaceColor',[0 1 0]);hold on ;histogram(teststat_bd,'FaceColor',[1 0 0])