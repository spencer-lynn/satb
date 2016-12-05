function performance=type2_sdt(outcomes,ratings,options)
% SAtb function: type2_sdt -- transform confidence ratings in to Type-II SDT analysis, such that:
% 
% CD|CR @ HIGH confidence = CD
% FA|MD @ HIGH confidence = FA
% CD|CR @ LOW confidence = MD
% FA|MD @ LOW confidence = CR
% 
% Where:
% outcomes = single column (vector) of decision outcomes (CD, etc).
% ratings = confidence ratings (scalers) matched to rows of outcomes.
% options.boundary = cutoff for "high" confidence, eg >= 6 on scale of 1-9,
%                                                        0 on z-scored ratings.
% options.method='zscore' => z-scoring of ratings
%                            otherwise, uses raw ratings.
% 
% Expects decision-outcome and confidence rating input from a single participant as two matched columns.
% Returns Outcome counts, dprime, and bias as 1 row x 6 column vector.
% 
% INTERPREATION:
% Low sensitivity = low self-awareness of performance (ppt not able to know when making poor decision)
% High sensitivity = high self-awareness of performance
% Liberal bias = over-confidence in performance (ppt not as good as he/she thinks)
% Conservative bias = under-confidence in performance
% 
% Change log:
% 9/24/11 - made performance a struct.
% 3/7/13 - dropped "do" from file name.
% 3/24/14 - forked to new version, depricated prior version.
%         - removed "boundary" param, replaced with "options" struct
% 
% TO DO:
% add more method options
% add boundary options: mean, median, mode, ..+1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Uncomment to debug
% outcomes
% ratings
% options.boundary

switch options.method
    case 'zscore'
        ratings=zscore(ratings);
    otherwise
        %undefined, use raw ratings
end

type2=cell(size(outcomes));
for i=1:length(outcomes)
    switch outcomes{i}
        case {'CD' 'CR'}     %ppt answered correctly
            if ratings(i)>=options.boundary %high confidence
                type2{i}='CD';
            else             %low confidence
                type2{i}='MD';
            end
        case {'FA' 'MD'}     %ppt answered incorrectly
            if ratings(i)>=options.boundary %high confidence
                type2{i}='FA';
            else             %low confidence
                type2{i}='CR';
            end
    end %switch
end %for each trial

datatype.type='frequency'; %we're evaluating frequencies of CDs, etc
performance=[]; %clear

performance.raw_counts=evaluate(type2,'raw_counts',datatype); %return counts of [CDs FAs MDs CRs]
% performance=[performance counts]; %accrete measures output

performance.dprime=evaluate(type2,'dprime',datatype);
% performance=[performance dprime]; %accrete measures output

performance.c=evaluate(type2,'c',datatype);
% performance=[performance bias]; %accrete measures output

%% Uncomment to see output
% disp('      CDs       FAs     MDs       CRs       dprime     bias')
% performance
end