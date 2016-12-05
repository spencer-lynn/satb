function waitmouse
%Pause until mouse click.
%See also GetClicks
%Uses Psychtoolbox

buttons=0;
WaitSecs(.3); %pause for debounce.
while ~any(buttons) % wait for press
    [x,y,buttons] = GetMouse;
    WaitSecs(0.001); % Wait 10 ms before checking the mouse again to prevent overload of the machine at elevated Priority()
end %while
end %fn waitmouse