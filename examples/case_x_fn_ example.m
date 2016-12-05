function case_x_example
global w stimfolder wRect xtrial xstiminfo 
%In real fn you'd likely need access to one or more of these globals.
%Other params (eg font) could be read from a list file.

Screen('TextSize', w, 32);
Screen('TextFont',w, 'Arial');
Screen('TextColor', w, [255 50 255]);
mytext='Stimulus type x';
Screen('DrawText', w, mytext, 20, 20);

end