function [source sigval]=fetch_signal
%SAtb fn: fetch_signal -- return a random signal given scenario definition in global signal_params.
% In SAtb experitments, this is called by get_signal, itself called as an xfn in a stimulus list file.
% But, this fn also stands alone for use in modeling.
%
%Where source = posobjtype or negobjtype, with probability = alpha (base rate)
%      sigval = value# (on x-axis sensory domain) of stim to be shown: the stim number.
%               Don't confuse sigval with the experimental block's current
%               trial number in stiminfo or with the value of a payoff.
% If mu,var are arrays, this will produce array of signals for each value (of type based on base rate toss.
% Current legal distribution types are 'normal' and 'uniform'.
%
% 6/18/10 added distn globals to parameters_list for each signal (S+,S-)
% = specifies distribution shape from which signal is sampled.
% Defaults to 'normal' in set_params for backwards compatibility.
%
% 7/30/10 - changed uniform sigval assingment to random index into x_range
% rather than random draw from array of length x_range. Allows for x_range
% to start at value other than 1 (set in set_params).
%
% 11/11/10 - modified to use separate x_ranges for target vs foil
% distributions. Replaced calls to x_range, which is now no longer
% available here as a global. Eliminated while-loop and moved that x-range value-check
% into the code for Normal distribution draws.
%
% 11/16/10 - changed r=randi(size(x_range_targets)) to r=Randi(numel(x_range_targets)) because
% older WIN install of ML seemed to lack ML's randfun/randi and Randi needs
% max-value rather than range of uniform distribution.
%
% 1/15/11 - depricated older version:
% - this fn was known as assign_signal (which was called by fetch_signal).
% - now uses global struct signal_params for all values.
% 
% 8/5/11 - added try stmt for case=normal to catch when statistics toolbox not installed.

global signal_params posobjtype negobjtype noobjtype %target stimulus stim-list codes; defined in main expt definitions
% global muSplus muSminus varSplus varSminus alpha distnSplus distnSminus %these globals = params, are arrays so can generate multiple sets if desired (eg bsln, alpha manip...). they are currently set as a parameter-list file or user_init_script
% global x_range x_range_targets x_range_foils stimulus_list

unirand=rand(1,1); %Get a Uniform rnd # btw 0-1. If >alpha, then a playback signal (=a trial) is from S-
if unirand<=signal_params.baserate
    source=posobjtype; %signal is a target/S+
    switch signal_params.distnTarget %Fetch the signal(s):
        case 'normal'
            try
                sigval=round(normrnd(signal_params.muTarget,signal_params.varTarget)); %Round to nearest integer so that it picks out a specific stimulus # to show.
            catch
                sigval=round(signal_params.muTarget + signal_params.varTarget .*randn(1)); %Use this method when stat-toolbox not available.
            end

            if sigval>max(signal_params.x_range_target);sigval=max(signal_params.x_range_target);end
            if sigval<min(signal_params.x_range_target);sigval=min(signal_params.x_range_target);end
        case 'uniform'
            r=Randi(numel(signal_params.x_range_target)); %Uses PTB's "Randi" rather than ML's "randi" to pick uniform random integer from range 1:n, where n=numel(x_range))
            sigval=signal_params.x_range_target(r); %Use r as index into x-range.
    end %switch targets

else %unirand>base rate
    source=negobjtype; %signal a foil/S-
    switch signal_params.distnFoil  %Fetch the signal(s):
        case 'normal'
            try
                sigval=round(normrnd(signal_params.muFoil,signal_params.varFoil)); %Round to nearest integer so that it picks out a specific stimulus # to show.
            catch
                sigval=round(signal_params.muFoil + signal_params.varFoil .*randn(1)); %Use this method when stat-toolbox not available.
            end

            if sigval>max(signal_params.x_range_foil);sigval=max(signal_params.x_range_foil);end
            if sigval<min(signal_params.x_range_foil);sigval=min(signal_params.x_range_foil);end
        case 'uniform'
            r=Randi(numel(signal_params.x_range_foil)); %pick uniform random integer from range 1:n, where n=numel(x_range))
            sigval=signal_params.x_range_foil(r); %Use r as index into x-range.
    end %switch foils
end %if re base rate
end % fn