
function user_init_scripts(fid,subjectID)
%user_init_scripts can contain code that is run prior to initializing the
%PsychToolbox Screen. If a file called "user_init_scripts.m" is in the
%Matlab path (eg in the main experimental directory), it will be run 
%(it is called by satb's initializers.m script).

global ra

%ra=get_ra_initials
%askquestions(fid,subjectID)
end


function ra_inits=get_ra_initials
ra_inits=input('Input RAs initials, in lower case, contained by single-quotes:');
end



function askquestions(fid,subjectID) 
%askquestions(datafilepointer,subjectID) %query subject for basic info.
%Eventually put this in to a gui control window
%or use smthg like: reply=Ask(w,'Who are you?',[255 255 255],[],'GetEchoString');
%set pos/neg response keys here, too, w/KbName(input(...))

colnames='\t \t Block \t Subject ID \t Group \t Date \t Age \t Gender \t Note \tHandedness \n'; %column names for subject infos in datafile
blocktag='Subject information';

age=input('Input subject age (years):');
gender=input('Input subject gender (male,female):','s');
hand=input('Input subject handedness (left,right):','s');
group=input('Input experimental group (pilot, control, patient):','s');
note=input('Brief note:','s');

datastring=strcat('\t\t',blocktag,'\t',subjectID,'\t',group,'\t',date,'\t',num2str(age),'\t',gender,'\t',hand,'\t',note,'\n\n');
fprintf(fid,colnames); %Write column headings
fprintf(fid,datastring); %Write subject infos
end
