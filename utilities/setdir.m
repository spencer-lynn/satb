function [myfile mypath]=setdir(myfile)
% Set the working directory for an experiment using mfile-name as input
% where myname = mfilename built-in ML fn.
%Any m-files across available paths with duplicate names will be run from this directory rather than some other.

myname=strcat(myfile,'.m'); %Get name of the currently running function, append .m to it.
mypath=which(myname); %Get the directory path of this currently running function.
s=strfind(mypath,myname); %Find the name of the file in the path.
mypath=mypath(1:s-1); %Over write that path, eliminating the file name from the end of it.
cd(mypath); %Set the MatLab working directory to the root path of the currently running m-file.
end