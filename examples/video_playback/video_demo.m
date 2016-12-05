function video_demo
% March 12 2014 
% Use PsychToolbox (PTB) to show video in Matlab. 
% PTB uses GStreamer to support audio/video playback. 
% Once you have PsychToolbox installed, type 'help GStreamer' for more info.
% 
% The current loadmovie and flipmovieframes functions were written before 
% PTB switched from QuickTime to GStreamer and haven't been tested under GStreamer.
% 
% This code makes calls to init_ptb and flipmovieframes, from SAtoolbox.
% 
% Contact Spencer with any questions: spencer.lynn@gmail.com.

[exptName mypath]=setdir(mfilename); %Get name of the currently running function, set current directory
path_to_movie='neutral1.mov'; % 'neutral1.mov'; %without a full path, the movie must be in the current Matlab directory.
init_ptb(1,1,[0 0 0]);
loadmovie(path_to_movie)
clear screen %kill psych-toolbox screen control.
end %fn movie_demo

function loadmovie(moviename)
%This modified from SATB fn load_movie.m.

global w %window pointer, returned by init_ptb
msize=100; %Percent of origianl movie's horizontal and vertical size to scale the movie by. Not working on Mac?

%Can take a few sec to get movie going, so "please wait" 
mytext='Please wait...';
[x,y] = positiontext(mytext,{'.5*right'},{'.5*bottom'});
DrawFormattedText(w, mytext, x, y,[],50);
Screen('Flip', w); 

%Load the movie, set playback parameters.
rate=1; %0=stop, neg=review
looped=0; %0=do not loop playback
soundlevel=1; %0.00-1.00 in percent
soundstep=.1; %min step possible = 0.01.
[movie movieduration fps imgw imgh] = Screen('OpenMovie', w, moviename);
mRect=[0   0  imgw imgh]; %Use this for windows (left top right bottom)
% mRect=[0 imgh imgw  0  ]; %For a Mac, need to have items in different order...not sure what yet
mRect=ScaleRect(mRect,msize/100,msize/100);
mRect=CenterRect(mRect,wRect);
%fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n',moviename, movieduration, fps, imgw, imgh); %print details to commandwindow.
Screen('SetMovieTimeIndex', movie, 0);% Seek to start of movie (timeindex 0)

%Play the movie.
Screen('PlayMovie', movie, rate, looped, soundlevel);% Start playback: start the realtime playback clock and playback of audio tracks, if any.
flipmovieframes(movie,rate,looped,soundlevel,w,mRect); %This fn written by Spencer

%Here control goes back to calling function, which can flip to a new stimulus, or whatever.
end %fn play_movie

