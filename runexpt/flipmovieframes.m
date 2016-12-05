function flipmovieframes(movie, rate, looped, soundlevel, w,  mRect)
%Called by loadstim
%Adapted from PTB demo PlayMoviesDemoOSX(moviename)

endmovie=0;
[tex pts] = Screen('GetMovieImage', w, movie, 1); %get first frame for size (no longer used)
% tex = either the texture handle, zero if no new frame is ready yet, -1 for EOF.
% pts = Presentation timestamp in seconds.


while endmovie==0 % Infinite playback loop: Fetch video frames and display them...
    if tex>=1  % Valid texture returned, ie, not end of file or error?
        %In fully featured SATB routine, pass tex to loadstim here
        Screen('DrawTexture', w, tex,[],mRect);% Draw the new texture to backbuffer (in WIN works to resize)
        Screen('Flip', w); % Update display. In full SATB, let showstim do this
        Screen('Close', tex);% Release memory used by tex.
        [tex pts] = Screen('GetMovieImage', w, movie, 1);% Return next frame in movie, in sync with current playback time and sound.

    else %EOF
        endmovie=1;
    end
end
Screen('PlayMovie', movie, 0); %Stop playback
Screen('CloseMovie', movie); %close movie
end
