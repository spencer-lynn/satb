function attn_beep(intensity)
% Play hardcoded beep sound.
% Uses Psychtoolbox functions: MakeBeep, PsychPortAudio

frequency=1024*3;
duration=.3;
repetitions=1;
attnBeep=intensity*MakeBeep(frequency,duration);

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle = PsychPortAudio('Open', [], [], 0, frequency, 1);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle, attnBeep);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1);

% Stop playback:
WaitSecs(duration)
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);

end %fn

