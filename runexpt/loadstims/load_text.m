function load_text(trial_info)
global stimfolder wRect 
global conditions %struct of current exptl condditions, defined in main expt script, available for use by 'x' fns


% case 't' %load a text string

[left top right bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %used by case=t, also can be called in list-files.

        rtmargin=.05*right; %where to wrap long lines of text
        Screen('TextSize', trial_info.wptr, trial_info.Size); %For text, the list-file SIZE field is font size in pts.
        Screen('TextFont',trial_info.wptr, char(trial_info.Font_Name)); %fn can use Font Number, but I've hard-coded for name as text string.
        Screen('TextColor', trial_info.wptr, [trial_info.Red trial_info.Green trial_info.Blue]);
        %Screen('TextStyle', wptr [,style]); %additional unsued text drawing options
        %Screen('TextBackgroundColor', wptr [,colorVector]);
        %Screen('TextMode', windowPtr [,textMode]);

        hmargin=.05*right;
        teststring='The quick brown fox jumped over the lazy dog.'; %45 diff chars, used to find how many chars fill fit on screen at any resolution
        [cnormBoundsRect, coffsetBoundsRect]=Screen('TextBounds', trial_info.wptr, teststring);
        [cleft ctop cright cbottom]=deal(cnormBoundsRect(1), cnormBoundsRect(2), cnormBoundsRect(3), cnormBoundsRect(4));
        max_h_chars=floor((right-2*hmargin)/(cright/45)); %where to wrap long lines of text

        mytext=char(trial_info.Stimulus);
        [x,y] = positiontext(mytext,trial_info.x,trial_info.y);
        %Screen('DrawText', wptr, mytext, x, y);
        DrawFormattedText(trial_info.wptr, mytext, x, y,[],max_h_chars); %strings longer than 255 chars crash here (but not in DrawFormattedTextDemo.m!)
end