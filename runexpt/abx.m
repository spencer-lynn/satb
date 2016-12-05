function [a_info b_info]=abx(trial,abxinfo,a_info,b_info,winlim,btwlim)
% FUNCTION ABX(abxinfo,abxinfo,winlim,btwlim)
% Return stims to implement an ABX perceptual categorization study
%
%% Signals Approach to ABX Perceptual Categorization Expt
%
% The point of ABX is that X is more often correctly identified (as being identical to either A or B) when A and B are drawn from different perceptual categories than when they are members of the same category.
% Typically, one shows AB pairs of all consecutive pairs of stimuli on a continuum. These pairs being shown all the same number of times.... that not possible in a signals task: different stim are shown different amounts of times.
% Modified to be used in a signals task
% For stim A = xi and stim B = xj and stim X = xk,
% Determine P[f(xi)]  is from S+ vs S-
% Determine P[f(xj)]  is from S+ vs S-
% Correct ID of xk as identical to xi vs xj (not as from S+ vs S-) should vary with above probabilities of category member. So, when P(same distn) is high for both stims, then ID should be inaccurate. When P(different disnt) is high should be more accurate. For stim for which P[] is moderate, not really useful...so we're really maybe just able to use the tails of the two distns?
% The interesting point of this application is that perceptual categories aren't generally assumed to be plastic (ie, with environmental conditions/signal parameters). Re NSCC study, emotion words definitely shouldn't be expected to change boundaries of percept cats, nor should SDT scenario.
%
%
%% ABX Design
%
% One trial is a sequence of three stimuli: A, B, X, where X is either A or B repeated, counter-balanced (ie, sequential match-to-sample).
% A+B pairs are sequential combinations of stimuli in series.
% For example, for 10 pairs ({1,2},{2,3}..{10,11}), to repeat 10x, half X=A, X=B. Get gen'l stim pres from abx list file
%    (eg, show each for 500 ms, with inf reponse time following X.)
%
%    winlim = w/in cat limit equal,say, 1 unit btw a and b.
%    btwlim = btw cat limit equal,say, 7 units btw a and b for catch trials
%
%% ABX list-file structure
%
% List every desired X stim twice because can be either response code A or B
% (except that stim_1 can only be A and stim_last can only be B.
% Specify Type, Size, Position, Duration, Window, etc as normal.
% Response codes = a=-,b=+ reflecting +/- dichotomy used by labeled keys: + is for more extreme value, - for less.
% So, for a stim2 trial coded -, A=stim2, B=stim3, X=stim2 (which is -/less extreme relative to stim3).
% This all interpreted and displayed by abx.m.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAIN CODE
global negresponse posresponse stimulus_list %the "untouched" ordered listing of available stims in the experiment

x=abxinfo{1}(trial); %get X stim ID num for current trial
answer=char(abxinfo{3}(trial)); %get correct response code for current trial
switch answer %determin a,b, based on current trial's response code
    case '-'
        a=x;
        b=a+winlim; 
        answer(trial)=negresponse; %ans now equal a keycode
    case '+'
        b=x;
        a=b-winlim;
        answer(trial)=posresponse; %ans now equal a keycode
    case 'p' %a probe to catch people not attending to task
        a=x;
        b=a+btwlim;
        answer(trial)=negresponse; %ans now equal a keycode
    case 'q' %an probe to catch people not attending to task
        b=x;
        a=b-btwlim;
        answer(trial)=posresponse; %ans now equal a keycode
    otherwise
        disp('Unknown response code in abx.m')
        answer(trial)=NaN;
end %switch

a_info{2}(trial)=stimulus_list{2}(a);
b_info{2}(trial)=stimulus_list{2}(b);
end %main


