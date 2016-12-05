function load_stim(trial_info)
%Load a stimulus into a window
%Default window = w, main window's back buffer, pass wptr to use an offscreen window for, eg, fast masking, animation.
%
% NOTE May get a crash from Screen() calls that need to be made wrt w rather than an offscreenwindow, such as MakeTexture. Can change as needed.
%
% CHANGE LOG
%3/4/10 added global CONDITIONS for xfns can have it eval'd. See eg, sig_catsd2 expt's feedback_list
%1/15/11 Replaced objdesc codes with calls to an xfn to eliminate slowness of switch stmt.
%2/7/11 made passed param a global, expects a single line from the listfile rather than the whole listfile.
%
%%%%%%%%%%%%%%%%%%

global w stimfolder wRect
global conditions %struct of current exptl condditions, defined in main expt script, available for use by 'x' fns
% global xtrial xstiminfo  %for use by any case 'x' function calls.

% if isempty(trial_info.wptr) %if a window pointer isn't supplied...
%     trial_info.wptr=w;%...then use the main window pointer.
% end

% conditions.xtrial=trial; %for use by any case 'x' function calls.
% conditions.xstiminfo=mystiminfo;
% 
% trial_info.trial=trial;
% [trial_info.objname trial_info.objdesc trial_info.mysize trial_info.fontname trial_info.red trial_info.green trial_info.blue trial_info.x trial_info.y]=...
%     deal(mystiminfo{2},...
%     mystiminfo{4},...
%     mystiminfo{5},...
%     mystiminfo{6},...
%     mystiminfo{7},...
%     mystiminfo{8},...
%     mystiminfo{9},...
%     mystiminfo{10},...
%     mystiminfo{11});
% objdesc=char(trial_info.objdesc(trial));
% [trial_info.left trial_info.top trial_info.right trial_info.bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %used by case=t, also can be called in list-files.


% trial_info
xfn=strcat(['load_' char(trial_info.Stimulus_Type) '(trial_info)' ]); %Create the function name, parameters from stimulus type.

% try
    eval(xfn) % If "Error: The input character is not valid..." check for " marks in list file xfn
% catch
%     
%     
%     Screen('TextSize', wptr, 32);
%     Screen('TextFont',wptr, 'Arial');
%     Screen('TextColor', wptr, [255 50 255]); %Purple
%     mytext='Stimulus type not recognized. See loadstim.m';
%     Screen('DrawText', wptr, mytext, 20, 20);
%     disp(mytext) %print to command line
% end

end %loadstim
