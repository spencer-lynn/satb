
function cleanup % cleanup at end of experiment

Screen('CloseAll');
ShowCursor;
% sca %replaces Scr(CA) and ShowCurs...
fclose('all');
% Priority(0);
diary off
end %clean up
