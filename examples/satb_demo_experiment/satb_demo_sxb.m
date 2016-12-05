function lor_params=satb_demo_sxb(scenario)
evalin('base','global lor_params')

switch scenario
    case {'conspaylowsim' 'conspayhighsim'}
        lor_params.method='beta';
        lor_params.beta=2.2255; %From beta value output by EXPT_model.m
        lor_params.dprime_range=0:0.1:3;
        
    otherwise
        disp(strcat(['Scenario not recognized in ',mfilename,'.m.']))
end


%% Now, in cmd-window:
% %Define dat martix and call sxb to calc & plot distances
% sxb(sig3dat,lor_params)

% % To get just the LOR (eg, to plot the ppts points agaist):
% parameters=lor_params;
% lor=eval(model)'; %get model from edit sxb
% [parameters.dprime_range' lor] %outputs the x,y values that plot the LOR.

% Return the part of the data set corresponding to a certain dat-col#3 code
%number (eg, mood, word condition)
% code=1;
% baserate_dat(find(baserate_dat(:,code)==3),1:2)
end