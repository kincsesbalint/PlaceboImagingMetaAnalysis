function r=fastcorrcoef_BK(A,B,varargin)
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
    if  any([isempty(A),isempty(B)])
       r=[] ; % If A or B is empty return empty instead of nan
    elseif any(strcmp(varargin,'exclude_nan')) % If nans should be excluded
        An=bsxfun(@minus,A,mean(A,1,'omitnan')); %%% zero-mean
        Bn=bsxfun(@minus,B,mean(B,1,'omitnan')); %%% zero-mean
        An=bsxfun(@times,An,1./realsqrt(sum(An.^2,1,'omitnan'))); %% L2-normalization
        Bn=bsxfun(@times,Bn,1./realsqrt(sum(Bn.^2,1,'omitnan')));
        r=sum(An.*Bn,1,'omitnan');
    else             % If nan should return nans (default)
        An=bsxfun(@minus,A,mean(A,1)); %%% zero-mean
        Bn=bsxfun(@minus,B,mean(B,1)); %%% zero-mean
        An=bsxfun(@times,An,1./realsqrt(sum(An.^2,1))); %% L2-normalization
        Bn=bsxfun(@times,Bn,1./realsqrt(sum(Bn.^2,1))); %% L2-normalization
        r=sum(An.*Bn,1);
    end
    
    r((sum(~isnan(A))<3)|(sum(~isnan(B))<3)) = NaN;% Even if nans are excluded... there cannot be a correlation without data.
    %todo check if the next line is really necessary bc it is not supported
    %by the GPU acceleation
    if any(r<-1) || any(r>1)
        fprintf("Rhis rounding thingy is needed here!!!!\n")
        r=round(r,12); % Fixes possible round-off problems, while preserving NaN: limit r to [-1,1].
    end

end