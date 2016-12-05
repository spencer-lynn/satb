To update my existing load_stim mechanism....
- load_stim does the call to Screen('DrawTexture',...), which goes too far
- load_stim is called by show_stim, so will need a new show_stim or amend with if stmt
    that called Screen('DrawTexture',...)
- make new mfile, load_tex to return a struct of everything needed by Screen('DrawTexture',...)
    - ie, the tex itself but also the rect info, etc. 



This code below, from old fetchsignal does preloading, does preloading but not in an efficient way

%Preload stimuli into offscreen windows. 
% This would be faster if bypassed my loadstim to use Textures instead of Off-screen Windows 
%   but loadstim lets you do some fancy stuff (adjust position, size, etc).

[oswptr(1) osrect]=Screen('OpenOffScreenWindow',w,bkgndColor); %Open offscreen window for loadstim to draw into.

loadstim(stimnum,stimulus_list,oswptr(1)) %Load the target stimulus to backbuffer

if useForwardMask
    [oswptr(2) osrect]=Screen('OpenOffScreenWindow',w,bkgndColor); %create addl window for mask
    loadstim(1,stimulus_list,oswptr(2)) %forward/backward mask = neutral face of current set
    Screen('CopyWindow', oswptr(2), w); %copy preloaded stim to open window's backbuffer
    fVBLTime=Screen('Flip',w); %show forward mask
    WaitSecs(0.200);  %use 200 msec forward mask. show stim for entire duration, ignoring subject response
end

Screen('CopyWindow', oswptr(1), w); %Copy preloaded target stim to open window's backbuffer

if useBackwardMask %hardcoded = same as fore mask
    [tVBLTime]=Screen('Flip',w); %Flip to target stimulus
    Screen('CopyWindow', oswptr(2), w); %Copy preloaded mask to open window's backbuffer
    WaitSecs(stim_dur); %target's stim dur...then let showstim flip to preloaded backmask
end



