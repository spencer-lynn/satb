function sap2qc(process,cond1,cond2)
%----
%FUNCTION SAP2QC: Quality Control for SAP2 data
%
%edit sap2qc  %<-- Triple-click & [RETURN] for useage and more information.
%
%
% Customize the globals,case-fns as needed for different expt'l datasets.
% Uses: qc_fun.m and other data processing components of SAtoolbox
%
%----
%%

global callingQCfn qcPanelHandles raw_dataset condition datacolumns
global minimumRT maximumRT ttl_trials ignore_final_trials start_trial numSubblocks
global fname sdt_scenario mood_condition
global files numStimuli numSubjects stimNames numRatings go_direction
global datafile_suffix datafolder

if nargin==0; initialize; end
switch process
    case 'set_expt_params'
        %% Set params unique to experiment
        numSubjects=length(files);
        stimNames={'stim1.tif' 'stim2.tif' 'stim3.tif' 'stim4.tif' 'stim5.tif' 'stim6.tif' 'stim7.tif' 'stim8.tif' 'stim9.tif' 'stim10.tif' 'stim11.tif' };
        numStimuli=length(stimNames);
        numRatings=9; %number of confidence rating options
        go_direction='right';
        datafolder='data';
        datafile_suffix='.dat';
        
        
        
    case 'set_analysis_params'
        %% What to do every time a new block is examined
        % Define which trials to analyze, other bits
        %A sap2 scenario has 200 yes/no trials that COULD be analyzed = 178 drawn from signal distn + 22 not from distn that get confidnce ratings.
        %Structure = 140 trials (in 14 loops of 10) + a final 38 (=178) interspersed with 22 y/n stimpres_ara (=200) + 22 1..9 confidnce ratings).
        minimumRT=0; %minimum acceptible response time (msec) to consider a trial as valid: Trials with RT below this are excluded from most analyses.
        maximumRT=Inf; %minimum acceptible response time (msec) to consider a trial as valid: Trials with RT below this are excluded from most analyses.
        ttl_trials=200; %= either 178 or 200
        ignore_final_trials=0; %number final trials to exclude (eg 0 or 38, if think interpersed ratings might effect responses)
        %  -Doesn't make sense to ignore final any trials if using all 200.
        numSubblocks=1; %number of subblocks to break the analysis into. Should evenly divide ttl_trials.
        start_trial=1; %eg, 1..20; use this to ignore early "warm up" trials.
       
        
    case 'init'
        %% Make any permanent changes to GUI for this dataset here.

    
    case 'openfile'
        %% What to do everytime a file is opened
        %then set condition & scenario option in qc panel's popup menu
        [cond i j]=unique(raw_dataset.scenario,'first');
        i=sort(i);
        c=cell(numel(i),1);
        c(1:end)={' : '};
        conds=raw_dataset.condition(i);
        scens=raw_dataset.scenario(i);
        for k=1:numel(i)
            c{k}=strcat([conds{k},c{k},scens{k}]);
        end
        set(qcPanelHandles.conditions_pop,'String',c)
        set(qcPanelHandles.conditions_pop,'Value',2) %in SAP2, 2nd entry is neutral:baseline
        eval([callingQCfn '(''set_conditions'',''neutral'',''baseline'')']) %recursively call this fn without hardcoding its name

        
    case 'set_conditions'
        mood_condition=cond1
        sdt_scenario=cond2
        
        condition.mood=cond1; %load global structure for use by qc_fun>extract/filter routine
        condition.sdt=cond2; %load global structure for use by qc_fun>extract/filter routine
        datacolumns.mood=1; %refers to which col in raw_dataset to which to apply the filter-string in condition.X
        datacolumns.sdt=2; %refers to which col in raw_dataset to which to apply the filter-string in condition.X
      
        if isequal(mood_condition,'neutral') && isequal(sdt_scenario,'baseline')
            set(qcPanelHandles.trimtrials_btn,'Enable','On')
            set(qcPanelHandles.starttr,'Enable','On')
        else
            set(qcPanelHandles.trimtrials_btn,'Enable','Off')
            set(qcPanelHandles.starttr,'Enable','Off')
        end
        

end %switch process
end %main fn




%% FOLLOWING FNS ARE REQUIRED, DO NOT MODIFY
function initialize
global callingQCfn qcPanelHandles
        callingQCfn=mfilename; %get name of this m-file for use by fns in qc_fun.m.
        eval([callingQCfn '(''set_expt_params'')']) %recursively call this fn without hardcoding its name
        set_dir
        h=qc_panel; %launch GUI
        qcPanelHandles=guihandles(h);
        eval([callingQCfn '(''set_analysis_params'')']) %recursively call this fn without hardcoding its name
        eval([callingQCfn '(''init'')']) %recursively call this fn without hardcoding its name
        qc_fun
end


function set_dir
global datafolder files datafile_suffix
        %% Set the working directory: expects a 'data' folder containing subjects' data files.
        myname=strcat(mfilename,'.m'); %Get name of the currently running function, append .m to it.
        mypath=which(myname); %Get the directory path of this currently running function.
        s=strfind(mypath,myname); %Find the name of the file in the path.
        mypath=mypath(1:s-1); %Over write that path, eliminating the file name from the end of it.
        
        datapath=strcat(mypath,datafolder,'/'); %write summary data output file to the same location as this m-file.
        cd(datapath); %Set the MatLab working directory to the root path of the currently running m-file.
        files=dir;% (strcat('*',datafile_suffix));%get list of all data files
end
