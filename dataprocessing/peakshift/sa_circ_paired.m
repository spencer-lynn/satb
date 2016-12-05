function results=sa_circ_paired(angles)
%  SAtb fn sa_circ_paired for paired (w/in-group, repeated measures) test
% ...for angles(:,1:2) in radians (=degrees*pi/180)
% See Zar 1984 p461
% 
% Parametric version = Hotelling's test
% Non-parametric version = Moore's test (not finished coding)
%
% Ho = there is no difference between angles1 and angles2
% Ha = angles1 and angles2 differ
%
% Uses:
% - Try's to use ML's Statistics Toolbox for Fcrit, P computation.
% 
% To do:
% - code up non-parametric version
% - generalizable to >2 repeated measures?
% - What's the full GLM generalization?
% - code up ties in Moore's non-parametric test.
%%%%%%%%%%%%%%%%%%%%


if nargin==0
    disp('Demo data from Zar 1984, p461')
    angles(:,1)=[105;120;135;95;155;170;160;155;120;115];
    angles(:,2)=[205;210;235;245;260;255;240;245;210;200];
    angles
    angles=angles.*pi/180;
end

X=cos(angles(:,2))-cos(angles(:,1));
Y=sin(angles(:,2))-sin(angles(:,1));
k=length(angles(:,1));


%% Parametric test
meanX=mean(X);
meanY=mean(Y);
sumX2=sum(X.^2)-(sum(X)^2)/k;
sumY2=sum(Y.^2)-(sum(Y)^2)/k;
sumXY=sum(X.*Y)-(sum(X)*sum(Y))/k;

results.F_stat = (k*(k-2)/2) * ( (meanX^2*sumY2 - 2*meanX*meanY*sumXY + meanY^2*sumX2 )  / ((sumX2 * sumY2) - sumXY^2) );


%% Non parametric test
% - not completed. Not sure how to deal w/ties.
% rj=sqrt(X.^2+Y.^2);
% cos_aj=X./rj;
% sin_aj=Y./rj;
% 
% ranked_rj=sort(rj);
% n=length(unique(ranked_rj));
% numties=length(ranked_rj)-n


%% Report results
try
    results.F_crit=finv(.95,2,k-2);
    results.P = 1-fcdf(results.F_stat,2,k-2);
    
    if results.F_stat>results.F_crit
        disp('Reject Ho!')
    else
        disp('Cannot reject Ho.')
    end
catch statsError
    statsError
    disp('Cannot determine F-critical value or P. Is Statistics Toolbox installed?')
end
end