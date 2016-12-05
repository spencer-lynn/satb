function load_xfn(trial_info)
global stimfolder wRect 
global conditions %struct of current exptl condditions, defined in main expt script, available for use by 'x' fns
[left top right bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %used by case=t, also can be called in list-files.


% case 'x' %custom build to load a more complex stimulus
        %To invoke this case, in the list file, specify a function name (without the ".m"
        % suffix) as "Stimulus" and set "Stimulus Type" to "x" (no quote marks though).
        % For example, this case might call a custom function with instructions to look to
        % additional list file(s) for creation of stimulus elements not
        % possible with other cases (those being limited to one element
        % (stim, drawing, line of text) per row) (thus calling fn loadstim
        % recursively). Or, the m-file might just be hard coded itself to
        % call PsychToolBox routines.
%         The fn can also include parameters 
%         This can be any thing ML can evaluate, not just m-files.

        xfn=char(trial_info.Stimulus);
        eval(xfn) % If "Error: The input character is not valid..." check for " marks in list file xfn
end