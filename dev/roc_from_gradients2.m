function roc=roc_from_gradients2(distnTarget,distnFoil,x_range,plotflag)
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
% 7/21/12? - started
% 3/8/13 - parts split out: reimann_sum
% 3/9/13 - add proportional weighting to incoming keypress distn
%
%% Here:
% weight the incomming pdf by #presentations for each stim (calc that in pmetric)
% - this is because it's drawn from a normal distn, so key presses will be normally shaped,
%   even in absence of discrimination.
% = but this just makes the resulting S+ and S- pmetric/CDFs identical, mirror images
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
end %if

% if plotflag~=false
%     figure;hold on; zoom
%     plot(x_range,distnTarget,'b')
%     plot(x_range,distnFoil,'r')
% end

ttl_presses=distnTarget+distnFoil;

%% 1. Convert distributions to PDFs
distnTarget=distnTarget/(sum(distnTarget)); %transform so that sums to 1. 
distnFoil=distnFoil/(sum(distnFoil)); %transform so that sums to 1.
% if plotflag~=false
%     figure;hold on; zoom
%     plot(x_range,distnTarget,'b')
%     plot(x_range,distnFoil,'r')
% end

%% 2. Convert PDFs to releative frequency psycometric fns
% - doing this on raw keypress gradients just makes mirror-image pmet gradients
%     - if not target then must have been foil!
%     - total overlap so no discrimination.
% - if sigmoid shape, indicates Gaussian underlying SIM representation?
distnTarget=distnTarget./ttl_presses;
distnFoil=distnFoil./ttl_presses;
if plotflag~=false
    figure;hold on; zoom
    plot(x_range,distnTarget,'b')
    plot(x_range,distnFoil,'r')
end


%% Convert PMETs to CDFs
% - ack, this reveals that CDFs are identical.
distnTarget=normalizer(distnTarget); %normalize range 0-1. 
distnFoil=normalizer(distnFoil); %normalize range 0-1
if plotflag~=false
    figure;hold on; zoom
    plot(x_range,distnTarget,'b')
    plot(x_range,distnFoil,'r')
end


%% 3. Flip Foil PMET
% distnFoil=fliplr(distnFoil); %Careful, not the same as 1-gradient
distnFoil=1-distnFoil; 
if plotflag~=false
    figure;hold on; zoom
    plot(x_range,distnTarget,'b')
    plot(x_range,distnFoil,'r')
end

%% 4. Get differentials, which creates PDFs
distnTarget=diff(distnTarget);
distnFoil=diff(distnFoil);
if plotflag~=false
    figure;hold on; zoom
    plot(distnTarget,'b')
    plot(distnFoil,'r')
end

%% 2. Convert PDF to CDF
distnTarget(isnan(distnTarget))=0;
distnFoil(isnan(distnFoil))=0;
roc.cd_cdf=1-cumsum(distnTarget);
roc.fa_cdf=1-cumsum(distnFoil);
if plotflag~=false
    figure;hold on; zoom
    plot(roc.cd_cdf,'b')
    plot(roc.fa_cdf,'r')
end


% %% Plot ROC
if plotflag~=false
    figure;%hold on; zoom
    plot(roc.fa_cdf,roc.cd_cdf,'-o')
end
end %fn




