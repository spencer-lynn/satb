function s=waitSOA(soa,variableflag)
% SAtb fn: waitSOA -- Wait (optionally variable) stimulus onset asynchrony, time IN SECONDS
%Use variableflag=1 for variable SOA, soa=[duration1,duration2,...] selected randomly at each fn call.
% 
% Change log:
% 1/2/13 - Return value of the selected duration.
% 
% To do:
% %Eventually code this to pick random interval given distribution paramters.


try
    if variableflag==0 %do not use a variable SOA, just constant SOAs
        s=mean(soa);
    else if variableflag == 1 %use a variable SOA
            r=randperm(length(soa)); %Randomly reorder indices into soa.
            s=soa(r(1));  %Will use first reordered SOA as current SOA
        else
            disp('Invalid variableflag sent to waitSOA.')
            soa
            variableflag
        end
    end
    WaitSecs(s); %Do the wait.
    
catch % if error above, clean up and hint at error
    cleanup
    psychrethrow(psychlasterror);
end % try ... catch %
end % FN
