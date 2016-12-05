function source=bayes_posterior(signal,scenario)
% SAtb function: bayse_posterior -- compute posterior probability of signal given signal parameters.
% Expects one signal at time (ie, per call)
% 
% If your getting all + or all - sources, check to see that scenario.x_range matches 
% the actual stimulus values in the experiment (eg, 1-11).
% 
% TO DO:
% - Re scenario struct, should rename var fields to "sd".
% - run many replications for for each ppt determining signal source, like bootstraping.
%     sources{s}=signalsources; keep track of s replicate runs.
% - don't do this for each ppt, since all got same stims in same order, just do for each distn scenario.


target=normpdf(scenario.x_range,scenario.muTarget,scenario.varTarget);
foil=normpdf(scenario.x_range,scenario.muFoil,scenario.varFoil);

bayes = target(signal) * scenario.baserate ./ ( (target(signal)* scenario.baserate) + (foil(signal) * (1-scenario.baserate)) );
r=rand;

% [target;foil]
% scenario
% [signal bayes r]


if r<=bayes
    source='+';
else
    source='-';
end

%Uncomment to view
% disp('     odds      rand     source')
% [bayes rand str2double(strcat(source,'1'))]

end %end function


