function satoolbox(action)
%satoolbox A help-file entry point into the Signals Approach Toolbox.
% 
%The Signals Approach Toolbox (SAtoolbox,satb) is collection of m-files for
%contructing a behavioral experiments in a utility-based signal detection
%theory framework.
% 
%SATB uses Matlab and Psychtoolbox.
% 
%doc satb_readme  %<--- Triple-click and press ENTER for more info.
% 
%Also try:
%satoolbox('action')
%where action =
%     help = show the satb_readme file.
%     where = display path to satb folder.
%     functions = display listing of all satoolbox sub-directories.
%%%%%%%%%%%%%%%%%%%%%%


if nargin==0
    action='undefined';
end

[fname satbRootPath]=setdir(mfilename); %Get name of the currently running function, set current directory


switch action
    case {'help' 'readme' 'about'}
        doc satb_readme
        
    case 'functions'
       %List contents of each satoolbox sub-directories
       disp(strcat(['Path to ' fname ' is' satbRootPath '.']))
       help dataprocessing
       help dev
       help modeling
       help depricated
       help examples
       help runexpt
       help utilities
        
    case {'root' 'where'} %See also: PsychtoolboxRoot
        satbRootPath
        
    case {'edit' 'notes'}
        edit satb_readme
        
    case 'undefined'
        help satoolbox
        
    otherwise
        disp('ACTION not recognized in fn satoolbox.')
end%switch
end %main

