function [x y]=positiontext(mytext,x,y)
global w wRect

[left top right bottom]=deal(wRect(1), wRect(2), wRect(3), wRect(4)); %sometimes used by stimlist cells

if length(mytext)~=0
%Center text regardless...
[normBoundsRect, offsetBoundsRect]=Screen('TextBounds', w, mytext); %bounds of text string
[l t width height]=deal(normBoundsRect(1), normBoundsRect(2), normBoundsRect(3), normBoundsRect(4));
[newx,newy] = RectCenter(wRect); %center of monitor's screen
newRect = CenterRectOnPoint(normBoundsRect,newx,newy); %method 1
%[newRect,dh,dv] = CenterRect(normBoundsRect,wRect); %method 2
[cleft ctop cright cbottom]=deal(newRect(1), newRect(2), newRect(3), newRect(4));


if strcmp(x,'center')
    x=cleft;
else
    %x=str2num(char(x)); %OLD: convert from cell to num, x must be a number
    x=eval(char(x)); %x can be any matlab equation using known variables (like left and top). Use this to
                    %position text at porportions of any screen rather than hardcoded #pixels.

end

if strcmp(y,'center')
    y=ctop;
else
    %y=str2num(char(y));  %OLD: convert from cell to num, y must be a number
    y=eval(char(y)); %x can be any matlab equation using known variables (like left and top). Use this to
                    %position text at porportions of any screen rather than hardcoded #pixels.
end

end
end %fn
