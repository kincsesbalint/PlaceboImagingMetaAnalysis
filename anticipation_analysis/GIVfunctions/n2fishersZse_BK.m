function SE_Z=n2fishersZse_BK(n)
% Converts the n of pairs in a correlation to the corresponding SE
% of Fisher's z.
% Returns NaN instead of Inf for small sample sizes.
% The Standard Error (SE) of Fisher's z only depends on n (e.g. see: E.g.
% https://en.wikipedia.org/wiki/Fisher_transformation)
SE_Z=sqrt(complex(1./(n-3))); %SQRT: needs to return a complex result, but this is not supported for real input X on the GPU. Use SQRT(COMPLEX(X)) instead.
SE_Z(n<=3)=NaN; %if we wotk with doubles this line basically converts back the copmlex number to a adouble array
SE_Z=real(SE_Z); %this is necessary as previous step does not automatically convert back the array to double from compley
end