
function surfaceplotting2(experimentName,xHeader,yHeader,zHeader,cHeader,datamat)
% eg:
% surfaceplotting2('sig3','dprime','bias','used_pts','used_pts')
%
%1. Create a mat-file "experimentName" inside experimentName/data 
%- to make the mat file, save text file of x,y,z,c in columns (with col names header line)
%- Do ML File/Import data...
%- Do >>save of three resultant workspace vars (colheaders,data,textdata) as mat file
% ! 9/3/15 Import data no longer does what it used to--see update below.
%
%2. Then, call this fn
%- Uses cdwork() to get to experimentName's directory
%
%3. Alternatively, to plot LOR SxB heatmap, just see util_space.m,
%   which creates data and passes here automatically.
%
%
% Spencer Lynn 4/20/09
% Updates: 
% 11/28/09 sap2->sig3... made a little more generalized
% 6/28/10 Accepts utilspace global from util_space.m to plot LOR heatmap.
% 9/3/15 Import data no longer does what it used to.
%        So, need to create global expt.data as a matrix, with 
%            rows = observations
%            cols 1-3 or 4 matching the x,y,z,c header infor passed in when the fn is called.
%        Then call this w/ expt name = 'bespoke'
%
% NOTES:
% See also Functions of Complex Variables: cplxdemo


global expt fig sur ax x y c z utilspace isospace
ptflag=1 %plot indiv pts or not.

switch experimentName
    case 'utilspace' 
        %Passed data from util_space.m
        %Need to spoof expt. data structure
        expt.colheaders={xHeader yHeader zHeader};
        expt.textdata={xHeader yHeader zHeader};
        expt.data=utilspace;
        expt
    case 'isobias'
        %Passed data from util_space.m
        %Need to spoof expt. data structure
        expt.colheaders={xHeader yHeader zHeader};
        expt.textdata={xHeader yHeader zHeader};
        expt.data=datamat; %four cols of rows of data
        expt
      
        
    case 'isospace'
        %Passed data from isoaccuracy.m
        %Need to spoof expt. data structure
        expt.colheaders={xHeader yHeader zHeader};
        expt.textdata={xHeader yHeader zHeader};
        expt.data=isospace;
        expt

    case 'bespoke'
        %Passed data from something else
        %Need to spoof expt. data structure
        expt.colheaders={xHeader yHeader zHeader};
        expt.textdata={xHeader yHeader zHeader};
        expt
      
    otherwise
        cdwork(experimentName)
        expt=load(strcat('data/',experimentName)) %LOAD = mat file struct of colnames + numeric data
end

%suss data columns to plot from input args
xcol=strmatch(xHeader,expt.colheaders,'exact');
ycol=strmatch(yHeader,expt.colheaders,'exact');
zcol=strmatch(zHeader,expt.colheaders,'exact');
ccol=strmatch(cHeader,expt.colheaders,'exact');

% xdat=expt.data(:,xcol);
% ydat=expt.data(:,ycol);
% zdat=expt.data(:,zcol);
% cdat=expt.data(:,ccol);

% [x y z c]=setplotaxes(xcol,ycol,zcol,ccol);

lgx=~isnan(expt.data(:,xcol)); %make logical index array used to...
lgy=~isnan(expt.data(:,ycol)); %make logical index array used to...
lgz=~isnan(expt.data(:,zcol)); %make logical index array used to...
lgc=~isnan(expt.data(:,ccol)); %make logical index array used to...
logfilt=logical((lgx.*lgy.*lgz.*lgc));
expt.data=expt.data(logfilt,:); %...overwrite data with only the useable data of interest

%hist(expt.data(:,y))


xs=linspace(floor(min(expt.data(:,xcol))),ceil(max(expt.data(:,xcol))),100); %100 intervals for high resolution interpolation->smooth graph
ys=linspace(floor(min(expt.data(:,ycol))),ceil(max(expt.data(:,ycol))),100)';
[xmat ymat]=meshgrid(xs,ys);

z_grid=griddata(expt.data(:,xcol),expt.data(:,ycol),expt.data(:,zcol),xmat,ymat,'cubic'); %Populate data matrix with sparse data. For mutiple x,y samples griddata happily takes the average.
color_grid=griddata(expt.data(:,xcol),expt.data(:,ycol),expt.data(:,ccol),xmat,ymat,'cubic'); %Populate data matrix with sparse data. For mutiple x,y samples griddata happily takes the average.

fig=figure; hold on;
sur=surfc(xmat,ymat,z_grid,color_grid, ...
    'FaceColor','interp',...
    'EdgeColor','none',...
    'FaceLighting','phong');
ax=gca;
% set(sur,'AmbientStrength',.4)%=0..1
% set(sur,'DiffuseStrength',.3)%=0..1
% set(sur,'SpecularExponent',18)%<0
% set(sur,'FaceLighting','none')%<0 %turn off lighting/shadow, hard shell finish
axis tight
view(2)
camlight left
colorbar

%   Correct position for multi-monitor break down
%ltbr=[194 2614 560 420];
%ltbr=[731 2461 891 706];
%set(fig,'Position',ltbr)

% customizeplot(xmat,ymat,z_grid)

xlabel(xHeader,'FontSize',24)
ylabel(yHeader,'FontSize',24)
zlabel(zHeader,'FontSize',24)

%plot indiv data points, floating above z axis
if ptflag
 plot3(expt.data(:,xcol),expt.data(:,ycol),ones(size(expt.data(:,zcol)))*max(get(ax,'zlim')),'r.') 
end
end %fn

function [x y z c]=setplotaxes(x, y, z, c)
global xaxisname yaxisname zaxisname caxisname
xaxisname=inputname(1); %suss variable name as string for plot axis lable
yaxisname=inputname(2);
zaxisname=inputname(3);
caxisname=inputname(4);
end

function customizeplot(xmat,ymat,zmat)
%% For each plot
global expt fig sur ax x y z c
global xaxisname yaxisname zaxisname caxisname

% xlabel(xaxisname,'FontSize',24)
% ylabel(yaxisname,'FontSize',24)
% zlabel(zaxisname,'FontSize',24)
% plot3(expt.data(:,x),expt.data(:,y),ones(size(expt.data(:,z)))*max(get(ax,'zlim')),'r.')
% 

%% More plotting options
%set(h,'EdgeColor','k') %change patch border color
%shading flat
%shading faceted
%hold on
%plot3(X3dtest(:,2),X3dtest(:,3)'.')
%plot3(X3dtest(:,2),X3dtest(:,3),X3dtest(:,1),'or')

contour3(xmat,ymat,zmat, 40)

% h = findobj('Type','patch');
% set(h,'LineWidth',2) %make contour lines pop out

end %fn





function process_duplicate_samples
%% Finds duplicate samples in x,y space so the z-data at those points can be
% processed (eg, averaged) before plotting.
% Essential logic copid from GRIDDATA.m

%Need x,y and z to be column vectors
sz = numel(x);
x = reshape(x,sz,1);
y = reshape(y,sz,1);
z = reshape(z,sz,1);

%Sort rows to group duplicate pts
sxyz = sortrows([x y z],[2 1]);
x = sxyz(:,1);
y = sxyz(:,2);
z = sxyz(:,3);

%Not totally sure what this does...
%EPS gets minimal distance btw valid points in space's numeric resolution.
myepsx = eps(0.5 * (max(x) - min(x)))^(1/3); %=1/3 of the EPS of half-range?
myepsy = eps(0.5 * (max(y) - min(y)))^(1/3);

%Index any duplicate sample points
ind = [0; ((abs(diff(y)) < myepsy) & (abs(diff(x)) < myepsx)); 0];

if sum(ind) > 0 %If dups exist...
    warning('MATLAB:griddata:DuplicateDataPoints',['Duplicate x-y data points ' ...
        'detected: using average of the z values.']);
    fs = find(ind(1:end-1) == 0 & ind(2:end) == 1); %SET UP VERY CLEVER INDEX METHOD!
    fe = find(ind(1:end-1) == 1 & ind(2:end) == 0);

    for i = 1 : length(fs)
        z(fe(i)) = mean(z(fs(i):fe(i))); % averaging z values
    end %for each set of dups

    x = x(~ind(2:end));
    y = y(~ind(2:end));
    z = z(~ind(2:end));
end %if dups exist
end %%fn

