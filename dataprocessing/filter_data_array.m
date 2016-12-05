function mydata=filter_data_array(mydata,filter_value,data_column,exflag)
% SATB Function: filter_data_array
% Usage: mydata=filter_data_array(mydata,filter_value,data_column[,exflag])
% 
% Filter a 2d matrix of SATB data (mydata, each column is a cell array) by a given criterion
% (filter_value), where filter_value is to be found in column number 'data_column' of 'mydata'.
% exflag is optional. exflag='exclude' will exclude the matched rows from the returned data.
% 
% Change Log
% 1/26/12 - Added switch to process numerical filter_values (renamed from filter_string).
% 3/5/13 - added extract/exclude flag.
%%%%%%%%%%%%%%%%

%% Uncomment to monitor:
% filter_value
%  mydata
%  mydata{data_column}

switch class(filter_value)
    case 'char'
        logicaltest=logical(strcmp(filter_value,mydata{data_column}));
    case 'double'
        logicaltest=mydata{data_column}==filter_value;
    otherwise
        disp('No procedure for class of filter_value, in filter_data_array.m')
end %switch

try
    %Inside try-block since older calls to this fn won't have this flag.
    if isequal(exflag,'exclude')
     logicaltest=~logicaltest;
    end
end
     

co=size(mydata,2);
for ct=1:co %for each column of data
    mydata{ct}=mydata{ct}(logicaltest);
end
end %% fn