function load_image(trial_info)
%Change Log:
% 20150931 added deal of wRect into bottom, etc.


global stimfolder wRect 
global conditions %struct of current exptl condditions, defined in main expt script, available for use by 'x' fns

[left top right bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %used by case=t, also can be called in list-files.

% case 'i' %load an image
        stimfilename=strcat(stimfolder,char(trial_info.Stimulus)); % suss stim file name
        imdata=imread(char(stimfilename)); %load image file
        tex=Screen('MakeTexture', trial_info.wptr, imdata); %make texture of image w/reference to main window, w
        tRect=Screen('Rect', tex); %gets rect dimention of image
        %Type "Screen Drawtexture?" and "help PsychRects" for more info.
        %For images, size(trial) (the list-file's SIZE field) is scale of
        %image in percent. x,y are left and top corner coordinates, respectively
        %Rect coords = [left top right bottom]
        tRect=ScaleRect(tRect,trial_info.Size/100,trial_info.Size/100);
        filterMode = 1; %choices=0 or 1. How to compute the pixel color values when the texture is drawn magnified, minified

        %Center the image, regardless, in case needed.
        imrect=CenterRect(tRect, wRect); %if x coord specified in list-file (well, stiminfo) ="center" then display images in center of screen.
%         wRect might need to be sussed from trial_info.wptr
        [ileft itop iright ibottom]=deal(imrect(1), imrect(2), imrect(3), imrect(4)); %might have top/bottom inverted?

        if strcmp(trial_info.x,'center')
            ileft=imrect(1);
            iright=imrect(3);
        else
            ileft=eval(char(trial_info.x));
            iright=eval(char(trial_info.x))+RectWidth(tRect);
        end

        if strcmp(trial_info.y,'center')
            itop=imrect(2);
            ibottom=imrect(4);
        else
            itop=eval(char(trial_info.y));
            ibottom=eval(char(trial_info.y))+RectHeight(tRect);
        end
        Screen('DrawTexture', trial_info.wptr, tex, [],[ileft itop iright ibottom],[], filterMode,[]); %draw image to backbuffer

end