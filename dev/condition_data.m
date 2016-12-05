function [X Y]=condition_data(X,Y)
% SAtb function: condition_data
% 
% If curve fitting produces "ill-defined" Jacobian, try conditioning the data
% (based on hints in Curve Fitting Toolbox)
% 
% 
% To do:
% - finish writing as stand alone procedure. Was developed to allow use of nlinfit in sigmoid_fit.m
% prior to development of sigmoid_fit_cftb (the Curve Fitting TB version).
% - make Centering work for matrix of Xs (ie, after adding noise to X).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inits
[yrows ycols]=size(Y);
sd=.1;

%% Add Y noise
r = randn(size(Y)).*sd; %normal 0,1 dist'n noise
r2=rand(size(Y)); %uni distn'
lg=r2>.5; %flag
r(lg)=r(lg)*-1;%make flags negative
Y=Y+r; %add noise to data

%% Add X noise
X=repmat(X,yrows,1); %Create an x-array for EACH ppt (rather than the single x-axis that the experiment actually used)
r = randn(size(X)).*sd; %normal 0,1 dist'n noise
r2=rand(size(X)); %uni distn'
lg=r2>.5; %flag
r(lg)=r(lg)*-1;%make flags negative, so variance goes pos and neg about mean.
X=X+r; %add noise to data

%% Center Xs
% Mean centering: 
% - not written to work on matrix of (noisey) Xs, just one (original) x-domain.
% - could use a for loop for multiple rows, or maybe specifiy demention of mean/sd?
X=(X - mean(X))./std(X); %Normalize (center) x-values for additional data conditioning.

end %conditioning
