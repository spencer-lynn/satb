function roc=roc_from_gradients(distnTarget,distnFoil,x_range,plotflag)
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
% 3/10/13 - v2 Investigated adding proportional weighting to incoming keypress distn. 
%              - Doesn't work to address lack of evidence of discrimination in tails of key press gradients.
%         - v3 Investigate summation/subtraction of delivery gradients.
%              - doesn't account for ppt mistakes
% 
%% To do
% Random key pressing would produce the summation of the two gaussian SIM distributions.
%  (Use model_pmetric::rocs to get data for this.)
%  - This means that tails at extemes of x-range don't indicate discrimination.
% 1. v2 NOPE: would like to weight the incomming pdf by #presentations for each stim (calc that in pmetric) 
%     - this draws a kind of pmetric fn, high at one tail, low at the other
%     - but this just makes the resulting S+ and S- pmetric/CDFs identical, mirror images
% 2. Can I cut those keypress tails off from ROC analysis? Just make ROC from portion of gradient btw means?
% 3. v3 NOPE: use the SIM gradient summation as a filter to mask out data that could be random: examine what passes through?
%      - something about this may help estimate random key pressing, but need to work with data about mistakes to really get at discrimination
% 4. Make gradients of SOURCEs, via outcomes: CD+MD, CR+FA. Ppt w/ lots of mistakes out in tails has worse sensitivity.
%     - express as proportion of #presentations (ie, pmet fn). 
%         - because these are independent trials, won't have mirror-image problem, above.
%     - might then normalize pmets->CDF, or take differential to make PDFs and make CDFs from those.
%         - uh, wait-doesn't use of pmet in this way assume pmet.slope=similarity? Maybe not for these processed data which are already grouped by category
%     - what about bias, making DFs from biased responses? What's the effect? Can model that. 
%     - could be that both distributions will be shifted, such that xover point of PDFs (and PMET-CDFs) is at t-loc on x-axis. That's how I'd expect threshold location to manifest.
%         - But normalizing won't shift distns... just make xover-pt more neutral-going. REMOVEs bias. 
%         - But might not expect means of the source-outcome distns to be at objective means; that's the point. 
%         - In which case normalizingor d/ttl->PDF might diminish bias evident in raw distns.
%      
% 
% keypress distn are behavior, so they combine the three SDT params. What can I infer from key press distn?
% - think about outcome-spp distributions or combos of them
% - what would -1/+1 summing them do? -> peak shift analysis
% - bias is revealed by relative area of the gradients. Can't tell whether the bias is due to base rate or payoff (or low d'?)
% 
%% %%%%%%%%%%%%%%%

%% Example gradient data
if nargin==0
    x_range=(1:.1:11);
    meanTarget=7;
    sdTarget=1;
    distnTarget=normpdf(x_range,meanTarget,sdTarget);
    meanFoil=5;
    sdFoil=1;
    distnFoil=normpdf(x_range,meanFoil,sdFoil);
    plotflag=1;
end %if no inputs

if plotflag~=false
figure;hold on; zoom
plot(x_range,distnTarget,'b')
plot(x_range,distnFoil,'r')
end

%% 1. Convert distributions to PDFs (ie, area sums to 1)
distnTarget=distnTarget/(sum(distnTarget)); %transform so that sums to 1. 
distnFoil=distnFoil/(sum(distnFoil)); %transform so that sums to 1.

%% 2. Convert PDF to CDF
roc.cd_cdf=1-cumsum(distnTarget);
roc.fa_cdf=1-cumsum(distnFoil);

if plotflag~=false
figure;hold on; zoom
plot(x_range,roc.cd_cdf,'b')
plot(x_range,roc.fa_cdf,'r')
end

%% Plot ROC
if plotflag~=false
figure;%hold on; zoom
plot(roc.fa_cdf,roc.cd_cdf,'-o')
end
end %fn




