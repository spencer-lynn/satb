function extract=db_extract(mydata,op_column,res)
% SAtb function: db_extract
% Written to perform a database extraction: subsample of x-range values out of a high-res model.
% For example, want to get data for every 0.1 in x-range, from a model with x-range steps of 0.02.
% 
% Useage: extract=db_extract(mydata,op_column,res)
% 
% Where:
%     - data=matrix (2d) of data
%     - op_column = column number in data over which to extract
%     - res = desiered x-range resolution (eg, 0.1)
% 
% Change log:
% 11/7/12 - started.
% 
% To do:
% - if given a text file as mydata, write extract to disk.
%
%
%%%%%%%%%%%%%%



xt=mydata(:,op_column); %grab the x-range column
xt=rem(xt,res); %overwrite with remainder of divsion that yeilds 0 is target rows.
%[mydata(:,op_column) xt] %Uncomment to view
xt=~xt; %created logical array of the inverse, to mark target rows


co=size(mydata,2); %Get number of columns in mydata
extract=ones(sum(xt),co)*NaN; %init extract variable
for ct=1:co %for each column of data
    extract(:,ct)=mydata(xt,ct);
end
