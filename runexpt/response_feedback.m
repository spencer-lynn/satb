function [payoff]=response_feedback(outcome)
%SAtb fn: response_feedback -- Assign payoff codes to outcomes.
% - Outcomes are defined in decision_outcome.m
% 
% Change Log:
% 7/18/10 - added recognition of D0 behavior code (for pressing distractor key to a distractor)
% 2/9/10 - modified to use new listfile structure
% 2/10/10 - calls to read_list, load_stim, accrue_payoff replaced by use of show_stim.
% 10/18/12 
%     - payoffs used as dynamic references to struc-fields, so cannot end in + or - chars. I changed D- to Dminus, etc.
%     - added case for outcome='Rating' so rating screens can have payoff processing.
% 
% To do:
% - Would put call to a reinforcement scheduler here, but need method of associating response types to schedule
%%%%%%%%%%%%%%


switch outcome
    %Could be made less repetitious but leave as is for future
    %probabilistic feedback implementation in each case
    case 'CD' %correct detection
        payoff='h';
    case 'MD' %missed detection
        payoff='m';
    case 'FA' %false alarm
        payoff='a';
    case 'CR' %correct rejection
        payoff='j';
    case'NR0' %correctly ignored a distractor
        payoff='NR0';
    case'NR+' %failed to ID a S+
        payoff='NRplus';
    case'NR-' %failed to ID a S-
        payoff='NRminus';
    case'D0' %correctly pressed distractor-key to distractor
        payoff='D0';
    case'Dx' %Incorrectly pressed distractor-key to S+ or S-
        payoff='Dx';
    case'D+' %pressed S+ key to distractor
        payoff='Dplus';
    case'D-' %pressed S- key to distractor
        payoff='Dminus';
    case'Rating' %Delivered a rating (eg, affect, confidence)
        payoff='Rating';
    otherwise
        disp('Outcome or Feedback Error in response_feedback.m')
        payoff='NaN';
end %switch
end %feedback

