function d=dx_pt2line(xs,ys)
% Distance from point to line.
% See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
% 
% Returns signed distance, where negative is above line, positive below.
% 
% Change log:
% 20131203 - started
% 
% Currently hard coded for stright-line of slope=1, y-int=0.

a=1; %slope
b=1; %y-weight
c=0; %y-intercept
% for by=ax+c, a straight line, solve for zero -> a.*x - b.*y + c = 0, then
dx='(a.*xs - b.*ys + c)./sqrt(a^2+b^2)';
% Note: abs(a..c) would give abs value of distance.
d=eval(dx);
end