function out=sigmoid_fit_cftb(x,y,direction,tmethod,constrain,plotflag,filename)
%SAtb function: out=sigmoid_fit_cftb(x,y,direction,tmethod,constrain,plotflag,filename)
%
%Where: low_asy = y(0), ie y when x=zero, or maybe low assymptote?: can constrain to 0
%       high_asy = y max-min, or maybe high assymptote? (~=y(xmax)-y(0) at any rate): can constrain to 1
%       inflectionpt = mu: x-axis value of inflection pt of the sigmoid: the threshold location
%       theta = theta: influences slope of curve through inflection pt (larger value = flatter curve)
%       direction = specifies whether left or right side of response gradient should be high (=1, 100% response strength)
%                 = {'lefthigh' | 'righthigh'}
%
% sigmoid_fit_output = (example)
% 
%               mfile: 'sigmoid_fit_cftb'
%            warnings: ''
%           direction: 'righthigh'
%           constrain: 1
%             tmethod: 'inflection'
%                note: ''
%              fitobj: [1x1 cfit]
%            goodness: [1x1 struct]
%             outputs: [1x1 struct]
%        inflectionpt: 5.6358
%     inflectionpt_ci: [5.5671 5.7044]
%               theta: 0.5894
%            theta_ci: [0.5295 0.6492]
%                ylow: NaN
%             ylow_ci: [NaN NaN]
%               yhigh: NaN
%            yhigh_ci: [NaN NaN]
%                yfit: [1x11 double]
%           threshold: 5.6358
%               y_thr: 0.5000
%               slope: 0.4242
%                 rsq: 0.9989
%         guessed_yes: 3.8368e-04
%          guessed_no: 1.1151e-04
% 
%                
%Notes:
% - Running "constrained" produces a perfect sigmoid, so there's no difference difference in threshold location, slope, theta among t-methods.
% - 95%CIs are always through inflection pt, regardless of t-method.
% - Warnings may be present in the output:
%       YNAN = Y inputs contained a NaN, which was ignored for fitting.
%       CST = Fit method may not be appropriate for unconstrained modeling. 
%       JAC = Ill conditioned Jacobian
%       ASY = Asymptote may be high
%       THR - threshold out of bounds bounds
%       RSQ - r^2 is ± infinite
%
%Uses Curve Fitting Toolbox rather than Statistics Toolbox's nlinfit.m.
% - Can produce worse results for "unconstrained" fits, but better results for some constrained fits.
% - When nlinfit Jacobian verges on "ill-conditioned", this can be a better method.
% - Default reporting is less thorough, so have expanded.
% - Still calcs Jacobian. Have borrowed code from nlinfit to evaluate it.
% 
% Change log:
% 4/25/12 - added struct records for high-resolution x and yfn for plotting
% 
%To do:
% 
% - Is this plotting x-range correctly? On pmetric_model simulations, x(1)=first x with data (eg, stim2), not stim1.
% 
% Pretty much fails for unconstrained: est. param values don't seem to match curve well, and curve doesn't fit endpts well.
% Will this script work for high guess-rates? (given that seems to only work when contrained?).
% Slope is always through inflection pt, regardless of t-method.
% 95%CIs are always through inflection pt, regardless of t-method.
%%%%%%%%%%%

%% Demo if no data passed in.
if nargin==0
    %     y=[1.00 1.00 .75 .25 0 0]
    %     y=[1 1 1 0 0 0]
    y=[0 0 0.0385    0.0823    0.2340    0.6587    0.9145    0.9711  0.9762  1 1]; %psychometric fn: probability of "go" response for each stimulus
    %y=[0 0 0.0385    0.0823    0.2340    0.6587    0.9145    0.9711  0.9762  1 NaN]; %psychometric fn: probability of "go" response for each stimulus
    x=(1:length(y)); %eg, 1-11 = number of stimuli in continuum.
    %     x=[0.9863    1.9648    3.0295    4.0827    4.9240    6.1120]'
    %     y=fliplr(y); %what is y is high-left rather than high-right?
    
    
    %     out.direction='lefthigh'
    %     out.direction='righthigh'
    if y(1)>y(end)
        direction='lefthigh';
    else
        direction='righthigh';
    end
    
    constrain=1;
    tmethod='inflection'; %options={inflection yfitmid y5}
    plotflag=1;
end



%% Inits
x=x'; %transpose, since most calls to this will pass as row, but needs col.
y=y'; %transpose, ...
out.mfile=mfilename;
out.warnings='';
out.direction=direction;
out.constrain=constrain;
out.tmethod=tmethod;
out.note='';

%% Check for and remove NaNs
ynan=isnan(y);
if sum(ynan)>0;
    notnanlocs=find(~isnan(y)); %index to non-NaN locations.
    y=y(~isnan(y));
    x=x(~isnan(y));
    out.warnings=strcat([out.warnings,'YNAN',';']); 
end

%% Select eq
switch constrain
    case 0
        disp(strcat(['WARNING: ',mfilename, ' returns odd results for fits using constrain=1.']))
        out.warning=strcat([out.warnings,'CST',';']);
        seeds=[0 1 max(x)/2 5];%initial values for param est.
        switch direction
            case 'righthigh'
                fy=fittype('low_asy + high_asy ./ (1 + exp(-(x-inflectionpt))/theta)');%slope is positive: "-(x-inflectionpt)"
            case 'lefthigh'
                fy=fittype('low_asy + high_asy ./ (1 + exp((x-inflectionpt))/theta)'); %slope is positive
            otherwise
                disp(strcat(['Direction not recognized in ',mfilename,'. Processing stopped.']))
                return
        end
        [out.fitobj out.goodness out.outputs]=fit(x,y,fy,'StartPoint',seeds);
        %out.fitobj %show, to verify that label assignments are correct.
        phats=coeffvalues(out.fitobj); %Estimated values for the parameters
        phats_ci = confint(out.fitobj,0.95); %confidence intervals for parameter estimates.
        out.inflectionpt=phats(2);
        out.inflectionpt_ci=phats_ci(:,2)';
        out.theta=phats(4);
        out.theta_ci=phats_ci(:,4)';
        out.ylow=phats(3);
        out.ylow_ci=phats_ci(:,3)';
        out.yhigh=phats(1);
        out.yhigh_ci=phats_ci(:,1)';
        
    case 1
        seeds=[max(x)/2 5]; %initial values for param est.
        switch direction
            case 'lefthigh'
                fy=fittype('1 ./ (1 + exp((x-inflectionpt)/theta))'); %slope is positive
            case 'righthigh'
                fy=fittype('1 ./ (1 + exp(-(x-inflectionpt)/theta))');%slope is positive: "-(x-thres)"
            otherwise
                disp(strcat(['Direction not recognized in ',mfilename,'. Processing stopped.']))
                return
        end
        [out.fitobj out.goodness out.outputs]=fit(x,y,fy,'StartPoint',seeds);
        %out.fitobj %show, to verify that label assignments are correct.
        phats=coeffvalues(out.fitobj); %Estimated values for the parameters
        phats_ci = confint(out.fitobj,0.95); %confidence intervals for parameter estimates.
        out.inflectionpt=phats(1);
        out.inflectionpt_ci=phats_ci(:,1)';
        out.theta=phats(2);
        out.theta_ci=phats_ci(:,2)';
        out.ylow=NaN;
        out.ylow_ci=[NaN NaN];
        out.yhigh=NaN;
        out.yhigh_ci=[NaN NaN];
        
    otherwise
        disp(strcat(['Contraint value not recognized in ',mfilename,'. Processing stopped.']))
        return
        
end %switch

%% Quality control on fitting process
%(1) Jacobian check copied from nlinfit (Stats toolbox).
% - if ill-conditioned, could try conditioning the data (add random noise to y (or x) values.
[Q,R] = qr(out.outputs.Jacobian,0);
if condest(R) > 1/(eps(class(seeds)))^(1/2) %Ill-conditioned Jacobian warning generated by nlinfit:224
    out.warnings=strcat([out.warnings,'JAC',';']);
end

%(2) If y_high-asymptote is much beyond P["Go"]=0..1, it suggests
% - un-sigmoid shape (be careful of t-method selection).
% - bad fit (consider reruning as contrained).
if constrain == 0 && out.yhigh >1.2
    out.warnings=strcat([out.warnings,'ASY',';']);
end


%% Prep add'l outputs
out.yfit=feval(out.fitobj,x)';

switch tmethod
    case 'inflection'
        %Threshold = the inflection point of yfit.
        % The best method when curve is nicely sigmoid, otw take infl/constrained or midpoint/unconst
        % With this method, Thr may be beyond stimulus range.
        out.threshold=out.inflectionpt; %from the model-fitting parameters, above
        out.y_thr=feval(out.fitobj,out.threshold);

    case 'yfitmid'
        %Threshold = the value of p at mid-point of it's y-axis range.
        % Good method if shape or computing resouces make inflection method ill-suited.
        ymax=max(out.yfit); %limit min & max to [0 1]
        if ymax >1
            ymax=1;
        end
        ymin=min(out.yfit);
        if ymin <0
            ymin=0;
        end
        
        %Given Ps, solve for y=midpt  --> note the -midpt added to the end of our fn below:
        midpt=ymin+(ymax-ymin)/2;
        inflectionpt=out.inflectionpt;
        theta=out.theta;
        low_asy=out.ylow;
        high_asy=out.yhigh;
        t=solve(strcat('(',strrep(formula(out.fitobj),'.',''),')','-midpt')); %SOLVE is part of Symbolic Toolbox, I think
        out.threshold=eval(t); %EVAL is part of Symbolic Toolbox, I think
        out.y_thr=midpt; %response strength (value of y) at threshold.
        
    case 'y5'
        %Threshold = the point at which y=0.5.
        % Problematic for odd psychometric functions -> t=imaginary.
        % Given Ps, solve for y=.5  --> note the -.5 added to the end of our fn below:
        inflectionpt=out.inflectionpt;
        theta=out.theta;
        low_asy=out.ylow;
        high_asy=out.yhigh;
        t=solve(strcat('(',strrep(formula(out.fitobj),'.',''),')','-.5')); %SOLVE is part of Symbolic Toolbox, I think
        out.threshold=eval(t); %EVAL is part of Symbolic Toolbox, I think
        %x=> p(3)-1.*log(-1.*(2.*p(1)+2.*p(2)-1.)/(2.*p(1)-1.))*p(4) %no need for other people to have SOLVE, EVAL
        if ~isreal(out.threshold) %when y=.5 is NOT on fit curve, t=imaginary
            out.threshold=NaN;
            out.warnings=strcat([out.warnings,'THR',';']);
            disp('y=.5 is NOT on fit curve, t=imaginary, recorded as NaN')
        end
        out.y_thr=0.5; %response strength (value of y) at threshold.

    otherwise
        disp('Requested threshold calculation method not recognized by sigmoid_fit_cftb.m')
end %switch
xs=[out.threshold-.01 out.threshold+.01];
ys=feval(out.fitobj,xs);
out.slope=(ys(2)-ys(1))/(xs(2)-xs(1));

if (out.threshold>max(x) || out.threshold<min(x))
    out.warnings=strcat([out.warnings,'THR',';']);
end

%r^2 goodness of fit to model
obs=~isnan(y)'; %Exclude NaNs' in observed data prior to R-squared.
out.rsq=rsq(y(obs)',out.yfit(obs)); %Transpose, since rsq wants obs in cols, ppts in rows.
if isinf(out.rsq)
    out.warnings=strcat([out.warnings,'RSQ',';']);
    out.rsq=NaN;
end



%Guessed Yes/No rates
%- These values are the guess rates for each key; to use as ppt filter in SPSS, try: gy>0.45, gn>0.45, not <0.55!
%- For poor, unconstrained fits these can be equal to zero, since value is off-axis.
ymax=max(out.yfit); %limit min & max to [0 1]
if ymax >1
    ymax=1; %In pefect case, max p[target] = 1, thus any deviation from this is guess (guessed "no") by pressing the FOIL button
end
ymin=min(out.yfit);
if ymin <0
    ymin=0; %In pefect case, min p[target] = 0, thus any deviation from this is guess (guessed "yes") by pressing the TARGET button
end
out.guessed_yes=ymin; %est. proportion of trials on which subject pressed TARGET as a guess
out.guessed_no=1-ymax; %est. proportion of trials on which subject guessed NO


%% Restore any NaNs to yfit
if sum(ynan)>0
    yfit=ones(numel(ynan),1)*NaN;
    yfit(notnanlocs)=out.yfit;
    out.yfit=yfit;
end


% Create function series for higher-resolution plotting
if length(x)<100
    out.xplot=x(1):.01:x(end); %Put more points in curve to draw smoothly
else
    out.xplot=x;
end
out.yplot=feval(out.fitobj,out.xplot);


%% plot
if plotflag
    figure;hold on;
    plot(x,y,'bo') %plot the data; should be an approximatey sigmoid shape curve
    line(out.xplot,out.yplot,'color','r') %overlay the fitted curve
    hold off;
    try
        title(strcat([out.warnings, ' ', strrep(filename,'_',' ')]))
    end
    legend('Data','Model','location','NorthEastOutside')
    xlabel('Stimulus #')
    ylabel('P[response = "target"]')
    xlim([x(1) x(end)])
    %ylim([0 1])
    
    zoom on;
    % linkdata on;
    % openvar y
    
end % if plot

end %fn