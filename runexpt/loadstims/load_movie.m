function load_movie(trial_info)
% Change log:
% 2/7/10 - quick pass to make changes for single-line param and new read_stim format. Untested.
% 
% case 'm' %load a movie file
        %This is a cludge: No subject response is readable DURING a movie at present. At end of movie,
        %control is given back to showstim (as with an xfn), waiting for user's response to trial.
        %Eventually, the way to code this will be to call each frame as it's own trial (or write
        %a special procedure for movie trials if showstim incurs too many dropped frames).
        %Code up for key presses, too (pause/resume, response keys, abort, sound up/down)

global stimfolder wRect 
global conditions %struct of current exptl condditions, defined in main expt script, available for use by 'x' fns
[left top right bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %used by case=t, also can be called in list-files.

        %Can take a few sec to get movie going, so
        mytext='Please wait...';
        [x,y] = positiontext(mytext,{'.5*right'},{'.5*bottom'});
        DrawFormattedText(trial_info.wptr, mytext, trial_info.x, trial_info.y,[],50);
        Screen('Flip', trial_info.wptr);
        moviename=strcat(stimfolder,char(trial_info.Stimulus)); % suss stim file name
        msize=trial_info.Size; %Not working on MAC: display size of movie in percent of native size, from listfile's size field.    
        rate=1; %0=stop, neg=review
        looped=0; %0=do not loop playback
        soundlevel=1; %0.00-1.00 in percent
        soundstep=.1; %min step possible = 0.01.
        [movie movieduration fps imgw imgh] = Screen('OpenMovie', trial_info.wptr, moviename);
        mRect=[0   0  imgw imgh]; %Use this for windows (left top right bottom)
      % mRect=[0 imgh imgw  0  ]; %For MAC: need to have items in different order...not sure what yet
        mRect=ScaleRect(mRect,msize/100,msize/100);
        mRect=CenterRect(mRect,wRect);
        %fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', moviename, movieduration, fps, imgw, imgh);
        Screen('SetMovieTimeIndex', movie, 0);% Seek to start of movie (timeindex 0)
        Screen('PlayMovie', movie, rate, looped, soundlevel);% Start playback: start the realtime playback clock and playback of audio tracks, if any.
        flipmovieframes(movie,rate,looped,soundlevel,trial_info.wptr,mRect); %This fn written by Spencer
        %Here control goes back to showstim, which flips to blank screen, so load some instructions on it.
        %s={{2} {'Go to next part ->'} {0} {'t'} {22} {'Arial'} {225} {225} {225} {'(right-width)-.1*right'} {'bottom-.05*bottom'} {NaN} {NaN}};
        %loadstim(1,s);
        mytext='Go to next part ->';
        [x,y] = positiontext(mytext,{'(right-width)-.1*right'},{'bottom-.05*bottom'});
        DrawFormattedText(wptr, mytext, x, y,[],50);
end