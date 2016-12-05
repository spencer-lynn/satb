function fdata=prep_datafiles(fdata)
%SAtb fn: datafile
%   run filename check, open main dat file, start diary log
%
%Change log:
%4/13/11 - uses fdata struct to open dat file
%10/16/12 - added fdata.datafile_middle as extra part optional extra part of file names, with ISFIELD error check.
%1/11/13 - Commented out user_init_script; not sure that's the way to do it.

% Check that: pptID not 'demo' AND file does not already exist
if ~isequal(fdata.participantID,'demo') && fopen(strcat(fdata.path,fdata.fname), 'rt')~=-1 %If name is not demo and file does already exist, quit.
    cleanup
    error('A data file with that name already exits.');
else %otherwise (pptID = 'demo' OR file doesn't exit, so...)
    fdata.fptr = fopen(strcat(fdata.path,fdata.fname),'wt'); % Open ASCII file for writing
%     try
%         user_init_scripts(fdata.fptr,fdata.participantID) %Run this file of user-supplied code if it exists.
%     catch
%         disp('No user_init_scripts run.')
%     end
end

if isfield(fdata,'datafile_middle')
    sessionlog=strcat(fdata.path,fdata.datafile_prefix,fdata.participantID,fdata.datafile_middle,'_diary.txt');
else
    sessionlog=strcat(fdata.path,fdata.datafile_prefix,fdata.participantID,'_diary.txt');
end
diary(sessionlog)
end %prep_datafiles

