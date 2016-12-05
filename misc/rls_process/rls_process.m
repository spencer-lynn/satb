function rls_process
% In ML, CD to study's main directory. This script expects txt files in data/rls_data.
% Process E-Prime txt data files from the Running Span task.
% - Expects a log file of a ppt's eprime run.
% - Each row is labeled with a header
% - Can't figure out the native row delimiters, so:
% Open mutiple eprime txt output files (not the edat2 files) in
% TextWrangler, then run the
% "Convert RLS file" automator workflow, which uses TextWrangler to edit 
% text-encoding (to Unicode 8) and EOF (Unix LF).
% 
%   = OLD procedure
% - Convert to rtf (with TextEdit) by hand, which gives /n end-of-line character. 
% - then convert back to txt.
% - Do this on MacOS X Lion, cmd-t, close, open, cmd-t, close: does the conversion and renames all at once.
%
%Spencer Lynn, spencer.lynn@gmail.com
%
%Change Log
% 1/18/12  -  Created for UTD study. Adapted on my ASI script ecommerce_receipts.m. Removed loop for fileformat types.
% 10/23/13 - Generalized to work with other studies, live in SAtoolbox.
% 10/23/13 - Made a cludgy fix to get session#.
%
%TO DO:
% - Haven't been able to read the native eprime txt file. I think the paragraph delimiter is not CR, CR/LF, FF, etc. Can get fileread to work, but nothing else.
%%%%%

% CD to rls_data if not there already. Will crash if not at least in expt's main directory with /data/rls_data/.
mypath=cd;
if ~isequal('rls_data',mypath(end-7:end))
    cd('data/ rls_data'); %Set the MatLab working directory to the rls_data folder.
end

fileformats={'.txt' '.rtf'};
fileformat='.txt';
delimiter=':'; %need a space after the colon, but won't stick.

fid = fopen(' rls_processed.dat','wt'); %open file on disk to write processed data
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','PptID','Experiment','Session','Date','Time','RunSpanScore','RunSpanTotal','File'); %Write colheaders to disk

%Define data headers of interest within the text file.
headers={'Subject'...
    'Experiment'...
    'Session'...
    'SessionDate'...
    'SessionTime'...
    'RunSpanScore'...
    'RunSpanTotal'};


d=dir(strcat('*',fileformat)); %get list of all data files in directory
numfiles=length(d);

for n=1:numfiles
    filename=d(n).name
    datafid=fopen(filename);
    data.txt=textscan(datafid,'%[^\n]'); %load data file as cell array matrix. format='%[^\n]' because '%s' stops at space-characters

    fclose(datafid);
    
    %data.txt{1} %uncomment to check
        
    for h=1:numel(headers)
        %headers(h) %uncomment to check.
        ind=strmatch(headers{h},data.txt{1}); %ind=index into data for target data row.
        if h==3;ind=ind(4);end %fix for not finding "session" correctly.
        try
            msg=data.txt{1}{ind}; %get the row contents
        catch
            msg=': Error, check data file.' %Add error note if header element is missing/unreadable.
        end
        delim_loc=findstr(msg,delimiter); %find the delimiter location
        switch fileformat
            case '.txt'
                data.(headers{h})=msg(delim_loc+2:numel(msg)); %Creat new field and put result into it. +2 to captures the space after the delimiter.
            case '.rtf' %has a '/' following each msg; trim that off.
                data.(headers{h})=msg(delim_loc+2:numel(msg)-1); %Creat new field and put result into it.
        end
        fprintf(fid,'%s\t',data.(headers{h})); %Write data to disk

    end %for each row
    %data %uncomment to check
    fprintf(fid,'%s\t',filename); %Write data to disk
    fprintf(fid,'%s\n',''); %Write new line at end of person
end %for each person
fclose('all'); %close all open files
end %fn


