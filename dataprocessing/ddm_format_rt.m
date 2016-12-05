function ddm_format_rt(data,prt)
% Format SAtoolbox response time data for drift-diffusion modeling by fast-dm.exe.
%
% Where:
% - data = cell array of two or three columns {condition, response outcome, response time)
%          intended to be filtered and passed from the experiments EXP_process m-file.
%          - condition/scenario column is optional
%          - rows are individual trials to be processed (any non-trial rows already filtered out)
% - prt = struct of info needed for processing
% - calling fn should add prt.ddm_label if you want extra detail in filenames.
% 
% Output:
% Expects a folder in current director called 'ddm_rt_files/'. It'll put output files there.
% Writes tab-delimited ".rt" file for each participant (with unlabled columns)
% - if provided col 1 = integer condition code, else
% - col 1 = 1/0 correct/incorrect response code,
% - last col = response time in seconds
% - filename is that of original dat file, with any prt.label condition appended. 
%   - If you want additional detail in fname, calling fn could append it to prt.label.
% - file is written to curent direction (ususally EXPT/DATA/rt_dir, see g-outputPath set by calling EXP_process script.
%
%% Change log:
% 20160319 - started. Developed w/ m1 expt data
%
%% Example code to call this fn (for exp_process process called 'ddm')
%See m1_process.m for an example.
% - calling fn should add prt.ddm_label if you want extra detail in filenames.
% TO GET ALL CONDITIONS IN ONE FILE (but can't trim trials):
% if isequal(currentProcess, 'ddm') %Extract RT data for drift-diffusion modeling (by 3rd-party software)
%      flt_data=filter_data_array({scenario block outcome responsetime},'trials',2); %extract block=trials
%      ddm_format_rt({flt_data{1} flt_data{3} flt_data{4}},prt); %extracts, formats, and writes RT data file.
% end %if ddm process
%
% TO GET EACH CONDITION IN SEPARATE FILE (or to use trim trials):
% case 'ddm'
%     prt.ddm_label=prt.label %add run-label to output rt file.
%     %Extract RT data for drift-diffusion modeling (by 3rd-party software)
%     flt_data=filter_data_array({scenario block outcome responsetime},'trials',2); %extract block=trials
%     flt_data=filter_data_array({flt_data{1} flt_data{3} flt_data{4}},prt.scenario,1); %extract scenario=baseline/consbrate
%     % size(flt_data{2}) %Uncomment to check that you've grabed the right trials
%
%     tr_range=[]; %pass all trials for processing.
%     %tr_range=1:15; %pass specified trials only (230=num trials in UTD study).
%     if ~isempty(tr_range)
%         disp('Warning - not using all trials.')%turn this off if you don't want to see it.
%         for ct=1:length(flt_data)
%             flt_data{ct}=flt_data{ct}(tr_range);
%         end
%     end
%     ddm_format_rt(flt_data,prt); %extracts, formats, and writes RT data file.
%
%% To do:
% Implement that coding alternative to correct/incorrect
% ?Deal with a second codition column (fast-ddm accepts stimuli & blocks).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global datafile_suffix %always='.dat', set by calling EXP_process m-file.


fnamesuffix='.rt'; %output files will be named .rt
rt_dir='ddm_rt_files/'; %directory to which to write outfiles (w/in EXPT_process scripts current directory, eg EPXT/DATA)

[rows cols]=size(data);
if cols==2
    outcome=data{1};
    responsetime=data{2};
elseif cols==3
    condition=data{1};
    outcome=data{2};
    responsetime=data{3};
    conds=unique(condition,'stable'); %get list of all condition strings (unsorted)
    coded_condition=ones(size(condition))*NaN;
    for cct=1:length(conds) %recode condition strings to integers, required by fast-dm.
        coded_condition(strcmp(condition,conds(cct)))=cct;
    end
else %crash
    disp('DATA format not recognized by ddm_format_rt.m')
    size(data)
end %if

%create RT filter for later use
minrtflt=responsetime>=prt.minimumRT; %make filter to exclude <min RTs
maxrtflt=responsetime<=prt.maximumRT; %make filter to exclude >max RTs
rt_flt=logical(minrtflt.*maxrtflt); %put the filters together

%convert RT from ms to seconds, required by fast-dm.
responsetime=responsetime/1000;

%recode outcome strings to integers, required by fast-dm.
coded_outcome=ones(size(outcome));
FAs=~strcmp(outcome,'FA');
MDs=~strcmp(outcome,'MD');
incorrects=FAs&MDs;
coded_outcome=coded_outcome&incorrects;
% [coded_outcome FAs MDs] %uncomment to check

%create output data matrix, excluding bad RTs
if cols==2
    dataout=[coded_outcome(rt_flt) responsetime(rt_flt)];
elseif cols==3
    dataout=[coded_condition(rt_flt) coded_outcome(rt_flt) responsetime(rt_flt)];
end

%create the output file name and write data to disk
dotdat=strfind(prt.filename,datafile_suffix);
if sum(strcmp(fields(prt),'ddm_label'))>0
    fname=strcat([rt_dir prt.filename(1:dotdat-1),'_',prt.ddm_label,fnamesuffix]);
else
    fname=strcat([rt_dir prt.filename(1:dotdat-1),fnamesuffix]);
end
dlmwrite(fname,dataout,'\t') %dlm uses more appropriate number formatting than save, easier than fprint.
end