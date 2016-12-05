function compare_sigmoids(action,x,y,direction,plotname)
% SAtb function: compare_sigmoids(action,x,y,direction,plotname)
% 
% Where:
% action = event-loop action
% x = x-axis data
% y = observed y-axis data
% direction = sigmoid direction: 'lefthigh' or 'righthigh'
% plotname = string for labeling plot (eg, a ppt-ID#)
% 
% This m-file plots alternative sigmoid fits to observed data. User then clicks in the plot-legend
% to select the best fit, to be logged in a processed-data file (controlled elsewhere). 
% 
% Uses: sigmoid_fit_cftb.m, sigmoid_fit_nlin.m to fit sigmoids. t-method
%       and constraint options for those functions are hard-coded below.
% 
% 
% Spencer Lynn, spencer.lynn@gmail.com, 4/18/12
% 
% Notes:
% - See h2_process.m for the first use of this function
% - Plot threes fits with fit params hard-coded in this script, called cftb, nlin1, nlin2
%
% To do:
%- make the fig window more operational: notes, exclude btn
%%%%%%%%%%%%%%%%%%%%%%
   
global caller %the name of the data processing m-file that calls this function.
global sigmoid_fit_output %the sigmoid fit results selected by the user; gets picked up by calling data processing mfile.
global cs_p %global params specific to this mfile.


switch nargin
    case 0 %Run in developement/demo mode with example data defined here.
        %y=[7.50E-01	0	2.50E-01	2.50E-01	0	0];
        %y=y/100;
        y=[0.1 0.1 0.0885    0.1823    0.5340    0.7587    0.9145    0.9711  0.9762 1 1]; %psychometric fn: probability of "go" response for each stimulus
        x=(1:length(y)); %eg, 1-11 = number of stimuli in continuum.
        if y(1)>y(end)
            direction='lefthigh';
        else
            direction='righthigh';
        end
        plotname='CS-test';
        cs_p.demoflag=true;
        compare_sigmoids('compare_sigmoids',x,y,direction,plotname) %Call this function again, using demo data, filler for action.
        
    case 1 %User selected fit passed in from click on plot        
        switch action
            case 'fetch_fit_results' %This catches recursive calls during development/demo runs
                sigmoid_fit_output %print selection to screen
                compare_sigmoids %rerun the demo, reestablish cs_p.
            otherwise %user clicked a plot series
                %get(gco,'Tag') %Oops, returns "legend" rather than actual calling element of legend, so this method fails.
                %Use this instead, where action is a string derived from a legend element's ButtonDownFcn, sent on to local fn defined below.
                close(cs_p.plot_handle) %close the figure
                sigmoid_fit_output=eval(action); %the action names the initialized fit result structures (globals). This line assigns the selected fit to the more general global fit_output.
                try
                    sigmoid_fit_output.note=cs_p.note; %Assign note, if present, to selected fit.
                end
                cs_p=[]; %clear variables                
                eval(strcat(caller,'(''fetch_fit_results'')')); %Send fetch_fit_results action call to calling mfile (perhaps this file, as demo)...which must have this switch/case option
                sigmoid_fit_output=[]; %clear variables
        end  
        
    case 2 %Add a note
        switch action
            case 'note'
                %Notes can be typed by hand at Matlab prompt, as compare_sigmoids('note','Note text.')
                cs_p.note=x; %Temp storate until a fit is selected by user.
            otherwise
                disp(strcat(['Action ''',action,''' not recognized in ',mfilename,'.']))
        end
        
    case 5 %Create and plot fits
        caller=action; %Use the caller/action so we can send selected_element structure back to the data-processing mfile for writing.
        local_do_plots(x,y,direction,plotname) %Run the sigmoid fits, plot the comparision
        
    otherwise %nargin not matched to case
        disp('Error in number of arguements passed to compare_sigmoids.m')
end %switch nargin
end %Primary fn


%% Local functions

function local_do_plots(x,y,direction,plotname)
global cs_p %fit results (sigmoid_fit_outputs): plot series available for the user to select

fitplots=0;

%Method to get most h2 gradients, which otherwise generate a lot of
%jacobian errors
cftb_tmethod='inflection';
cftb_constrain=1;

%Method to get odd-ball gradients (eg, high guess rates)
nlin1_tmethod='inflection';
nlin1_constrain=0;

%Alt method re t-loction, for odd-ball gradients
nlin2_tmethod='yfitmid';
nlin2_constrain=0;

% toggle_warnings.m should be controlled by calling data processing function if desired.
try 
    if cs_p.demoflag==true;toggle_warnings('off');end 
end
cs_p.cftb=sigmoid_fit_cftb(x,y,direction,cftb_tmethod,cftb_constrain,fitplots,plotname);
cs_p.nlin1=sigmoid_fit_nlin(x,y,direction,nlin1_tmethod,nlin1_constrain,fitplots,plotname);
cs_p.nlin2=sigmoid_fit_nlin(x,y,direction,nlin2_tmethod,nlin2_constrain,fitplots,plotname);
try 
    if cs_p.demoflag==true;toggle_warnings('on');end 
end



%% Plot Response Gradients & Fit
left=300;
top=2200;
right=1024;
bottom=600;

cs_p.plot_handle=figure;hold on;
set(cs_p.plot_handle,'Position',[left top right bottom])
plot(x,y,'ko','MarkerFaceColor','k') %plot the observed data

line(cs_p.cftb.xplot,cs_p.cftb.yplot,'color','r','LineWidth',2) %overlay fitted curve
line(cs_p.nlin1.xplot,cs_p.nlin1.yplot,'color','b','LineWidth',2) %overlay fitted curve
line(cs_p.nlin2.xplot,cs_p.nlin2.yplot,'color','c','LineStyle','-.','LineWidth',2) %overlay fitted curve

plot([cs_p.cftb.threshold cs_p.cftb.threshold],[cs_p.cftb.y_thr-.15 cs_p.cftb.y_thr+.15],'r','LineWidth',2)
plot([cs_p.nlin1.threshold cs_p.nlin1.threshold],[cs_p.nlin1.y_thr-.15 cs_p.nlin1.y_thr+.15],'b','LineWidth',2)
plot([cs_p.nlin2.threshold cs_p.nlin2.threshold],[cs_p.nlin2.y_thr-.15 cs_p.nlin2.y_thr+.15],'c-.','LineWidth',2)

hold off;
try
    title(strrep(plotname,'_',' '))
end
xlabel('Stimulus #')
ylabel('P[response = "target"]')
%     xlim([x(1) x(end)])
%     ylim([0 1])
%     zoom on; %Must be off for ButtonDownFcn to work.


% Create legend, make series-names run scripts on click.
[legh objh outh outm]=legend('Observed',...
    strcat(['cftb: ',num2str(cs_p.cftb.rsq,3),' ',cs_p.cftb.warnings]),...
    strcat(['nlin1: ',num2str(cs_p.nlin1.rsq,3),' ',cs_p.nlin1.warnings]),...
    strcat(['nlin2: ',num2str(cs_p.nlin2.rsq,3),' ',cs_p.nlin2.warnings]),'location','SouthOutside');
% LEGH = a handle to the legend axes.
% OBJH = a vector containing handles for the text, lines, and patches in the legend.
%      - First rows appear to match series names, in order
% OUTH = a vector of handles to the lines and patches in the plot.
% OUTM = a cell array containing the text in the legend.

if strmatch('cftb',get(objh(2),'String')) %Check for match before setting properties.
    set(objh(2),'ButtonDownFcn','compare_sigmoids cs_p.cftb')
else
    disp('Could not match legend string cftb.')
end

if strmatch('nlin1',get(objh(3),'String'))
    set(objh(3),'ButtonDownFcn','compare_sigmoids cs_p.nlin1')
else
    disp('Could not match legend string cftb.')
end

if strmatch('nlin2',get(objh(4),'String'))
    set(objh(4),'ButtonDownFcn','compare_sigmoids cs_p.nlin2')
else
    disp('Could not match legend string cftb.')
end

end %initialize fn


