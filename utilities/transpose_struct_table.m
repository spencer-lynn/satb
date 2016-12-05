function dataout=transpose_struct_table(mydata,direction)
% satb fn transpose_struct_table
%Convert "Import"-ed text files that are structured as columns of cell arrays into rows ('make_rows') or vice versa ('make_cols').

switch direction
    case 'make_rows'
        colheaders=fieldnames(mydata);
        cols=numel(colheaders);
        rows=numel(mydata.(colheaders{1}));
        for r=1:rows
            for c=1:cols
                
                val=mydata.(colheaders{c})(r);
                %                 if ~isnan(str2double(val)) %Convert values
                %                     val=(str2double(val));
                %                 end
                dataout(r).(colheaders{c})=val;
            end
        end
        
            case 'make_rows'
%                 ...not written yet.
end %switch
dataout=dataout';
end %fn