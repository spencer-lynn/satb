function ratings_summary=rating_gradient(stimNames,flt_stimname,flt_rating,flt_behavior,plotflag)
%% SATB fn: ratings_summary=rating_gradient(flt_stimname,flt_rating,flt_behavior,plotflag)
% 
% Calculate (and plot) summary statistics of confidence ratings given over each stimulus, like a psychometric fn.
% - ratings_summary is a struct with count, mean, stdev rating given to each stim; split by all, targets, foils
% - hard coded for two behavior types: -1="foil", +1="target"
% - this DOES NOT reframe ratings given to foils as if they were given to targets (ie, INVERSE ratings as used in roc_from_confidence)
%   - doing inverse would be an alternate way of getting a psychometric
%     function (where confidence level, as conf(S+) = response strength)
% 
% Spencer Lynn, spencer.lynn@gmail.com
% 
% Change Log:
% 3/7/13 - started for OTD study.
%% %%%%%%%%%%%%%%

for sctr=1:numel(stimNames)
    lg=strcmp(stimNames(sctr),flt_stimname); %creat logical index of current stim#
    ratings_summary.all.n(sctr)=sum(lg);% Should = 10 presentations of each stim, if none eliminated due to RT
    ratings_summary.all.mean(sctr)=nanmean(flt_rating(lg)); %get mean rating given to current stim#
    ratings_summary.all.sd(sctr)=nanstd(flt_rating(lg)); %get mean rating given to current stim#
end

beh_lg=flt_behavior==-1; %index to stims ppt called "foil"
for sctr=1:numel(stimNames)
    stim_lg=strcmp(stimNames(sctr),flt_stimname); %creat logical index of current stim#
%     
%     %some problem here.
%     size(beh_lg')
%     size(stim_lg)
   
    
    lg=logical(beh_lg.*stim_lg); %Combine the filters
    ratings_summary.foils.n(sctr)=sum(lg);% Should = 10 presentations of each stim, if none eliminated due to RT
    ratings_summary.foils.mean(sctr)=nanmean(flt_rating(lg)); %get mean rating given to current stim#
    ratings_summary.foils.sd(sctr)=nanstd(flt_rating(lg)); %get mean rating given to current stim#
end

beh_lg=flt_behavior==1; %index to stims ppt called "target"
for sctr=1:numel(stimNames)
    stim_lg=strcmp(stimNames(sctr),flt_stimname); %creat logical index of current stim#
    lg=logical(beh_lg.*stim_lg); %Combine the filters
    ratings_summary.targets.n(sctr)=sum(lg);% Should = 10 presentations of each stim, if none eliminated due to RT
    ratings_summary.targets.mean(sctr)=nanmean(flt_rating(lg)); %get mean rating given to current stim#
    ratings_summary.targets.sd(sctr)=nanstd(flt_rating(lg)); %get mean rating given to current stim#
end

if plotflag
    figure;hold on
    plot(1:numel(stimNames),ratings_summary.all.mean,'ko-')
    plot(1:numel(stimNames),ratings_summary.foils.mean,'ro-')
    plot(1:numel(stimNames),ratings_summary.targets.mean,'bo-')
end

%Uncomment to view
% ratings.all.mean
% ratings.foils.mean
% ratings.targets.mean
end