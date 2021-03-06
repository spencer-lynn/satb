function [rt_stats, headers]=rt_by_outcome(flt_outcome,flt_rt, prt, grab, stats, graphs)
% function: rt_by_outcome(flt_data, prt, grab, stats, graphs)
%
% "Response-time by outcome" -- Calculate response times by outcome-type (CD, FA, etc).
% Intended to be called from within an EXPT_process script, which has already created flt_data as needed).
%
% USAGE: rt_by_outcome(flt_data, prt, {'CR' 'CD' 'FA' 'MD'}, {@median @mean @std}, 0);
%
% WHERE:
% flt_data - data, with any filtering already applied.
% prt      - expt-spp collection of variables
% grab     - the types of outcomes you're splitting the rt data up for: {'CR' 'CD' 'FA' 'MD'}
% stats    - a cell array of function statistical handles (like, {@median @mean}). This script iterates through these,
%            applying each to the list of RT data. To add/remove stats, add or subtract from the list. 
% graphs   - 0/1: optionally make histograms of each set of RT data (FA, CD, MD, CR) for each participant
%            and saves those as pngs
%
% OUTPUT: prints stats to the larger csv file already generated by the calling function.
%
% CHANGE LOG:
% 20130917 - Written by William Johnston (Fall 2013 undergraduate IASLab research assistant), williamjjohnston@gmail.com.
% 20130923 - Generalized for inclusion in regluar Signals Approach Toolbox. -SKL.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%

% filter out long or short RTs
minrtflt = flt_rt >= prt.minimumRT;
maxrtflt = flt_rt <= prt.maximumRT;
logical_test = logical(minrtflt.*maxrtflt);
flt_outcome = flt_outcome(logical_test);
flt_rt = flt_rt(logical_test);

headers = ''; % begin new headers
rt_stats=[];
set(0,'DefaultFigureVisible','off'); % make it so millions of graphs don't appear

for trait = grab
    traitheader='';% build new column headers for current trait
    %disp(trait) %Uncomment to check.
    
    type = filter_data_array({flt_outcome flt_rt}, trait{1}, 1);
    typegrabbed = type(:, 2);
    typegrabbed = typegrabbed{1};
    
    lenstats = length(stats);
    stats_results = NaN(1, lenstats);
    stats_names = cell(1, lenstats);
    
    %% loop through passed in funcs
    for i = 1:lenstats
        stats_results(i) = stats{i}(typegrabbed);
        stats_names{i} = func2str(stats{i});
        traitheader = strcat(traitheader, ',',prt.label, '_',trait{1},'rt','_', stats_names{i}); % maintain headers

        %Display for debugging
        %disp(prt.pptID);
        %disp(trait);
        %disp(stats_names{i});
        %disp(stats_results(i));
    end
    rt_stats=[rt_stats stats_results];
    headers=strcat(headers,traitheader); %Accrete all the trait headers.
    
    %% plot and save graphs
    if graphs
        h = figure();
        hist(typegrabbed, 30);
        name = strcat(num2str(prt.pptID), trait);
        saveas(h, name{1}, 'png');
        close(h);
    end
end
set(0,'DefaultFigureVisible','on'); % make it so millions of graphs CAN appear
end
