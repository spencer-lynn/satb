function likelihood(signal,scenario,numtrials)
%Estimate likelihood and of seeing particular stims (or greater) and #sightings over given
%number of trials.
%- Only works correctly for x-range = integer stim values, not high resolution.
%- Uses continous rather than discrite fn, so a bit off.
% - could implement a flag for which tail to examine.

target=normcdf(scenario.x_range,scenario.muTarget,scenario.varTarget);
% so target(signal) = probablility of seeing stim of value=signal or less, given target distn
foil=normcdf(scenario.x_range,scenario.muFoil,scenario.varFoil);
% so foil(signal) = probablility of seeing stim of value=signal or less, given foil distn

% ...1 minus this will be prob see stim or more intense...

like_target=(1-target(signal)) * scenario.baserate;
num_targets=like_target*numtrials;

like_foil=(1-foil(signal)) * (1-scenario.baserate);
num_foils=like_foil*numtrials;

like_cumulative = like_target+like_foil;
num_exemplars=like_cumulative*numtrials;


Likelihoods={like_target num_targets like_foil num_foils like_cumulative num_exemplars;...
          'p Target' 'n targets' 'p Foil' 'n foils' 'p Signal' 'n exemplars'}'

end