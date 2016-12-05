function extract_data_from_plot
%% Pull the x,y data from the lines on a Matlab figure.
%Works with front most (active) figure window.

lines=get(gca,'Children') %get handle to each line on a graph
names=get(lines,'DisplayName') %show matrix of legend names for all lines
ydata=get(lines,'YData') %get matrix of Y-data for all lines
xdata=get(lines,'XData') %get matrix of Y-data for all lines

disp('Now print the data with, eg, >> ydata{1}')
% ydata{1}' %show Ydata for line 1
end
