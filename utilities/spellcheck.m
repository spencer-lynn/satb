function spellcheck(word,Options)
% Signals Approach Toolbox utility function
% 
% SPELLCHECK(word,Options): Looks for text string WORD in cell array of strings OPTIONS.
% 
% Useage: spellcheck(word,options)
%         where...
%         - word = text string or other element to compare
%         - Options = cell array of legal alternatives
% 
% Change Log:
% 1/16/13 - Made error output more informative.

if sum(strcmp(word,Options)) == 0 %no match
    fprintf('%s\n%s\n','',''); %display info in cmd-window, preceded by a new-line.
    warning(strcat(['Option ',word,' not recognized.']))
    Options
    cleanup %an satb fn to abort PTB and quit the experiment.
    error('Check spelling and try again.')
end

end