function ptb_imagecapture(targetfolder, process)
% Capture and process/save a PsycToolbox Screen, where:
%   targetfolder = path to folder of images
%   process = 'save' -- save a screen capture
%             'contrast' -- determin RMS contrast an image
%BY
% Spencer K. Lynn, spencer.lynn@gmail.com
% 
%FUNCTION
% Developed to do processing on Alpha composited images for Army2 study.
% To use for different experiment, will need to add stim-presentation code
% custom to that experiment at bottom of this script.
% 
%VERSION
% 3/8/12, update 3/9/12.1
%
%USES
% -Signals Approach Toolbox v3
% -Psychophysics Toolbox v3
%
%%%%%%%%%%
global w %created by init_ptb
global bufferID border crect imgfile_suffix fillcolor blendalpha scrcap_buffername%from army2 fns

cd(targetfolder)

switch process %pre-processing setups
    case 'save'
        army2_setup %should call init_ptb and create any variables needed to create stims.
        folder_contents=dir(strcat('*',imgfile_suffix));
        scr_cap_files=cell(numel(folder_contents),1);
        save_fmt='png'; %format in which to save screen captures
        
    case 'contrast'
        imgfile_suffix='jpg';
        folder_contents=dir(strcat('*.',imgfile_suffix));
        contrast_values=ones(numel(folder_contents),1)*NaN;
        delimiter='%i,';
        fid = fopen(strcat([' RMScontrast_values.csv']),'wt'); %open file in disk to write processed data
        fprintf(fid,'%s\n','File,RMS_contrast');
        
    otherwise
        disp('Requested process not recognized in ptb_imagecapture.m')
end


for fctr=1:numel(folder_contents) %each file in target directory
    imgName=folder_contents(fctr).name;
    stimfilename=strcat(targetfolder,'/',imgName); % suss stim file name
    switch process
        case 'contrast'
            fprintf(fid,'%s,',imgName);  %Name followed by comma-delimiter
            contrast_values(fctr)=rmsc(stimfilename);
            fprintf(fid,delimiter,contrast_values(fctr)); %write measure to file
            fprintf(fid,'\n');
            
        case 'save'
            %Use expt's methods of creating, loading the stims
            loadbuffer(bufferID,stimfilename,fillcolor,border,blendalpha); %copied from Army2.m
            Screen('Flip', w);% Show image on monitor. SET startrt
            imageArray=Screen('GetImage', w, crect, [],[],[]); %capture (part of) a PTB Screen. See notes.
            scr_cap_files{fctr}=strcat(stimfilename(1:numel(stimfilename)-4),'_scrcap','.',save_fmt); %trim suffix from image name, then save
            imwrite(imageArray,scr_cap_files{fctr},save_fmt) %save the screen-cap to disk.
            
        otherwise
            disp('Requested process not recognized in ptb_imagecapture.m')
    end %switch processes
end %each file
cleanup


switch process %post-processing
    case 'save'
        [scr_cap_files]
    case 'contrast'     
        contrast_values
        fclose('all'); %close all open files
    otherwise
        disp('Requested process not recognized in ptb_imagecapture.m')
end
end %fn

function rms_contrast=rmsc(stimfilename)
image_array=imread(stimfilename);
    if size(image_array,3)==3 % 3d=RGB, so discard color
        image_array = rgb2gray(image_array);
    end
image_array=im2double(image_array);% make UINT->double and re-range to 0-1 from 0-255.
image_array=image_array(:); %vectorize
m=mean(image_array); %mean
diff2=(image_array-m).^2; %square of each difference element
rms_contrast=sqrt(sum(diff2)/numel(image_array));
% rms_contrast=norm(image_array-m)/sqrt(numel(image_array)); %norm(x) also works

end


%% Army2.m functions
function army2_setup %PTB settings for Army2 expt
global w wRect bkgndColor screenNumber %created by init_ptb
global bufferID border imgfile_suffix fillcolor blendalpha scrcap_buffername
scrcap_buffername='frontLeftBuffer'; %needed by Scree-GetImage since Army2 uses split-screen steromode.
moreparams.stereomode=4; %4=stereo,0=mono; help StereoDemo
moreparams.screenNumber=1;
bkgnd_color=[0 0 0];
init_ptb(1,0,bkgnd_color,moreparams); %Start PsychToolBox. flags=hidecursor,pause. Pause=0 since setting a custom "ready" screen below.
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %set blend fn for transparency effect
bufferID=0; %we'll put all images on left side of split-screen
border=0; %Army2 uses 30px gray border surrounds each image. We set that to zero so we can get rect of image only, later.
fillcolor=GrayIndex(screenNumber); % get (as default) mean gray value of screen (doesn't update view)
blendalpha=0.1; %default used in Army2
imgfile_suffix='.jpg';
end

function loadbuffer(buffer,stimfilename,fillcolor,border,blendalpha)
global w wRect
global crect %needed for screen capture
Screen('SelectStereoDrawBuffer', w, buffer);
imdata=imread(stimfilename); %load image file
tex=Screen('MakeTexture', w, imdata); %make texture of image w/reference to main window, w
tRect=Screen('Rect',tex); %get size of tex (ie, image)
tRect(3)=tRect(3)+border; %prep grey border around image
tRect(4)=tRect(4)+border;
crect=CenterRect(tRect,wRect); %center the border (assuming image is drawn centered)
Screen('FillRect',w,fillcolor,crect); %draw the border, might need to be a texture?
Screen('DrawTexture', w, tex,[],[],[],[],blendalpha) %draw image, transparancy over bkgnd set by blendalpha
end
