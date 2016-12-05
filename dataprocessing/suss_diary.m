function data=suss_diary(target,infos,conditions)
% SAtb fn suss_diary: Use regular expressions and string comparisions 
% to retrieve information from an SATB experiment's diary files.
%
% Where:
% TARGET is a string variable representing a path/filename or just a path/.
% For TARGET = path/filename (a path ending in a specfic diary file name):
% - call this fn separately for each info-type/process you'd like data on.
% - the output is returned to the calling function as a cell, data. 
% For TARGET = path/ (a path to a directory containing diary files):
% - path should end with '/'.
% - Call this fn once to process all the files in sequence.
% - Output is written to a csv file in the target directory.
% 
% INFOS = a cell of strings indicating the information to retrieve from the diary.
% - Current options are: {'duration' 'yesbtn' 'valence' 'generic'}.
% - If TARGET = a single file, call this fn with one option at a time.
% - If TARGET = a directory, you can call this fn with more than one option at a time.
%   'duration' = time in minutes of the experiment run
%   'yesbtn'   = location of the YES or S+ response label
%   'valence'  = valence condition (specific to some expts, eg, SB5).
%   'generic'  = a method to return a string from the diary for any specifiable condition (such as valence).
%                - Requires a .sstr (search string) field defined in the CONDITIONS input struct.
%                - This process only works for TARGET=single file, not directory.
% 
% CONDITIONS = optional input param to given extra information to this fn when needed.
%            - For example, passing conditions.sstr is used by the 'generic' process.
%
% CHANGE LOG
% 12/22/14 - Started as "suss_diary_regexp.m".
% 11/14/15 - Combined with (older?) "suss_diary.m"
%          - added various calling and output complexities.
% 20160302 - fixed error that crashed on to cell() for many files.
% 
%% %%%%%%%%%%%%%%%%%%%

multifile_flag=isdir(target); %Check if TARGET is a single file or a directory of files.
if multifile_flag %then TARGET is a directory containing diary files and we'll write the data from all those files to an output file
    path_to_diaries=target;
    diarylist=dir(strcat(path_to_diaries,'*diary.txt')); %For OTD study, diary files are named as: 'otd_245_b_diary.txt'
    numSubjects=length(diarylist);
    fid = fopen(strcat(path_to_diaries,'_diary_data.csv'),'wt'); %open file on disk to write processed data
    fprintf(fid,'%s\n',''); %Write empty line at top of output file (will later hold data column names)
else %TARGET is a path/filename and we'll pass that files's data back to calling function.
    numSubjects=1;
    diaryfile=target;
end
data=cell(numSubjects,1);

for ct=1:numSubjects
    if multifile_flag
        columnheadings='Filename'; %accrete col headers listing
        fprintf(fid,'%s,',diarylist(ct).name); %write current filename to output data file
        diarylist(ct).name %Uncomment to check/troubleshoot.
        diaryfile=strcat(path_to_diaries,diarylist(ct).name);
    end
    diary=load_diary(diaryfile); %read in the diary file
    
    for process_ct=1:numel(infos)
        process=infos{process_ct};
        switch process
            case 'generic'
                %This is intended to be called during per-ppt processing
                %rathern than to be written to this a suss_diary output file.
                %data=cell(1:numSubjects);
                
                data{ct}=get_generic_string(conditions.sstr,diary);
                
                %For example, if target is an SB5 diary and conditions.sstr='valence:'
                %this will return the diary line containting the ppt's valence condition, eg: 'valence: 'negative''
                %In the calling fn, you can then search this returned line for the options
                %to determine which one the ppt received.
                
            case 'valence'
                %data=cell(1:numSubjects);
                data{ct}=get_valence(diary);
                if multifile_flag
                    columnheadings=strcat(columnheadings,',','Valence'); %accrete col headers listing
                    fprintf(fid,'%s,',data{ct}); %write to output data file
                end
                
            case 'duration'
                data{ct}=get_duration(diary);
                if multifile_flag
                    columnheadings=strcat(columnheadings,',','Duration'); %accrete col headers listing
                    fprintf(fid,'%s,',num2str(data{ct})); %write to output data file
                end
                
            case 'yesbtn'
                data{ct}=get_yesbtn(diary);
                if multifile_flag
                    columnheadings=strcat(columnheadings,',','yesbtn'); %accrete col headers listing
                    fprintf(fid,'%s,',data{ct}); %write to output data file
                end
                
            otherwise
                disp('Info-type not recognized in suss_diary.m')
        end %switch
    end %each process in infos
    if multifile_flag
        columnheadings=strcat(columnheadings,',','EOL'); %accrete col headers listing
        fprintf(fid,'%s\n','end of line'); %newline after current file
    end
end %for each ppt
if multifile_flag
    fprintf(fid,'%s\n',columnheadings); %Write names for data columns as last row in file. Not ideal method, and colheads depend on success of final subject
    fclose(fid); %close output file
end
end %fn


%% case fns
function txt=get_generic_string(sstr,diary)
%For generic retrieve of a hit from within diary
% - txt contains the found paragraph diary
% - so, then, in the calling fn search within that txt to locate the specific values of interest.
% - See get_valence, below, for example code for that.
txt=diary{strncmp(sstr,diary,numel(sstr))}; %Return entire paragraph/row containing search string
end

function valence=get_valence(diary)
%This example is hard-coded for SB5 experiment valence condition {neutral or negative}.
%For more generic use, have suss_diary return the found paragraph txt from
%diary and then search within that in the calling fn to locate the
%condition.

sstr='valence: ''neutral';
neu_hit=sum(strncmp(sstr,diary,numel(sstr)));

sstr='valence: ''negative';
neg_hit=sum(strncmp(sstr,diary,numel(sstr)));

if neu_hit>0
    valence='neutral';
else
    if neg_hit>0
        valence='negative';
    else
        disp('Condition not idenfitied in suss_diary.m.')
        sstr='valence:';
        txt=diary{strncmp(sstr,diary,numel(sstr))} %Return entire paragraph/row containing search string
    end
end
end

function minutes=get_duration(txt)
regexp1='was \d+ minutes'; %numeric minutes as regexp pattern
s1=regexp(txt,regexp1,'match'); %return the string-pattern found the text, contains the number. s1 is a cell.
minutes=regexp([s1{1:end}],'\d+','match'); %now return just the number extracted from w/in its containing cell. data is a cell.
minutes=str2double(char(minutes{1}));
end

function yesbtn=get_yesbtn(diary)
try
    txt=diary{strmatch('The yesbtn is:',diary)}; %Need the line number (eg, row 38) of cell 1 of the text-import.
    % txt='The yesbtn is: "/?".' %eg, a whole diary file
    % txt='The yesbtn is: "z".' %eg, a whole diary file
    % txt='The yesbtn is: "1".' %eg, a whole diary file
    regexp1='The yesbtn is: "([/\z91])'; %find a /, z, 9, or 1 at given location in string.
    s1=regexp(txt,regexp1,'tokens'); %return the string-pattern found in the text. Token returns just regex in ().
    yesbtn=char(s1{1}); %extract the string from the regexp cell output.
catch myerror
    myerror.message
    yesbtn=NaN; %If no valid yes button, set to NaN.
end %try
end

function diary=load_diary(diaryfile)
formatSpec = '%s%s%[^\n\r]';
delimiter = '¶'; %this shouldn't actually appear in the diary file, so each paragraph will be a row in the
diaryfid = fopen(diaryfile,'r');
diary = textscan(diaryfid,formatSpec,'Delimiter', delimiter,  'ReturnOnError', false);
%Returns diary = {113x1 cell}    {113x1 cell}    {113x1 cell}
%Where cell 1 is the diary file, each row it's own cell array.
%and cells 2,3 are empties.
fclose(diaryfid);
diary=diary{1};
end


