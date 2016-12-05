function dataout=import_data(inputfile)
% Create workable structure-based database from input ASCII file.
% Aligns headers, text-data, and numerica data into data structures appended to input file struct.
dataout=importdata(inputfile); %importdata is a builtin ML fn
headers=dataout.textdata(1,:); %define column headers as first row of file
for i=1:(size(dataout.textdata,2)) %for num cols in textdata portion, convert each column to a sub-structure (makes text-data useable in ML)
    dataout.(strtrim(headers{i}))=dataout.textdata(2:end,i); %append new structs for each input col and put the data in the struct
end

hcol=size(dataout.textdata,2)-size(dataout.data,2); %determine how many text-data columns there are.
for i=1:(size(dataout.data,2)) %for each col of numerica data...
    dataout.(strtrim(headers{hcol+i}))=dataout.data(:,i); %...append new structs for each input col and put the data in the struct
end
% dataout
end %fn