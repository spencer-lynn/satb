function psvec=peakshift_vector(new_origin,xs,ys)
% SAtb function: psvec=peakshift_vector(x,y) 
% 
% Where:
%       new_origin = cartesian coordinates on which to re-center the x,y data.
%       xs, ys = cartesian coordinates of ppt's S+ and S- response key use
%       psvec = struct with fields:
%           .dir (angle, theta, in radians).
%           .mag (rho, radius, vector mag).
%     
% Calling this fn with no input parameters will use demo data.
% 
% For data from a peak shift experiment, convert S+ and S- response key use (input xs,ys respectively) into 
% polar coordinates (vector with direction (angle theta) and magnitude (distance, radius rho).
% 
% However, these x,y pts are re-centered with respect to the experiment's point of no shift (new_origin).
% For example, if S+ and S- training stimuli were at stim7 and stim5, then point (7,5) becomes the 
% new origin (new_origin) for the input data (xs,ys) and the vectors are expressed in this transformed coordinate system.
% 
% This permits analysis of range shift and peak shift over all ppts:
% - Range shift in S+ direction will be in Quadrant 1 (top,right)
% - Range "contraction" will be in Quadrant 2 (top,left)
% - Range shift in S- direction will be in Quadrant 3 (bottom,left)
% - Peak shift will be in Quadrant 4 (bottom,right)
% 
% This script gets vector angles and magnitude. Submit the angles to CircStatTB, like:
%       circ_wwtest(group1_angles, group2_angles)
% - this will compare angles of two (btw-subj) groups.
% - This test won't handle NaNs in input columns.
% - For example, see proc_sap1_circular
% 
%Notes:
% The call to cart2pol can return some negative radians (ie, below horizontal midpoint of circle).
% That's okay: both polar plot and circstat tb deal fine with these.
% 2*pi+neg_rads will convert to positive values, and polar and circstat work with that fine too.
%  
% 
%Change Log:
% 8/14/12 started.
% 8/15/12 Removed sin/cos code and call to now-depricated script
% circular_stats.m; replaced by calls to circstat toolbox.
%
%%%%%%%%%%%%%%%%%%%%%

%% Demo data
if nargin==0
xy=[7 5;8 6;6 6;6 4;8 4];
new_origin=[7 5]
xs=xy(:,1);
ys=xy(:,2);
[xs ys]
end


%% Plot raw data
figure; hold on;
plot(new_origin(1),new_origin(2),'bx')
plot(xs,ys,'bo')


%% Center x,y points to new origin
center_xs=xs-new_origin(1);
center_ys=ys-new_origin(2);
plot(center_xs,center_ys,'ro') %Uncomment to check. Should mirror raw data at origin (0,0).

%% Convert centered x,ys to polar
[psvec.dir psvec.mag]=cart2pol(center_xs,center_ys); %Returns polar angles (theta) in radians.
polar(psvec.dir,psvec.mag,'k.') %Uncomment to check. Should match centered data.

%% Transform theta angles so can compute meaningful averages.
% = depricated. Use circstat toolbox for stats on the angles.
% circles=circular_stats(theta,'r')






end