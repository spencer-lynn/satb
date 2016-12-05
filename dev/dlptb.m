function dlptb
%Create the target directory where you want PTB installed
%Put PTB's DownloadPsychtoolbox.m file there (downloaded from psychtoolbox.org).
%Fill out info below
%   Hint: to get the path string of the target directory, drag that
%   DownloadPsychtoolbox.m file to the matlab prompt
%Run this script
%
%See also SetUpPsychtoolbox to set up a copied version
%See also UpdatePsychtoolbox to get most recent "beta/current" flavor.

targetdirectory='/Users/spencer/Applications/ML_toolboxes/Psychtoolbox/'
flavor='beta' %  'stable'|'current'=='beta'

cd(targetdirectory);
DownloadPsychtoolbox(flavor,targetdirectory)

end %fn