function [summary]=GIV_summary_BK_gpu(stats, outputs)
% Generic inverse-variance (GIV) method to summarize continuous statistics across studies 
% This function differs from the GIV_summary_BK as uses gpuArrays to
% calculate the summary statistics. So the stats structure contains
% gpuArrays(each row is one study)
% Input:
%
% stats: objects from withinMetastats or betweenMetastats with N studies.
% outputs: OPTIONAL! will default to: outputs={'mu','d','g','r'}
%          if fewer arguments are desired (e.g. to speed up computation and
%          limit size of results for whole-brain imaging analysis), those
%          can be specified explicitly (e.g. as {'g'})

% Output:
% Per default the "summary" output object will contain fixed and random summaries for
% 'mu': unstandardized (raw) means
% 'd': Cohen's d
% 'g': Hedges' g
% 'r': Correlation between repeated measures (only within-metastats)
% 'r': Correlation between repeated measures (only within-metastats)
% 'r_external': Correlation of original data with external data (used to
% correlate voxel activation changes with behavioral changes)

% Further adds "weight_d","weight_g" and "weight_r" fields to stats object
% for reviewing the weights used by the GIV method.

% Random/Fixed Summary statistics include:

% summary ? Weighted effects summary of effects
% SEsummary ? Standard error of weighted effects summary
% z - z-score of summary effect
% p - probability ('statistical significance') of summary effect
% CI_lo - 95% confidence intervals lower bound
% CI_hi - 95% confidence intervals upper bound
% chisq - fixed effects measure of heterogeneity in sample
% tausq - random effects measure of heterogeneity in sample
% df - degrees of freedom (just number of input studies-1)
% p_het - probability ('statistical significance') of observed heterogeneity based on chisq (same for fixed/random)
% Isq - I-squared... "This measures the extent of inconsistency among the
% studies, and is interpreted as approximately the proportion of
% total variation in study estimates that is due to heterogeneity rather
% than sampling error." (see: Deeks & Higgins, p. 6)

% All calculations are performed for all columns in stats object.

% See:
% Statistical algorithms in Review Manager 5
% Jonathan J Deeks and Julian PT Higgins
% on behalf of the Statistical Methods Group
% of The Cochrane Collaboration
% August 2010

% commented by BK and added the lines below
% if ~exist('outputs')
%     outputs={'mu','d','g','r'};
% end

 if exist('outputs','var')==0
    outputs={'mu','d','g','r'};
end 
%Global variables (true for all statistics computed)

%means
if any(strcmp(outputs,'mu'))
[summary.mu.fixed,...
 summary.mu.random,...
 summary.mu.heterogeneity]=GIV_weight_BK(vertcat(stats.mu),vertcat(stats.se_mu));
 summary.mu.n=sum(vertcat(stats(:).n),'omitnan');
end
%d
if any(strcmp(outputs,'d'))
[summary.d.fixed,...
 summary.d.random,...
 summary.d.heterogeneity]=GIV_weight_BK(vertcat(stats.d),vertcat(stats.se_d));
 summary.d.n=sum(vertcat(stats(:).n),'omitnan');
end
%g
if any(strcmp(outputs,'g'))
[summary.g.fixed,...
 summary.g.random,...
 summary.g.heterogeneity]=GIV_weight_BK(vertcat(stats.g),vertcat(stats.se_g));
 summary.g.n=sum(vertcat(stats(:).n),'omitnan');
end
%r
% For correlations all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'r'))
[summary.r.fixed,...
 summary.r.random,...
 summary.r.heterogeneity]=GIV_weight_BK(r2fishersZ(vertcat(stats.r)),n2fishersZse(vertcat(stats.n))); %For Fisher's Z the SE of correlations only depends on n sqrt(1./(n-3))
 summary.r.n=sum(vertcat(stats(:).n),'omitnan');

% Back-transform from fishersZ to r
[summary.r.fixed,...
 summary.r.random,...
 summary.r.heterogeneity]=GIV_weight_fishersZ2r(summary.r.fixed,...
                                                summary.r.random,...
                                                summary.r.heterogeneity);
end

%r external
% Same as above: all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'r_external'))
% Empty fields have to be filled with nans

[summary.r_external.fixed,...
 summary.r_external.random,...
 summary.r_external.heterogeneity]=GIV_weight_BK(r2fishersZ(vertcat(stats.r_external)),n2fishersZse_BK(vertcat(stats.n_r_external))); %For Fisher's Z the SE of correlations only depends on n. sqrt(1./(n-3))
 summary.r_external.n=sum(vertcat(stats(:).n_r_external),'omitnan'); % N where both observations are available!

% Back-transform from fishersZ to r
[summary.r_external.fixed,...
 summary.r_external.random,...
 summary.r_external.heterogeneity]=GIV_weight_fishersZ2r(summary.r_external.fixed,...
                                                summary.r_external.random,...
                                                summary.r_external.heterogeneity);
end

 % For ICC all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'ICC'))
    if ~isempty([stats.ICC])
        [summary.ICC.fixed,...
         summary.ICC.random,...
         summary.ICC.heterogeneity]=GIV_weight_BK(r2fishersZ(vertcat(stats.ICC)),n2fishersZse(vertcat(stats.n))); %For Fisher's Z the SE of correlations only depends on n sqrt(1./(n-3))

        % Back-transform from fishersZ to r
[summary.ICC.fixed,...
 summary.ICC.random,...
 summary.ICC.heterogeneity]=GIV_weight_fishersZ2r(summary.ICC.fixed,...
                                                summary.ICC.random,...
                                                summary.ICC.heterogeneity);
    end 
end
end