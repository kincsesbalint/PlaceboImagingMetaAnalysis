function r_partial=fastcorrcoef_quadratic_BK(A,B,varargin)
% This function aims to fit a quadratic model


% quadratic term 
A2 = A.^2;
% remove projection on A (residualize) 
% columnwise norms ignoring NaNs 
AA = sum(A.^2,1,'omitnan');
% projection of A2 onto A 
projcoef_A2 = sum(A.*A2,1,'omitnan') ./ AA;
proj_A2_on_A = A .* projcoef_A2;
rA2 = A2 - proj_A2_on_A;
% projection of B onto A 
projcoef_B = sum(A.*B,1,'omitnan') ./ AA;
proj_B_on_A = A .* projcoef_B;
rB = B - proj_B_on_A;
% zero mean 
rA2 = rA2 - mean(rA2,1,'omitnan');
rB = rB - mean(rB,1,'omitnan');
% normalization 
rA2 = rA2 ./ sqrt(sum(rA2.^2,1,'omitnan'));
rB = rB ./ sqrt(sum(rB.^2,1,'omitnan'));
% correlation 
r_partial = sum(rA2 .* rB,1,'omitnan');
r_partial((sum(~isnan(A))<3)|(sum(~isnan(B))<3)) = NaN;% Even if nans are excluded... there cannot be a correlation without data.
if any(r_partial<-1) || any(r_partial>1)
    warning("Rhis rounding thingy is needed here!!!!\n")
    r_partial=round(r_partial,12); % Fixes possible round-off problems, while preserving NaN: limit r to [-1,1].
end
% Fisher z for meta-analysis effects = atanh(r_partial);
% standard error SEs = 1 ./ sqrt(n - 4);

% Calculates pearson's correlation coefficient between two matrices A and B
    % COLUMN-WISE
    % bsxfun speeds up the procedure vastly compared to corrcoef
    % Columns containing NaN return NaN by default
    % Setting the field excluded_nan to true excludes NaNs.

    % I rewrite everything and now we run on the GPU
%     if any(strcmp(varargin,'gpu'))
%         A=gpuArray(A);
%         B=gpuArray(B);
%     end
%     if  any([isempty(A),isempty(B)])
%        r=[] ; % If A or B is empty return empty instead of nan
%     elseif any(strcmp(varargin,'exclude_nan')) % If nans should be excluded
%         An=bsxfun(@minus,A,mean(A,1,'omitnan')); %%% zero-mean
%         Bn=bsxfun(@minus,B,mean(B,1,'omitnan')); %%% zero-mean
%         An=bsxfun(@times,An,1./realsqrt(sum(An.^2,1,'omitnan'))); %% L2-normalization
%         Bn=bsxfun(@times,Bn,1./realsqrt(sum(Bn.^2,1,'omitnan')));
%         r=sum(An.*Bn,1,'omitnan');
%     else             % If nan should return nans (default)
%         An=bsxfun(@minus,A,mean(A,1)); %%% zero-mean
%         Bn=bsxfun(@minus,B,mean(B,1)); %%% zero-mean
%         An=bsxfun(@times,An,1./realsqrt(sum(An.^2,1))); %% L2-normalization
%         Bn=bsxfun(@times,Bn,1./realsqrt(sum(Bn.^2,1))); %% L2-normalization
%         r=sum(An.*Bn,1);
%     end
%     
%     r((sum(~isnan(A))<3)|(sum(~isnan(B))<3)) = NaN;% Even if nans are excluded... there cannot be a correlation without data.
%     %todo check if the next line is really necessary bc it is not supported
%     %by the GPU acceleation
%     if any(r<-1) || any(r>1)
%         fprintf("Rhis rounding thingy is needed here!!!!\n")
%         r=round(r,12); % Fixes possible round-off problems, while preserving NaN: limit r to [-1,1].
%     end

end