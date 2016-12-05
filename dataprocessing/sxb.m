function sxb_output=sxb(datamat,parameters,plotflag)
%SAtb fn SXB -- Explore sensitivity x bias relationship.
%
%Bascially: reports minimum distance of [senditivity,bias] data point to
%curve defined by ideal association (from model, best-operators, whatever).
%Calculated by main force, no differential eq.
% 
%To use this to plot color-coded groups' d',c scatter plot on LOR:
% - save d',c,group# to pass in as datamat
% - call EXPT_sxb to get parameters, create struct like:
%         parameters = 
%                 method: = 'beta'
%           dprime_range: = 0:0.01:1.5
%                   beta: = [(1-alpha)/alpha] ? [(j-a)/(h-m)] ...eg, 1.5385
% - call this script


%OLD 1/2/12 steps, using m-files, beta (rather than SPSS, inverse fn curve fitting):
% 1. Use expt-name_lorpoints.m to hand-tune the output of dprime,bias pts (which define the LOR).
% 2. Send the points to lor_fit.m to obtain the Beta coefficient that best fits the LOR.
% 3. Log the beta and other LOR curve parameters into expt-name_sxb.m
% 3. Use this sxb fn with datamat = a ppts dprime,bias pt, paramters = expt-name_sxb.m output to get distances. 
% 
%OLD Steps (SPSS, inverse fn curve fitting):
%- use compare_params to generate points on ideal line
%- fit those points in SPSS (Regr/Curve Fit (inverse w/ANOVA tbl), get the equation for line of best-fit
%- specify the equation for the line in this code, give paramters as input
%- paste in x,y data from spreadsheet into Matlab cmdwindow
%- call sxb function with data matrix name (x,y,opt z) and
% e.g.:
% parameters.method='inverse';
% parameters.b0=0.0080; %=B value "constant" from SPSS curve fit output
% parameters.b1=0.1070; %=B value "1/dprime" from SPSS curve fit output
% parameters.dprime_range=0:0.1:3
%- outputs plot and to cmdwindow a col of distances; paste back into spreadsheet
% 
% To get just the LOR: Can have this run w/out a datamat
% parameters=baseline_params
% lor=eval(model)'
% [parameters.dprime_range' lor]
% 
% Change Log:
% 12/31/11 - added case = beta, using output from new lor_fit.m
%          - changed functionality of expt_lor_points and expt_sxb fns 
%           so that this fn can be called with expt_process_data.m as, eg, sxb(expt_lorpoints('scenario'),expt_sxb('scenario'),1)
% 1/2/12   - wrote new steps to document the work flow from model to distance.
%~6/19/12  - Depricated lor_fit, no longer need "lor_points" scripts, so steps 1-2 of work flow differ from above.
% 4/3/13   - Fixed bug for determining direction when method=beta.
%            Commented out other case methods, below. Check them for same thing before using.
% 9/1/15   - Added c_opt code: determine the LOR bias corresponding to shortest distance. Could be useful for motivation syndrome scores.
%          - Currently, it's only output to cmd window by uncommenting line ~121, below.
% 01/11/16 - Changed the output to a struct with a fields distance, direction, c_opt. Older version depricated, so it's still callable by old _process scripts.
%%%%%%%%%%%%%%%

global model dprime bias ys

switch parameters.method
    %For all except beta, models: file:///Applications/SPSSInc/SPSS16GP/SPSS16.0.app/Contents/bin/help/main/overvw_auto_0.htm
    %parameter values fit in SPSS
    
    case 'beta'
        model='log(parameters.beta)./parameters.dprime_range';
        model_obs='log(parameters.beta)./dprime';
                
    case 'linear' %
        model='parameters.b0+parameters.b1.*parameters.dprime_range';
        model_obs='parameters.b0+parameters.b1.*dprime';
   
% Check for diagonal mirror-fn on these before using direction calculation. 
% See correction for d'<0 for method=beta, below.
%     case 'inverse'
%         model='parameters.b0 + parameters.b1 ./ parameters.dprime_range'; %Line of Optimal Response (LOR)
%         model_obs='parameters.b0 + parameters.b1 ./ dprime'; %Optimal bias at each observed dprime.
%         
%     case 'power'
%         model='parameters.b0.*(parameters.dprime_range.^parameters.b1)';
%         model_obs='parameters.b0.*(dprime.^parameters.b1)';
%         
%     case 'quadratic' %
%         model='parameters.b0+parameters.b1.*parameters.dprime_range+parameters.b2.*parameters.dprime_range.^2';
%         model_obs='parameters.b0+parameters.b1.*dprime+parameters.b2.*dprime.^2';

        
    otherwise
        disp('Method not recognized in sxb.m fn')
        
end %switch
model=eval(model);
%size(model)

dprime=datamat(:,1);
bias=datamat(:,2);
sxb_output.distance=zeros(size(dprime))*NaN;
index=zeros(size(dprime))*NaN;
sxb_output.c_opt=zeros(size(dprime))*NaN;

for i=1:length(dprime) %for each observed data point (sens,bias), get distance from model
    [sxb_output.distance(i) index(i)]=get_distance(dprime(i),bias(i),parameters.dprime_range,model,'euclidean');
    sxb_output.c_opt(i)=model(index(i)); %Nearest bias on LOR for ppt's d'.
end

if plotflag
    do_plot(parameters,model,dprime,bias,datamat)
end

model=model'; %transpose the global for external use.

%% Determine sign of distance: too liberal vs conservative
if isequal(parameters.method,'beta')
    % For method=beta, this doesn't return intended value if ppt's d'<0 (and maybe some extremely sub-optimal biases
    % because the function has mirror image in diagonal quadrant:
    % ppt's point may be closer to the mirror than to the real LOR.
    % = Need to pull a particular quadrant of the model; can't be done by
    % limiting d' range...or if d'<0 => d'=0 (just for opt_bias calc, not distance itself)
    dprime(dprime<0)=0; %replace d'<0 with 0 for determining direction
end
opt_bias=eval(model_obs); %determine each ppt's optimal bias for his/her observed dprime. THIS IS NOT EUCLID nearest bias, but the LOR fn bias value associated with ppt's d'.
sxb_output.direction=sign(bias-opt_bias); %for any concavity LOR, if direction <0 then observed bias is too liberal, 0= optimal, >1 too conservative.

%  disp('dprime bias c_opt opt_bias distance direction')
%  [dprime bias sxb_output.c_opt opt_bias sxb_output.distance sxb_output.direction]
 %c_opt
end %fn


function do_plot(parameters,model,x,y,datamat)
figure;hold on;zoom on
ax=gca;
plot(parameters.dprime_range,model) %plot optimal model

if size(datamat,2)>2 %thrid col used for color coding data points
    zcol=uint8(datamat(:,3)); %convert codes to integer
    zcol=double(zcol); %convert codes to integer
    n=max(zcol);%get count of unique colors needed.
%     n=length(unique(zcol));%get count of unique colors needed.
    cmap=jet(n); %set plot's color map to num colors needed
    colormap(ax,cmap);%set plot's color map to num colors needed
    for i=1:length(x)
        plot(ax,x(i),y(i),'ko','MarkerFaceColor',cmap(zcol(i),:)) %over-print x,y pts with colors
    end
    colorbar('peer',ax)
else
    plot(x,y,'ko') %plot data points
end
end %fun

function [dx index]=get_distance(x,y,xs,ys,metric)
% For method = beta, the fn is mirrored in diagonal quadrant. 
% This method for distance works in that case, because we are limiting 
% dprime_range to the real LOR; it doesn't extend to alternate quadrants.

xs=[x;xs']; %prepend point of interest to list of all points that make up the line
ys=[y;ys'];
points=[xs ys];
dx=squareform(pdist(points,metric));
[dx index]=min(dx(1,2:end)); %top row of output is distances from pt1 to all other points. (remaining rows are distances from other points...)
end %fun