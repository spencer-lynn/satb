function set_params(myparam)
% SAtb fn: set_params -- SET SIGNAL PARAMETERS FOR AN EXPERIMENTAL RUN
% Uses a list file that must have particular file name and colum names.
% Parameters can be listed in any order.
%
% Change log:
% 6/18/10 added distn globals to parameters_list for each signal (S+,S-)
%   = specifies distribution shape from which signal is sampled.
%   Defaults to 'normal' for backwards compatibility.
% 7/30/10 added additional optional lines in info-list for x_range min and step values. This permits x_range to start at values >1.
% 1/15/11 made param reading more flexible to accomodate separate x_ranges for targets vs foils.
%     made global signal_params, used in assign/fetch_signals
% 
% 2/8/11 
% - modified to use new listfile format (with traspose=false flag on read_list).
% - dropped all backwards compatibility code
% 
% 7/31/12 began adding additional outcome codes, such as D0, Dx (from response_feedback), in try blocks (used, eg, in peak shift studies, stimdur_test)
% 3/11/15 signal_params had been both an output of this function and a global set by this function. I removed the output.


global listfolder signal_params %struct to hold everything going forward.

params.transpose = false;
params.rnd = false;
paraminfo=read_list(strcat(listfolder,'parameters_',myparam,'_list.txt'),params);


% Define basic elements
%HOW TO: cell reference = {column}(row)... eval(char()) -> numeric interpretation

% Specify target, foil distribution shapes
i=strmatch('distnTarget',paraminfo.Parameter,'exact'); %aka S+ distribution
signal_params.distnTarget = char(paraminfo.Value(i));

i=strmatch('h',paraminfo.Parameter,'exact'); % h = benefit of correct detection of target (points)
signal_params.h = eval(char(paraminfo.Value(i)));

i=strmatch('m',paraminfo.Parameter,'exact'); % m = cost of missed detection of target (points)
signal_params.m = eval(char(paraminfo.Value(i)));

i=strmatch('distnFoil',paraminfo.Parameter,'exact'); %aka S+ distribution
signal_params.distnFoil = char(paraminfo.Value(i));

i=strmatch('a',paraminfo.Parameter,'exact'); % a = cost of false alarm of foil (points)
signal_params.a = eval(char(paraminfo.Value(i)));

i=strmatch('j',paraminfo.Parameter,'exact'); % j = benefit of correct rejection of foil (points)
signal_params.j = eval(char(paraminfo.Value(i)));


try
i=strmatch('D0',paraminfo.Parameter,'exact'); % D0 = Correctly press distractor-key to distractor stim
signal_params.D0 = eval(char(paraminfo.Value(i)));
end

try
i=strmatch('Dx',paraminfo.Parameter,'exact'); % Dx = Press distractor-key to target or foil stim
signal_params.Dx = eval(char(paraminfo.Value(i)));
end

try
i=strmatch('Dplus',paraminfo.Parameter,'exact'); % D+ = S+ button press to distractor stim
%Use this in peakshift or for stims with no correct answer, such as stimuli that will receive a confidence rating.
signal_params.Dplus = eval(char(paraminfo.Value(i)));
end

try
i=strmatch('Dminus',paraminfo.Parameter,'exact'); % D- = S- button press to distractor stim
%Use this in peakshift or for stims with no correct answer, such as stimuli that will receive a confidence rating.
signal_params.Dminus = eval(char(paraminfo.Value(i)));
end

try
i=strmatch('Rating',paraminfo.Parameter,'exact'); % Rating = Delivered a (numeric) rating (eg, mood, confidence)
signal_params.Rating = eval(char(paraminfo.Value(i)));
end



% Specify relative base rate of T vs F occurance
i=strmatch('baserate',paraminfo.Parameter,'exact'); %aka alpha
signal_params.baserate = eval(char(paraminfo.Value(i)));

%Get further details given distribution type
switch signal_params.distnTarget
    case 'normal'
        % Specify mean and variance (wouldn't be given for Uniform distn
        i=strmatch('muTarget',paraminfo.Parameter,'exact');
        signal_params.muTarget = eval(char(paraminfo.Value(i)));
        
        i=strmatch('varTarget',paraminfo.Parameter,'exact');
        signal_params.varTarget = eval(char(paraminfo.Value(i)));
        
    case 'uniform'
        %Do nothing else.
        
end %switch target

switch signal_params.distnFoil
    case 'normal'
        i=strmatch('muFoil',paraminfo.Parameter,'exact');
        signal_params.muFoil = eval(char(paraminfo.Value(i)));
        
        i=strmatch('varFoil',paraminfo.Parameter,'exact');
        signal_params.varFoil = eval(char(paraminfo.Value(i)));
        
    case 'uniform'
        %Do nothing else.
        
end %switch foil



% Define target x-range
i=strmatch('xmax_target',paraminfo.Parameter,'exact');
xmax=eval(char(paraminfo.Value(i)));

i=strmatch('xmin_target',paraminfo.Parameter,'exact');
xmin = eval(char(paraminfo.Value(i)));

i=strmatch('xstep_target',paraminfo.Parameter,'exact');
xstep = eval(char(paraminfo.Value(i)));

signal_params.x_range_target=xmin:xstep:xmax;


% Define foil x-range
i=strmatch('xmax_foil',paraminfo.Parameter,'exact');
xmax=eval(char(paraminfo.Value(i)));

i=strmatch('xmin_foil',paraminfo.Parameter,'exact');
xmin = eval(char(paraminfo.Value(i)));

i=strmatch('xstep_foil',paraminfo.Parameter,'exact');
xstep = eval(char(paraminfo.Value(i)));

signal_params.x_range_foil=xmin:xstep:xmax;


end