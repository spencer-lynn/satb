function modelgui(process,conditions)
%GUI for playing with the SAtb utility function models
global callback_modelgui modelguiPanelHandles plot_settings model_output signalsPlotAxis utilPlotAxis scenario

if nargin==0; process='setup'; end %runs at startup
switch process
    case 'setup'
        %% SET UP MAIN PROCESSING PARAMS, DEFAULTS
        callback_modelgui=mfilename; %get name of this m-file for use by callback fns in panel GUI.
        h=modelgui_panel; %load the GUI panel
        modelguiPanelHandles=guihandles(h) %struct of all GUI-panel component HANDLES

        signalsPlotAxis=gca(modelguiPanelHandles.signalsModel); %GCA for the figure window called signals.Model
%         signalsPlotAxis=modelguiPanelHandles.signalsAxis;
       utilPlotAxis=modelguiPanelHandles.pmetAxis;
%something buggy here: fig creation is renaming last axis.
       
        plot_settings=define_plot_settings; %load plot settings
        scenario=quary_panel(modelguiPanelHandles); %Get the default parameter settings from the GUI panel
        do_updates
                
    case 'set_muTarget'
        scenario.muTarget=conditions; %update the parameter setting
        set(modelguiPanelHandles.muTargetEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_varTarget'
        scenario.varTarget=conditions; %update the parameter setting
        set(modelguiPanelHandles.varTargetEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_muFoil'
        scenario.muFoil=conditions; %update the parameter setting
        set(modelguiPanelHandles.muFoilEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_varFoil'
        scenario.varFoil=conditions; %update the parameter setting
        set(modelguiPanelHandles.varFoilEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_baserate'
        scenario.baserate=conditions; %update the parameter setting
        set(modelguiPanelHandles.baserateEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_h'
        scenario.h=conditions; %update the parameter setting
        set(modelguiPanelHandles.hEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_m'
        scenario.m=conditions; %update the parameter setting
        set(modelguiPanelHandles.mEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_a'
        scenario.a=conditions; %update the parameter setting
        set(modelguiPanelHandles.aEdit,'String',num2str(conditions))
        do_updates
        
    case 'set_j'
        scenario.j=conditions; %update the parameter setting
        set(modelguiPanelHandles.jEdit,'String',num2str(conditions))
        do_updates
                
end %main event switches
end %main fns

function unused
%second, trasparent axis overlay
h2 = axes('Position',get(h1,'Position')); %Create the second axes at the same location
plot(days,TCE,'LineWidth',3) %plot the overlay data
set(h2,'YAxisLocation','right','Color','none','XTickLabel',[]) %To ensure that the second axes does not interfere with the first, locate the y-axis on the right side of the axes, make the background transparent, and set the second axes' x tick marks to the empty matrix:
set(h2,'XLim',get(h1,'XLim'),'Layer','top') %Align the x-axis of both axes and display the grid lines on top of the bars:

end
    
    
   
    
function do_updates
global model_output scenario signalsPlotAxis utilPlotAxis
        model_output=run_model(scenario);
        plot_model(signalsPlotAxis,utilPlotAxis,scenario.x_range,model_output)
end

function plot_model(faxis,uaxis,x_range,model_output)
global plot_settings

cla(faxis)
hold(faxis,'on');

if plot_settings.Splus_distn.on;plot(faxis,x_range,model_output.Splus_distn,plot_settings.Splus_distn.color,'LineWidth',plot_settings.Splus_distn.linewidth);end%Distn of S+.
if plot_settings.Sminus_distn.on;plot(faxis,x_range,model_output.Sminus_distn,plot_settings.Sminus_distn.color,'LineWidth',plot_settings.Sminus_distn.linewidth);end%Distn of S-.
if plot_settings.cd_ara.on;plot(faxis,x_range,model_output.cd_ara,plot_settings.cd_ara.color);end%CDF envelope of S+.
if plot_settings.fa_ara.on;plot(faxis,x_range,model_output.fa_ara,plot_settings.fa_ara.color);end%CDF envelope of S-.
if plot_settings.cl_ara.on;plot(uaxis,x_range,model_output.cl_ara,plot_settings.cl_ara.color);end%classic util fn
if plot_settings.threshold.on;plot(faxis,[model_output.threshold model_output.threshold],[plot_settings.threshold.min plot_settings.threshold.max],plot_settings.threshold.color,'LineWidth',plot_settings.threshold.linewidth);end% threshold
try %hstloc is often zero if muTarget>muFoil due to inflexible coding on my part.
    if plot_settings.hstloc.on; plot(faxis,[model_output.hstloc model_output.hstloc],[plot_settings.threshold.min plot_settings.threshold.max],plot_settings.threshold.color,'LineWidth',plot_settings.threshold.linewidth);end% threshold as zero of HotSpot fn
end

if plot_settings.hs_ara.on;plot(faxis,x_range,model_output.hs_ara,plot_settings.hs_ara.color);end%hotspot util fn
if plot_settings.HS_linear_scale.on;plot(faxis,x_range,model_output.response,plot_settings.HS_linear_scale.color);end%HS response probability gradient (lin scaled HS fn)
if plot_settings.minhotspotloc.on;plot(faxis,[model_output.minhotspotloc model_output.minhotspotloc],[plot_settings.minhotspotloc.min plot_settings.minhotspotloc.max],plot_settings.minhotspotloc.color);end% min  of HotSpot fn
if plot_settings.maxhotspotloc.on;plot(faxis,[model_output.maxhotspotloc model_output.maxhotspotloc],[plot_settings.maxhotspotloc.min plot_settings.maxhotspotloc.max],plot_settings.maxhotspotloc.color) ;end% max of HotSpot fn

end

function model_output=run_model(scenario)
% ALL this taken from compare_params2
% model_output.Splus_distn = target signal distn
% model_output.Splus_distn = target signal distn

% model_output.cd_ara = P[CD] at each point on x-axis
% model_output.fa_ara = P[FA] at each point on x-axis
% model_output.md_ara = P[MD] at each point on x-axis
% model_output.cr_ara = P[CR] at each point on x-axis

% model_output.cl_ara = classic utility function
% model_output.threshold = threshold location on x-axis
% model_output.hs_ara = hotspot utility function

% model_output.yint= y-intercept of indifference line
% model_output.pfa2 = top of indifference line

h=scenario.h;
j=scenario.j;
a=scenario.a;
m=scenario.m;
muSplus=scenario.muTarget;
muSminus=scenario.muFoil;
var1=scenario.varTarget;
var2=scenario.varFoil;
alpha=scenario.baserate;
x_range=scenario.x_range;



    %CLASSIC CALCS = use normCDF. normcdf=integral from -INF to x:
    %if muSplus(=S+) is less than muSminus(=S-) (attack to left of threshold) CD & FA =normcdf, MD & CR =1-normcdf
    %if muSplus(=S+) is more than muSminus(=S-) (attack to right of threshold) CD & FA =1-normcdf, MD & CR =normcdf

    if(muSplus<muSminus) %S+ to left of S- on increasing x-axis
        model_output.cd_ara=normcdf(x_range,muSplus,var1);
        model_output.fa_ara=normcdf(x_range,muSminus,var2);
    else %S+ to right of S- on increasing x-axis
        model_output.cd_ara=1-normcdf(x_range,muSplus,var1);
        model_output.fa_ara=1-normcdf(x_range,muSminus,var2);
    end
    model_output.md_ara=1-model_output.cd_ara;
    model_output.cr_ara=1-model_output.fa_ara;


    %Calc slopes of ROC at each point = [(y2-y1)/(x2-x1)].
    diff_cd=diff(model_output.cd_ara);
    diff_fa=diff(model_output.fa_ara);
    slope_ara=diff_cd./diff_fa;

    S=eval('((1-alpha)*(j-a))/(alpha*(h-m))'); %Slope of indifference line.
    classic_util='model_output.cd_ara*alpha*h+alpha*m*model_output.md_ara+(1-alpha)*a*model_output.fa_ara+(1-alpha)*j*model_output.cr_ara'; %Classic Utility.
    model_output.cl_ara=eval(classic_util); %Generate utilty curve

    s_ara=ones(1,length(slope_ara))*S; % make array of size, filled with S value
    s_ara=slope_ara-s_ara; %subtract one from another
    s_ara=s_ara.*s_ara; %square the differences
    hitlist=find(s_ara==min(s_ara)); %the smallest sqare difference locates the closest match to S.
    hitslope=slope_ara(hitlist); %return array of matches to S (identical-value, closest match)

    pCD=model_output.cd_ara(find(model_output.cl_ara==max(model_output.cl_ara)));
    pFA=model_output.fa_ara(find(model_output.cl_ara==max(model_output.cl_ara)));
    model_output.threshold=x_range(find(model_output.cl_ara==max(model_output.cl_ara))); %Get the threshold location

    %Some params settings will force extreme t's; result in multiple identical extreme values. Just pick one.
    if (length(pCD)>1 || length(pFA)>1 || length(model_output.threshold)>1)
        pCD=pCD(1);
        pFA=pFA(1);
        model_output.threshold=model_output.threshold(1); %some params will force multiple extreme t's (all equal, eg at max)
        disp('Multiple pCD, pFA or threshold estimates. Using first.')
    end
    if (S==0 || S>100)
        disp('Extreme threshold location')
    end

    %Indifference Line using using new HitSlope and accurate pCD,pFA
    model_output.yint=pCD-(hitslope(1)*pFA); %y-intercept
    model_output.pfa2=((1-pCD)/hitslope(1))+pFA; %pFA value when pCD=1 = top of indifference line: based on S=[(y2-y1)/(x2-x1)]

    %HOTSPOT CALCS = use normPDF
    model_output.Splus_distn=normpdf(x_range,muSplus,var1);
    model_output.Sminus_distn=normpdf(x_range,muSminus,var2);
    hotspot_util='(model_output.Splus_distn*alpha*h+model_output.Sminus_distn*(1-alpha)*a)-(model_output.Splus_distn*alpha*m+model_output.Sminus_distn*(1-alpha)*j)'; %HotSpot utility fn.
    model_output.hs_ara=eval(hotspot_util); %Generate utilty curves
    
end

function scenario=quary_panel(modelguiPanelHandles)
%Get the default parameter settings from the GUI panel
scenario.baserate=get(modelguiPanelHandles.baserateSlider,'Value'); %Probability of (target vs foil). range 0..1

scenario.h=get(modelguiPanelHandles.hSlider,'Value');   %h=benefit of correct detection of target
scenario.m=get(modelguiPanelHandles.mSlider,'Value');  %m=cost of missed detectin of target
scenario.a=get(modelguiPanelHandles.aSlider,'Value');  %a=cost of false alarm to foil
scenario.j=get(modelguiPanelHandles.jSlider,'Value');  %j=benefit of correct rejection of foil

scenario.muTarget=get(modelguiPanelHandles.muTargetSlider,'Value');  %mean sensory value of target (%-emotion in morph)
scenario.varTarget=get(modelguiPanelHandles.varTargetSlider,'Value'); %variance of target distribution
scenario.muFoil=get(modelguiPanelHandles.muFoilSlider,'Value');    %mean of foil
scenario.varFoil=get(modelguiPanelHandles.varFoilSlider,'Value');   %variance of foil

xstep=.1; %controls "sensory acuity," after a fashion
x_range_min=get(modelguiPanelHandles.muTargetSlider,'Min');
x_range_max=get(modelguiPanelHandles.muTargetSlider,'Max');
scenario.x_range=x_range_min:xstep:x_range_max; %the array of points at which utility will be calculated
end

function plot_settings=define_plot_settings
% x.on set to: 1=plot it, 0=skip it.
%% DISTRIBUTIONS
plot_settings.Splus_distn.on = 1;           %Distn of S+/target.
plot_settings.Splus_distn.color='g';
plot_settings.Splus_distn.linewidth=2;

plot_settings.Sminus_distn.on = 1;          %Distn of S-/foil.
plot_settings.Sminus_distn.color='b';
plot_settings.Sminus_distn.linewidth=2;

plot_settings.cd_ara.on = 0;                %CDF envelope of S+/target.
plot_settings.cd_ara.color='g';

plot_settings.fa_ara.on = 0;                %CDF envelope of S-/foil.
plot_settings.fa_ara.color='b';


%% CLASSIC UTILITY FN
plot_settings.cl_ara.on = 1;                %classic util fn
plot_settings.cl_ara.color='k';


%% THRESHOLD
plot_settings.threshold.on = 1;            %threshold
plot_settings.hstloc.on = 0;               % threshold as zero of HotSpot fn

plot_settings.threshold.color='k';         %use these settings for HSTloc also
plot_settings.threshold.linewidth=2;
plot_settings.threshold.min = -0.1;        %threshold min pt
plot_settings.threshold.max = 0.2;         %threshold heigth


%% HOTSPOT UTILITY FN, CRITERIA
plot_settings.hs_ara.on = 0;                %hotspot util fn
plot_settings.hs_ara.color='k';

plot_settings.HS_linear_scale.on = 0;       %HS response probability gradient (lin scaled HS fn)
plot_settings.HS_linear_scale.color='k';

plot_settings.minhotspotloc.on = 0; %criterion @ min of HotSpot fn (S+ shift)
plot_settings.minhotspotloc.color='b';
plot_settings.minhotspotloc.min = -5;    %threshold min pt
plot_settings.minhotspotloc.max = 5;     %threshold heigth

plot_settings.maxhotspotloc.on = 0; %criterion @ max of HotSpot fn (S- shift)
plot_settings.maxhotspotloc.color='g';
plot_settings.maxhotspotloc.min = -5;    %threshold min pt
plot_settings.maxhotspotloc.max = 5;     %threshold heigth


%% ROC
plot_settings.roc.on = 0;                   %ROC curve
plot_settings.indiffence_line.on = 0;       %indifference line
end