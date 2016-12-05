function psm=payoff_specific_measures(flt_outcome)
%% SAtb fn: payoff_specific_measures(flt_data,prt)
% Determine SDT measures (eg, bias, sensitivity) for subset of trials that immediately followed a specific outcome.
% 
%Parameters
% 	prt = parameters-run-time: a struct containing everything needed other than data
% 	flt_outcome = the outcomes (CD, FA, D+, etc) of each descision
%   psm = data output struct of {'fCDs' 'fFAs' 'fMDs' 'fCRs' 'fTargets' 'fFoils' 'fBenes' 'fCosts' 'fDistractors'}
%       - run each of the output types through evaluate.m to get bias, sensitivity, etc 
%       - Responses to "distractor" stims (eg, confidence rated stims; outcome = D+ or D-) can be passed in and will be treated
%       as an outcome subtype, just like CDs. etc. Distractors that follow an outcome type are filtered out inside evaluate.m 
%       (they don't have a target/foil source, so no correct answer to calc d' or c from)
%Notes 
% A few ways this analysis could turn out:
% 0. Bias could be near optimal following any kind of outcome: the prior trial's outcome should be independent of performance on current trial.
%    - The following possible results are all about looking for a lack of independence.
% 1. 1 or more outcomes produces more optimal bias on following trials
% 2. 1 or more outcomes leads to less optimal bias on following trials
% 3. These might differ by condition, or magnitude could be associated with an individual difference.
% 4. Condition might lead to more or less "perseveration" - effect of prior trial's outcome on next trial - 
%     that shows up in min/max bias spread, rather than a particular payoff due to power issues?
% 5. Outcome might influence accuracy for following targets vs foils rather than bias overall?
%     - Nah, "accuracy" for foils is meaningless, that's just regular accuracy.
% 
%Change log
% 12/30/10 - ~started, w/in catsd2_process.m
% 3/8/13 - rewriting as stand-alone script. Move all the evaluation & writing to the calling fn. 
%        - See catsd2_process or otd_process for examples.
% 3/8/13 - added D+/D- as output type, for trials that followed a confidence rating.
%        - added code for empty results -> NaN (eg, for if no D+/D- data sent in)
% 
%% %%%%%%%%%%%%%%%%%%%%%


%% Create logical arrays to get responses to stims that followed a particular source/outcome
ftrial=numel(flt_outcome)-1; %Skip the last trial, since we there is response after that.

%Get index (ie, trial) numbers for each outcome type.
CDs_index=strmatch('CD',flt_outcome(1:ftrial));
FAs_index=strmatch('FA',flt_outcome(1:ftrial));
MDs_index=strmatch('MD',flt_outcome(1:ftrial));
CRs_index=strmatch('CR',flt_outcome(1:ftrial));
Dplus_index=strmatch('D+',flt_outcome(1:ftrial));
Dminus_index=strmatch('D-',flt_outcome(1:ftrial));

%Increase each index by one, so that it refers to following trial
CDs_index=CDs_index+1; 
FAs_index=FAs_index+1;
MDs_index=MDs_index+1;
CRs_index=CRs_index+1;
Dplus_index=Dplus_index+1;
Dminus_index=Dminus_index+1;

%Init logical indices
CDs_logical=false(numel(flt_outcome),1);
FAs_logical=false(numel(flt_outcome),1);
MDs_logical=false(numel(flt_outcome),1);
CRs_logical=false(numel(flt_outcome),1);
Dplus_logical=false(numel(flt_outcome),1);
Dminus_logical=false(numel(flt_outcome),1);

%Flag desired trials (ie, those following specific outcomes)
CDs_logical(CDs_index)=true;
FAs_logical(FAs_index)=true;
MDs_logical(MDs_index)=true;
CRs_logical(CRs_index)=true;
Dplus_logical(Dplus_index)=true;
Dminus_logical(Dminus_index)=true;
% [sum(CDs_logical) sum(FAs_logical) sum(MDs_logical) sum(CRs_logical)]

%Create conglomerate indicies
targets_logical=CDs_logical | MDs_logical;
foils_logical=FAs_logical | CRs_logical;
benes_logical=CDs_logical | CRs_logical;
costs_logical=FAs_logical | MDs_logical;
distractors_logical=Dplus_logical | Dminus_logical;
% [sum(targets_logical) sum(foils_logical) sum(benes_logical) sum(costs_logical)]

%% Use the filters to grab the various subsets of outcomes.
psm.fCDs=flt_outcome(CDs_logical); %"f" for "following"; a listing of the outcomes that followed a CD on the prior trial.
psm.fFAs=flt_outcome(FAs_logical);
psm.fMDs=flt_outcome(MDs_logical);
psm.fCRs=flt_outcome(CRs_logical);
psm.fTargets=flt_outcome(targets_logical);
psm.fFoils=flt_outcome(foils_logical);
psm.fBenes=flt_outcome(benes_logical);
psm.fCosts=flt_outcome(costs_logical);
psm.fDistractors=flt_outcome(distractors_logical);

%Replace empty arrays with NaNs so that evaluate.m will return NaN when the array gets processed for dprime, etc.
ps_vars=fields(psm);
for fct=1:numel(fields(psm))
    if size(psm.(ps_vars{fct}),1)==0
        psm.(ps_vars{fct})=[NaN NaN NaN NaN];
    end
end

end %fn