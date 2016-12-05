%% STUDY: Example Experiment using the Signals Approach Toolbox
%
%CONTACT INFORMATION
%  Questions? Contact Spencer Lynn, spencer.lynn@gmail.com
%
%% FUNCTION satb_demo
% To quit in the middle, or to get out of a crash, press CTRL-c keys 
% simultaneously, followed by [ENTER], then blindly type "cleanup" (without
% quotes, then [ENTER]. This will bring you back to the Matlab command window.
% This may not work in Windows 7.
% 
% Also, occaisionally that might not work (eg, if the Matlab command-window gets backgrounded).
% Try Alt-0 (or Cmd-0 or ctl-0) then repeat the ctl-c/cleanup proceedure.
% 
% Files in the "data" and "list" folders are best opened in a spreadsheet
% program.
%
%% HOW TO RUN THE PROGRAM
%(1) Open Matlab
%
%(2) In the Matlab Command Window, at the >> prompt, type:
%
%      satb_demo(pptID)
%
% where: pptID = either a number or text string (the latter in single quotes)
%        pptID = 'demo' will run a very brief version.
%
% You'll get a warning in the Command Window if the pptID you provide
% has already been used. Retype, using a different pptID. 
% 
% If you attempting to re-run the same participant (eg, because computer crashed)
% then just add a "b" or ".2" or something to the subjectID to designate that it is 
% another run of the same person. 
% 
% Using pptID='demo' will bypass the data-file-already-exists
% check, over-write any existing 'demo' data file, and run a shorter
% "demonstration" version of the program, useful for trouble shooting.
%
% - The screen will go black for several seconds, then briefly white with
% the message "Welcome to PsychToolbox" and some other small text.
%
%(3) The screen then presents instructions for readying the experiment -
% Place the keyboard labels on the appropriate keys, as instructed
% on-screen. 
% - Press [SPACE BAR] when ready to continue, as instructed.
%
%(4) The screen then presents instructions to the participant 
% - Use the labeled keys to navigate through the instructions. 
% - The experiment is all automated from this point on.
%
%(5) To quit in the middle, or to get out of a crash 
% - Press the CTRL-c keys simultaneously, followed by [ENTER], then blindly type "cleanup"
% (without quotes), then [ENTER] again. This will bring you back to the Matlab command window.
% - To rerun the same subject use a new subjectID like '23.1' for subject 23,
% run 2.
%
%(6) At the end of the experiment the last screen of the experiment thanks
% the subject for participating and displays the total points earned. You or
% the subject can press the "Quit" key to
% end. You'll then see the Command Window again. The Command Window will
% display the duration of the experiment and total points earned.
%
%%%%%%%%%%%%%
