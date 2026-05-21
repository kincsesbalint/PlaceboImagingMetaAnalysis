%this is just a helper function bc htat was missing from Canlab funcitons
%and created quickly by chatgpt, however, need to be double checked if the
%implementation is correct or not. This is only called when robust
%esimtaiont is called(that is not possible with multilevel mediation).
function [r,p] = weighted_corrcoef(x,y,w)
    % weightedCorr Weighted Pearson correlation (and approx p-value).
    % x,y,w: vectors of same length. w must be nonnegative.
    % p-value uses an approximate effective sample size.
    
    x = x(:); y = y(:); w = w(:);
    m = isfinite(x) & isfinite(y) & isfinite(w) & (w > 0);
    x = x(m); y = y(m); w = w(m);
    
    w = w / sum(w);                    % normalize weights to sum to 1
    mx = sum(w.*x);  my = sum(w.*y);
    xc = x - mx;     yc = y - my;
    
    covw = sum(w .* xc .* yc);
    vx   = sum(w .* xc.^2);
    vy   = sum(w .* yc.^2);
    r    = covw / sqrt(vx*vy);
    
    % approximate p-value via effective sample size
    neff = 1 / sum(w.^2);              % Kish effective sample size
    t = r * sqrt((neff-2) / max(1e-12, (1-r^2)));
    p = 2 * tcdf(-abs(t), neff-2);
end