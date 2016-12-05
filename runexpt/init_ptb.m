
function init_ptb(hideflag,waitflag,rgbTriplet,moreparams)
%Quick & easy fn to get PTB ready to go
global w wRect bkgndColor screenNumber
black=[0 0 0];%screen background color
white=[255 255 255];%screen background color
gray=[45 45 45];%screen background color

if hideflag;HideCursor;end

AssertOpenGL; % check for opengl compatability

maxScreen=max(Screen('Screens'));
try
    if moreparams.screenNumber<=maxScreen %check that any requested screen number exists.
        screenNumber=moreparams.screenNumber;
    else
        screenNumber=maxScreen; %Starts at screen 0; get highests screen #, will draw to that (ie,2nd monitor if avail).
    end
catch screenerr%if no specific screen requested
    screenerr
    screenNumber=maxScreen; %Starts at screen 0; get highests screen #, will draw to that (ie,2nd monitor if avail).
end

if nargin==2
    bkgndColor=black;
else
    bkgndColor=rgbTriplet;
end

% if nargin<4;stereomode=0;end
try 
   stereomode=moreparams.stereomode;
catch
    stereomode=0;
end

% 10/6/10 trying to move stereo split more medial
% localrect=Screen('Rect', screenNumber)
% [left top right bottom]=deal(localrect(1), localrect(2), localrect(3), localrect(4));
% [w, wRect]=Screen('OpenWindow',screenNumber, bkgndColor,[left+.1*right top right-.1*right bottom],32,2,stereomode);

[w, wRect]=Screen('OpenWindow',screenNumber, bkgndColor,[],32,2,stereomode);
Priority(MaxPriority(w));% set priority - must be set after Screen init
black=255;

Screen_Flip_Interval=Screen('GetFlipInterval', w)

if waitflag
    line1=70;
    nextline=30;
    Screen('TextSize', w, 24);
    Screen('TextFont',w, 'Arial');
    Screen('DrawText', w, 'Ready.', 10, line1, black);
    Screen('DrawText', w, 'Press space-bar to begin.', 10, (line1+5*nextline), black);
    Screen('Flip', w); %show text
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while KeyCode(KbName('space'))==0 % loop until valid key is pressed
        [KeyIsDown, endrt, KeyCode]=KbCheck; %check for key presses
        WaitSecs(0.001); % Wait 1 ms before checking the keyboard again to prevent overload of the machine at elevated Priority()
    end %while key not pressed
    Screen('Flip', w); %show empty screen
    WaitSecs(0.100); % aestheitic wait before starting
end
end %fn