function roc=roc_from_gradients5(distnYes,distnNo,x_range,plotflag)
%% SAtb fn: reimann=roc_from_gradients(distnTarget,distnFoil,x_range,plotflag)
%
% Generate ROC from perceiver's target and foil button-press gradients.
% - Must have perceiver's categorizations of stimuli on continuum as target and/or foil.
% - Use that to estimate signal distributions re targets, foils.
%
%% Notes
% An ROC is the plot, at each pt on perceptual domain (x-axis)
% of the foil cummulative distribution function vs the target CDF.
% So,
%   - pass in keypress gradients (distnTarget,distnFoil)
%   - turn them into PDFs
%   - turn PDFs in to CDFs
%   - foil CDF= Xs of ROC
%   - target CDF = Ys of ROC
% The ROC pts can then be passed on to reimann_sum.m to get area under the ROC.
%
%% Change Log
% 7/21/12?- Started
% 3/8/13  - Parts split out: reimann_sum now stand-alone m-file.
% 3/10/13 - v2 Investigated adding proportional weighting by ttl_presses per key to incoming keypress distn.
%              - Doesn't work to address lack of evidence of discrimination in tails of key press gradients.
%         - v3 Investigate summation/subtraction of delivery gradients.
%              - doesn't account for ppt mistakes
%20150617 - v4 Skipped - see ideas in v1
%         - v5 Comparisons of keypress gradient relative to SIM, not presentations or total presses (since those have base rate in them).
%             - should be useful for examining a kind of bias across the x-range.
%
%% To do
% Random key pressing would produce the summation of the two gaussian SIM distributions.
%  (Use model_pmetric::rocs to get data for this.)
%  - This means that tails at extemes of x-range don't indicate discrimination.
% except via difference from PDFs underlying what was actually shown
%
%% %%%%%%%%%%%%%%%

%% Example gradient data
if nargin==0
    %Objective, enrivonmetal SIMILARITY params
    x_range=(1:.1:11);
    meanTarget=7;
    sdTarget=1;
    pdfTarget=normpdf(x_range,meanTarget,sdTarget);
    cdfTarget=1-normcdf(x_range,meanTarget,sdTarget);
    meanFoil=5;
    sdFoil=sdTarget;
    pdfFoil=normpdf(x_range,meanFoil,sdFoil);
    cdfFoil=1-normcdf(x_range,meanFoil,sdFoil);
    
    %Yes/No response gradient params
    meanYes=meanTarget;
    sdYes=1.5;
    distnYes=normpdf(x_range,meanYes,sdYes);
    meanNo=meanFoil;
    sdNo=sdYes;
    distnNo=normpdf(x_range,meanNo,sdNo);
    
    plotflag=1;
end %if no inputs

if plotflag~=false
    figure;hold on; zoom
    plot(x_range,pdfTarget,'b-')
    plot(x_range,pdfFoil,'r-')
    plot(x_range,distnYes,'b')
    plot(x_range,distnNo,'r')
end


%% wt keypress gradients by signal distns
yesdiff=distnYes-pdfTarget;
nodiff=distnNo-pdfFoil;

yesdiff=distnYes./pdfTarget;
nodiff=distnNo./pdfFoil;

if plotflag~=false
    figure;hold on; zoom
    plot(x_range,yesdiff,'b')
    plot(x_range,nodiff,'r')
end

%% 1. Convert distributions to PDFs (ie, area sums to 1)
distnYes=distnYes/(sum(distnYes)); %transform so that sums to 1.
distnNo=distnNo/(sum(distnNo)); %transform so that sums to 1.


%% 2. Convert PDF to CDF
roc.cd_cdf=1-cumsum(distnYes);
roc.fa_cdf=1-cumsum(distnNo);

if plotflag~=false
    figure;hold on; zoom
    plot(x_range,cdfTarget,'b-')
    plot(x_range,cdfFoil,'r-')
    plot(x_range,roc.cd_cdf,'b')
    plot(x_range,roc.fa_cdf,'r')
    
end

%% Plot ROC
if plotflag~=false
    figure;hold on; zoom
    plot(cdfFoil,cdfTarget,'-o')
    plot(roc.fa_cdf,roc.cd_cdf,'-o')
    
end




end %fn




