function layout_evaluator(layout_file,cell_index)
%Load multiple elements onto screen from a layout-list file, where:
% - layout_file is a text string of the list file name,
% - (Optional) cell_index is index of [row cols] into layout_file that have values to be evaluated/filled-in with global vars.
%  For example, cell_index=[5 2] will eval the string in the Stimulus column (col 2) of line 5 (row 5) of layout_file,
%  perhaps evaluating the string command: strcat([num2str(conditions.ttlPoints) 'total points earned.']).
%
%Change Log
% 12/6/10 - added global "profile" variable (intended to be a generic struct). (For use by cfs-dating)
% 2/7/11
% - removed global 'profile', as new CFS toolbox is under dev. Use global conditions instead, if needed.
% - updated for new listfile format, read_list, load_stim
% 1/14/13 - put cell_index try stm in if/then to handle when no cell_index is provided.
%
% To do:
% need to replace col# with colName
% For FEEDBACKs, it would be nice to pass layoutinfo rather than do a disk read every time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global listfolder w stimfolder wRect  %standard xfn globals from loadstim.m
global conditions signal_params %other useful globals. Add what ever needs to be called from layout file

stiminfo=read_list(strcat(listfolder,layout_file)); 
fn=fieldnames(stiminfo); %get cell array of user-supplied field names
[stiminfo.wptr]=deal(w); %Deal w pointer into all rows of stiminfo struct (creating wptr if necc).

if nargin>1
    try
        for i=1:size(cell_index,1) %number items needing to be changed
            myrow=cell_index(i,1);
            mycol=cell_index(i,2);
            
            %uncomment to see results of [row,col] evaluation:
            %        stiminfo(myrow).(fn{mycol})
            %        eval(char(stiminfo(myrow).(fn{mycol})))
            
            stiminfo(myrow).(fn{mycol})=eval(char(stiminfo(myrow).(fn{mycol}))); %replace stimulus with evaluated text string containing cmds,vars
        end
    catch LayoutError
        disp(strcat(['Error evaluating element ', num2str(myrow),' in layout_evaluator.']))
        LayoutError.message
    end
end

%Draw screen elements
nelements=length(stiminfo);
for element=1:nelements
    load_stim(stiminfo(element)) %load trial's on-screen components to Screen's back-buffer
end %for-loop for drawing all elements in list file

end %fn
