function est_outcomes=assign_bayes_outcomes(signalsources,flt_outcome)
%% SATB fn: est_outcomes=assign_bayes_outcomes(signalsources,flt_outcome)
% Assign correct/incorrect answers to confidence rated trials
% - following bayesian estimation of signal source as target vs foil by bayes_posterior.m
% - can then follow this with call the type2_sdt.m
% 
% Where: signalsources is output from bayes_posterior.m
%        flt_outcome are D-/D+ response outcome codes, resulting from ppt calling current face a foil or target.
%
% Change log:
% 3/7/13 - started
% 
%% %%%%%%%%%%%%%


est_outcomes=cell(size(signalsources));
for ct=1:numel(flt_outcome)
    switch flt_outcome{ct}
        case 'D+' %ppt said "target"
            if isequal(signalsources{ct},'+')  %correct answer is "target"
                est_outcomes(ct)={'CD'};
            elseif isequal(signalsources{ct},'-')%correct answer is "foil"
                est_outcomes(ct)={'FA'};
            else
                disp(strcat(['Signal source not recognized on line# ',num2str(ct)]))
            end
        case 'D-' %ppt said "foil"
            if isequal(signalsources{ct},'+')%correct answer is "target"
                est_outcomes(ct)={'MD'};
            elseif isequal(signalsources{ct},'-')%correct answer is "foil"
                est_outcomes(ct)={'CR'};
            else
                disp(strcat(['Signal source not recognized on line# ',num2str(ct)]))
            end
        otherwise
            disp(strcat(['flt_outcome not recognized on line# ',num2str(ct)]))
    end
end
% est_outcome %uncomment to check
end
