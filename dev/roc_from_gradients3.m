function roc=roc_from_gradients3(distnTarget,distnFoil,x_range,plotflag)
%% SAtb fn: reimann=roc_from_gradients(distnTarget,distnFoil,x_range,plotflag)
% 
% Generate ROC from perceiver's target and foil button-press gradients.
% - Must have perceiver's categorizations of stimuli on continuum as target and/or foil. 
% - Use that to estimate signal distributions re targets, foils.
% 
%% Notes
% An ROC is the plot, at each pt on perceptual domain (x-axis) of 
% the foil cummulative distribution function vs
% the target CDF. 
% So,
%   - pass in keypress gradients (distnTarget,distnFoil)
%   - turn them into PDFs
%   - tune PDFs in to CDFs
%   - foil CDF= Xs of ROC
%   - target CDF = Ys of ROC
% The ROC pts can then be passed on to reimann_sum.m to get area under the ROC.
% 
%% Change Log
% 7/21/12?- Started
% 3/8/13  - Parts split out: reimann_sum now stand-alone m-file. 
% 3/10/13 - Investigated adding proportional weighting to incoming keypress distn. 
%           Doesn't work to address lack of evidence of discrimination in tails of key press gradients.
% 
%% To do
% Random key pressing would produce the summation of the two gaussian SIM distributions.
%  (Use model_pmetric::rocs to get data for this.)
%  - This means that tails at extemes of x-range don't indicate discrimination.
% 
% v3 trying this: 3. Or use the SIM gradient summation as a filter to mask out data that could be random: examine what passes through?
% =concl: I need to leverage what I know about ppt's mistakes at each stim
% to improve this.
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

% if plotflag~=false
% figure;hold on; zoom
% plot(x_range,distnTarget,'b')
% plot(x_range,distnFoil,'r')
% end

%% Get sum of target, foil delivery PDFs
targets_ara=normpdf(1:11,7,1); %Array of signals
foils_ara=normpdf(1:11,5,1); %Array of signals
delivery_gradient=targets_ara+foils_ara;

%% xfrom to area=1. This represents expected random key press distribution for either key, separately.
%- this isn't "random" pressing, it's just not discriminable from random.
%- non-random, discriminatatory pressing will fill a lot of this area, too.
delivery_gradient=delivery_gradient/(sum(delivery_gradient)); %transform so that sums to 1. 

% figure; hold on
% plot(1:11,targets_ara,'b')
% plot(1:11,foils_ara,'r')
% plot(delivery_gradient,'k')


%% 1. Convert keypress distributions to PDFs (ie, area sums to 1)
distnTarget=distnTarget/(sum(distnTarget)); %transform so that sums to 1. 
distnFoil=distnFoil/(sum(distnFoil)); %transform so that sums to 1.

%% 2. Determine gradient differences
ttl_keypress_gradient=distnTarget+distnFoil; %Sum of target and foil keypresses at each stim
discrimination_gradient=delivery_gradient-ttl_keypress_gradient; %proportion of presses not examplained by random pressing
nonrandom_target_gradient=distnTarget-delivery_gradient; %proportion of "target" judgements not attributable to random response
nonrandom_foil_gradient=distnFoil-delivery_gradient; %proportion of "foil" judgements not attributable to random response
% **if it's not random, it's presumed to also not be mistaken?
% - that doesn't seem to capture discrimination well.
% - I need to deal with mistakes somehow.

if plotflag~=false
figure;hold on
plot(x_range,distnTarget,'b')
plot(x_range,distnFoil,'r')
plot(delivery_gradient,'k')

figure;hold on
plot(nonrandom_target_gradient,'b')
plot(nonrandom_foil_gradient,'r')
plot(discrimination_gradient,'k')

%% Area under this curve should corresepond to discriminability.
% - Correlate with ROC in modeled data?
figure;hold on
plot(abs(nonrandom_foil_gradient-nonrandom_target_gradient))


% figure;hold on
% plot3(abs(nonrandom_foil_gradient),abs(nonrandom_target_gradient),1:11)
end



% %% 2. Convert PDF to CDF
% roc.cd_cdf=1-cumsum(distnTarget);
% roc.fa_cdf=1-cumsum(distnFoil);
% 
% if plotflag~=false
% figure;hold on; zoom
% plot(x_range,roc.cd_cdf,'b')
% plot(x_range,roc.fa_cdf,'r')
% end
% 
% %% Plot ROC
% if plotflag~=false
% figure;%hold on; zoom
% plot(roc.fa_cdf,roc.cd_cdf,'-o')
% end
end %fn




