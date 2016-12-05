function out=sigmoid_fit_nlin(x,y,direction,tmethod,constrain,plotflag,filename)
% SAtb function: sigmoid_fit_nlin(x,y,direction,tmethod,constrain,plotflag,filename)
%

% March 2013 - Run-time notes for pmetric_model for RISE poster
% SOME warnings not being reported in output... But are being noted in cmd window (no not being suppressed, oddly)
% ="In nlinfit at 280" = 
%     if any(all(abs(J)<sqrt(eps(norm(J,1))),1),2) % one or more columns of zeros
%            warning(message('stats:nlinfit:ModelConstantWRTParam'));
% - Because nlinfit code has revision? This is a new warning message I'm not trapping. 
% - No longer fails in my try statement in sigmoid_fit_nlin under ML2012b (Using my sigmoid_fit_cftb does catch the warnings)
% 	- can set sigmoid_fit's plotflag=1 to see some pattern, perhaps.
% [lastmsg, lastID] = lastwarn; %will report last warning, even if output to cmd-window is suppressed with warning().
% - use this to flag all nlinfit errors.





% Fit your signal detection response data to a sigmoid curve to find the
% threshold and other psychmentric function measures.
%
% Spencer Lynn, spencer.lynn@gmail.com
% Requires Statistics Toolbox, sometimes Symbolic Toolbox
%
%WHERE:
% - x & y are vectors of x-axis stimulus values and points drawing a more or less sigmoid curve
% such as probability (proportion 0..1, not percent) of "go" response at each stimulus value.
% - constrain = 0 (no constraint) or 1 (constrain Y min & max to 0 and 1).
% - direction = specifies whether left or right side of response gradient should be high (=1, 100% response strength)
%             = {'lefthigh' | 'righthigh'}
% - tmethod is method for determining threshold: 'y5', 'yfitmid', 'inflection'
% 
% sigmoid_fit_output = (example)
% 
%            mfile: 'sigmoid_fit_nlin' %log model method
%         warnings: ''                 %log model warnings
%        direction: 'righthigh'        %run-time param
%        constrain: 0                  %run-time param
%          tmethod: 'inflection'       %run-time param
%             note: ''                 %user-entered commment (available in event-driven mode).
%                R: [4x4 double]       %nlinfit quality control
%                J: [11x4 double]      %nlinfit quality control
%             COVB: [4x4 double]       %nlinfit quality control
%              MSE: 0.0038             %nlinfit quality control
%             yfit: [0.0195 0.0294 0.0645 0.1757 0.4280 0.7301 0.9046 0.9669 0.9851 0.9901 0.9914]
%             ylow: 0.0158             %Not exactly = y(min(x)) or y(x=0). ~low assymptote? I set to NaN if constrained=1.
%            yhigh: 0.9761             %Not exactly = max(y)-min(y). Not high assymptote. NaN if constrained = 1.
%     inflectionpt: 5.2381             %x-value @ inflection point
%            theta: 0.7594             %sigmoid shape parameter, influences slope: larger value = flatter curve, since in denominator: x/p(4)
%              rsq: 0.9860             %R-squared goodness of fit
%      guessed_yes: 0.0195             %min(yfit), ~y-value @ min(x)
%       guessed_no: 0.0086             %max(yfit), ~y-value @ max(x)
%        threshold: 5.2381             %x-value @ modeled threshold, dependant on t-method.
%            y_thr: 0.5039             %yfit @ modeled threshold
%            slope: 0.3213             %straight-line rise/run across modeled threshold
%            xplot: [1x1001 double]    %high res plot
%            yplot: [1x1001 double]    %high res plot
% 
%        
%NOTES:
% - pmetric fn can actually be shifted above/below p(target)=0.5, this is expected in high bias, high similiarity.
%   So, : don't constrain fit to 0-1, inflection: truncate at x-axis boundary, yfitmid is not a threshold, y5 is bad.
% - A main differnce btw contrained and unconstrained is location of threhsold, rather than P[endpoints].
% - Some data are really hinky with unconstrained, but look more normal constrained, with more realistic threshold location.
% - if lots of Jacobian warnings, try sigmoid_fit_cftb.m instead.
% - Warnings may be present in the output:
%       !FIT = Fit failed
%       NLIN = Bad fit (eg, ill conditioned Jacobian)
%       ASY = Asymptote may be high
%       THR - threshold out of bounds
%       RSQ - r^2 is ± infinite

%
%CHANGE LOG
% 10/20/08 - started, at McLean Hospital 
% 4/18/12 - forked from sigmoid_fit.m (now depricated). See that file for earlier changes.
% 4/18/12 - renamed to "_nlin" to distinguish from other fit methods.
%         - added some flexibility re direction, warnings, based on _cftb version.
%         - removed x-shift code, removed notes re old calculation methods.
%         - removed NaN assignments when nlinfit crashes, now RETURN.
% 4/25/12 - added struct records for high-resolution x and yfn for plotting
% 4/1/13 - Using lastwarn to trap nlinfit warnings
%
%TO DO
% - add a t-method that simply finds stimulus interval w/steepest change.
% - get 95%CI on parameter estimates (p-hats)?
%%%%%%%%%%%%%%%%%%%%%



%% Use this demo data if none provided with function call.
if nargin==0
%          y=[0	0	0	0	4.44E-02	3.19E-01	8.21E-01	9.12E-01	1	1	         NaN] %what re NaNs in pmetric output?
    y=[0.1 0.1 0.0885    0.1823    0.5340    0.7587    0.9145    0.9711  0.9762 1 1]; %psychometric fn: probability of "go" response for each stimulus
    x=1:length(y); %eg, 1-11 = number of stimuli in continuum.
%     y=fliplr(y); %what is y is high-left rather than high-right?
    
    if y(1)>y(end)
        direction='lefthigh';
    else
        direction='righthigh';
    end
    
    constrain=1;
    plotflag=1;
    tmethod='yfitmid';% 'y5', 'yfitmid' 'inflection'
end

%% Inits
out.mfile=mfilename;
out.warnings='';
out.direction=direction;
out.constrain=constrain;
out.tmethod=tmethod;
out.note='';

out.threshold=NaN;
out.slope=NaN;
out.theta=NaN;
out.y_thr=NaN;
out.guessed_yes=NaN;
out.guessed_no=NaN;
out.yfit=NaN;
out.rsq=NaN;

%% Use statistics toolbox function NLINFIT to fit a user-specified non-linear function to the data:
%We'll use the logistic distribution function (M&C1991 EQ. 8.1).
% nlinfit methods use several terms to refer to the curve parameters:
% b0=initial seed values, phats=modeled est. values; where:
% p(1) = y(0), ie y when x=zero, or maybe low assymptote?: can constrain to 0
% p(2) = y max-min, or maybe high assymptote? (~=y(xmax)-y(0) at any rate): can constrain to 1
% p(3) = mu: x-axis value of inflection pt of the sigmoid
% p(4) = theta: influences slope of curve through midpoint (larger value = flatter curve)

switch constrain %do/don't constrain min and max to 0<->1.
    case 0
        %Unconstrained
        b0=[0 1 max(x)/2 .5]; %Specify initial values for fn parameters, to seed least-squares fit
        switch direction
            case 'righthigh'
                f = @(p,x) p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));%slope is negative: "-(x-inflectionpt)"
            case 'lefthigh'
                f = @(p,x) p(1) + p(2) ./ (1 + exp((x-p(3))/p(4))); %slope is positive
            otherwise
                disp(strcat(['Direction not recognized in ',mfilename,'. Processing stopped.']))
                return
        end
    case 1
        %Constrained
        b0=[max(x)/2 .5]; %Specify initial values for fn parameters, to seed least-squares fit
        switch direction
            case 'righthigh'
                f = @(p,x) 0 + 1 ./ (1 + exp(-(x-p(1))/p(2))); %slope is negative"-(x-thres)"
            case 'lefthigh'
                f = @(p,x) 0 + 1 ./ (1 + exp((x-p(1))/p(2)));%slope is positive:
            otherwise
                disp(strcat(['Direction not recognized in ',mfilename,'. Processing stopped.']))
                return
        end
    otherwise
        disp(strcat(['Contraint value not recognized in ',mfilename,'. Processing stopped.']))
        return
end

lastwarn('');%Reset warnings cue.
try
    [phats,out.R,out.J,out.COVB,out.MSE] = nlinfit(x,y,f,b0); %fit the fn to the observed data
catch nlinfit_error
    %Catch fatal nlinfit errors
    out.warnings=strcat([out.warnings,'!FIT',';']);
    %nlinfit_error.identifier
    return
end %try nlinfit

[lastmsg, lastID] = lastwarn; %Fetch last warning (even if output to cmd-window is suppressed with warning()).
if ~isempty(lastID)
    out.warnings=strcat([out.warnings,'NLIN',';']);
    %lastID
    %lastmsg
end

%% Evaluate the fn to get estimated Y's from the model.
out.yfit=f(phats,x);


%% Assign parameter estimates to output struct, where
switch constrain
    case 0 %model unconstrained
        out.ylow=phats(1);
        out.yhigh=phats(2);
        out.inflectionpt=phats(3);
        out.theta=phats(4);
    case 1 %model constrained
        out.ylow=NaN;
        out.yhigh=NaN;
        out.inflectionpt=phats(1);
        out.theta=phats(2);
end


%% Quality control on fitting process
% - if warning, you could try (on a subsequent run) to reevaluate subject with alternative constraint and treshold methods.
% - if lots of Jacobian warnings, try sigmoid_fit_cftb.m instead.

% [q1,r1] = qr(out.J,0);
% if (condest(r1) > 1/(eps(class(phats)))^(1/2))
%        out.warnings=strcat([out.warnings,'JAC',';']);
% end

if constrain == 0 && out.yhigh >1.2 %p(2) much beyond P["Go"]=0..1 suggests un-sigmoid shape
    out.warnings=strcat([out.warnings,'ASY',';']);
end

%% Determin R-squared goodness of fit
obs=~isnan(y); %Exclude NaNs' in observed data.
out.rsq=rsq(y(obs),out.yfit(obs));
if isinf(out.rsq)
    out.warnings=strcat([out.warnings,'RSQ',';']);
    out.rsq=NaN;
end

%% Estimate Guessing
%These values are the guess rates for each of yes,no keys; to use as ppt filter in SPSS, try: gy>0.45, gn>0.45, not <0.55!
%Valid for either constrained or unconstrained runs, I believe.
ymax=max(out.yfit); %limit min & max to [0 1]
if ymax >1
    ymax=1; %In pefect case, max p[target] = 1, thus any deviation from this is guess (guessed "no") by pressing the FOIL button
end
ymin=min(out.yfit);
if ymin <0
    ymin=0; %In pefect case, min p[target] = 0, thus any deviation from this is guess (guessed "yes") by pressing the TARGET button
end
out.guessed_yes=ymin; %est. proportion of trials on which subject pressed TARGET as a guess (causing elevation of NO/min reponses off of 0).
out.guessed_no=1-ymax; %est. proportion of trials on which subject guessed NO


%% Find the threshold in one of several ways:
switch tmethod
    case 'inflection'
        %Threshold = the inflection point of yfit, See M&C1991 Figure 8.1
        %The best method when curve is nicely sigmoid, otw take infl/constrained or midpoint/unconst
        %With this method, Thr may be beyond stimulus range.
        out.threshold=out.inflectionpt; %the model-fitting parameters, above
        out.y_thr=f(phats,out.threshold); %response strength (value of y) at threshold.
        
    case 'yfitmid'
        %Threshold = the value of p at mid-point of it's y-axis range.
        %Good method if shape or computing resouces make inflection method ill-suited.
        ymax=max(out.yfit); %limit min & max to [0 1]
        if ymax >1
            ymax=1;
        end
        ymin=min(out.yfit);
        if ymin <0
            ymin=0;
        end
        
        midpt=ymin+(ymax-ymin)/2;
        %Given Ps, solve for y=midpt  --> note the -midpt added to the end of our fn below:
        p=phats;
        fstr=strrep(func2str(f),'@(p,x)',''); %Convert function to string
        fstr=strrep(fstr,'.',''); %Strip dots for solving
        t=solve(strcat('(',fstr,')','-midpt')); %SOLVE is part of Symbolic Toolbox, I think
        out.threshold=eval(t); %EVAL is part of Symbolic Toolbox, I think
        out.y_thr=midpt; %response strength (value of y) at threshold.
        
    case 'y5'
        %Threshold = the point at which y=0.5. Problematic for odd psychometric functions -> t=imaginary.
        %Given Ps, solve for y=.5  --> note the -.5 added to the end of our fn below:
        p=phats;
        fstr=strrep(func2str(f),'@(p,x)',''); %Convert function to string
        fstr=strrep(fstr,'.',''); %Strip dots for solving
        t=solve(strcat('(',fstr,')','-.5')); %SOLVE is part of Symbolic Toolbox, I think
        out.threshold=eval(t); %EVAL is part of Symbolic Toolbox, I think
        %out.threshold=p(3)-1.*log(-1.*(2.*p(1)+2.*p(2)-1.)/(2.*p(1)-1.))*p(4); %no need for other people to have SOLVE, EVAL
        out.y_thr=0.5; %response strength (value of y) at threshold.        
        if ~isreal(out.threshold) %when y=.5 is NOT on fit curve, t=imaginary
            out.threshold=NaN;
            out.warnings=strcat([out.warnings,'THR',';']);
            disp('y=.5 is NOT on fit curve, t=imaginary, recorded as NaN')
        end

    otherwise
        disp('Requested threshold calculation method not recognized by sigmoid_fit.m')
end %switch

%Calc slope as rise/run @+/- small distance from threshold
xs=[out.threshold-.01 out.threshold+.01];
ys=f(phats,xs);
out.slope=(ys(2)-ys(1))/(xs(2)-xs(1));

if (out.threshold>max(x) || out.threshold<min(x))
    out.warnings=strcat([out.warnings,'THR',';']);
end

% Create function series for higher-resolution plotting
if length(x)<100
    out.xplot=x(1):.01:x(end); %Put more points in curve to draw smoothly
else
    out.xplot=x;
end
out.yplot=f(phats,out.xplot);


%% Plot
if plotflag
    %% Plot Response Gradient & Fit
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
end %% if

end %%
