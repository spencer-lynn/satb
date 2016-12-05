function dataout=read_list(pathtofile,params)
%SAtb fn: read_list -- Read in a list file, transpose to rows, randomize order if needed.
% List file must be tab-delimited with 1 header row.
% You can pass an optional struct, with the following fields:
%     params.rnd = true will randomize the order of rows.
%     params.transpose = false will leave dataout in column orientation
%     params.transpose = true will transpose dataout to row orientation (this is also default behavior, no params required).
% Output is a struture, with field names = column names and records = rows. Accessed as dataout(record#).FieldName
%
%Change log:
% 2/7/11 - Forked from original readstim.m:
% - uses flexible importdata() rather than brittle textscan
% - New row-based format for dataout.
% - Parameritized add'l vars.
% 8/28/15 - In nargin=2 block, switched transposition to come before randomization...otherwise randomization wasn't working.

% Uncomment to test:
% if nargin==0
%     pathtofile='/Users/spencer/Coding/Matlabber/my_m-files/SAlab/experiments/body_and_food/bf1_program/lists/trials_list.txt';
%     params.rnd=true;
%      %might need to paste a part into the ELSE block below to get it to run in this demo.
% end

% pathtofile %uncommment to check.

dataout=importdata(pathtofile,'\t',1); %importdata is a builtin ML fn, creates a struct with two parts: .data and .textdata

headers=dataout.textdata(1,:); %First row of .textdata is column header line. Separated that from data rows.
for i=1:(size(dataout.textdata,2))
    dataout.(strtrim(headers{i}))=dataout.textdata(2:end,i); %Create new fields, named with column headers, containing data rows.
end

hcol=size(dataout.textdata,2)-size(dataout.data,2); %Get difference in #cols betw text and numerica data.
for i=1:(size(dataout.data,2)) %For each col of numerica data...
    dataout.(strtrim(headers{hcol+i}))=dataout.data(:,i); %Transfer numeric data into fields.
end

dataout=rmfield(dataout, {'data' 'textdata'}); %Remove the original data fields.

if nargin==2 %a structure of additional parameters has been passed in
    try
        %Skip transposition
        if params.transpose==false
            %Don't transpose structure to row orientation.
        end
    catch %If .transpose is not provided or is true.
        params.transpose=true;
        dataout=transpose_struct_table(dataout,'make_rows');
    end
    
    try
        %Randomize order of stimulus list to produce order of trials
        if params.rnd==true %randomize the stimulus order
            randomorder=randperm(numel(dataout));
            dataout=dataout(randomorder);
        end
    catch myerr
        myerr.message
    end
    
    %Do string to number conversions of particular columns
    %     for i=1:size(dataout.LineNo,1)
    %         dataout.Size(i)={str2double(dataout.Size{i})};
    %     end
    
else
    %Default behavior
    dataout=transpose_struct_table(dataout,'make_rows');
end %if add'l params
end %fn


