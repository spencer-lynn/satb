  function performance=evaluate(behavior,measure,datatype)
% SAtb fn EVALUATE(behavior, measure, datatype) -- Indexes of signal detection performance, where:
% BEHAVIOR is decision outcomes, in one of two formats:
%    format #1 = list of outcome labels ("CD", "MD", etc) down rows of a single column. An optional second column can contain response times.
%    format #2 = row(s) of four columns = counts or proportions of [CDs FAs MDs CRs]
%
% MEASURE is one of {'raw_counts' 'precision' 'accuracy' 'dprime' 'bias' 'rt' 'betag'}... and others.
%    NOTE: 'rt' returns mean response time of each outcome type.
%
% DATATYPE, if present, is a structure with .type = 'frequency'|'fraction'|'rate' (ie the type of hit,alarm, etc being passed)
%                                       and .baserate = alpha if type=fraction
%                                       and .numTrials = number of trials to assume
% 
% .type = 'frequency' => expects counts of CDs, etc, from which hit-rate, FA-rate are determined. Data come from participants.
% .type = 'rate' => eg, hit-rates directly from normCDF. Data come from scenario models. 
% .type = 'fraction' => Not sure about this one. Could mean a couple of things -- be careful using it.
%            - Could mean hit-rates (usu from normCDF, model) get transformed into frequencies. Can yeild inaccurate low d', beta.
%            - Could mean proportion of trials (from participant or model).
% 
% 
% NOTES
% - d' is calculated for a "yes/no" or "one-interval" expt in M&C
% terminology (ie, a trial shows a single stimulus that perceiver
% categorizes). For 2AFC or ABX trials (ie, more than one stimulus in a
% trial) need to write new routine.
% 
% CHANGE LOG
% 11/25/09 Added fn nudge to change zero outcome counts to very small number for d', bias computations.
% 2/8/10   Changed nudge frequencies by add/subtract 0.5. Lowers otherwise extreme measures.
% 2/21/10  Changes:
%           -Format #2 accepts multiple cases, down rows. Returns column of outcomes.
%           -Removed "p" proportion of input to be processessed (used only by SAP1 expt)
%           -Corrects for either counts or proportions = zero.
% 7/26/10   Uses cts=0 for 'format not recognized error'
% 5/25/11   Discovered source of non-monotonic hiccoughs in d' estimates for model output. Several sources:
%           - datatype.numtrials too low to generate adequate hit rates at extreme threshold locations
%           This is passed in from, eg, lorpoints, compare_params scripts.
%           - Bug, re I neglected to use 1-baserate for FOILs in transform_proportions, below.
%           - Fixing these revealed non-zero d' floor arising from transform + 0.5 correction.
%           = Solution: use fractions (type='rate') directly in performance calcs.
%             With adjustment of rates near zero by small nudge, which was a little problematic (see below).
%             Rewriting script for this now (depricated prior version).
%           * This error applied only to type=fraction, not frequency, so only affected modeling data calcs, 
%             not observed data analysis.
% 
% 2/9/12    In do_nudge case=frequencies, I changed calc of hitRate & falseRate to use ./ rather 
%            than / operator to fix a bug when operating on multiple rows of observations.
% 3/12/12   Now applies nudge=0.5 correction to case when both related-outcomes (ie, CD+MD or FA+CR) have count=0.
%            This is useful for payoff-specific bias/sens calcs.
% 5/12/12   Added mean RT (response time) output for targets, foils, costs, and benefits to that of outcomes.
% 10/21/12  Discovered that accuracy and precision not calculated correctly by fn evaluate.m if datatype=rate. Replaced with NaN, error msg.
%           Might be true of datatype=fraction, too. Noted w/ msg.
% 11/9/12 Fix accuracy for type=rate. Haven't fixed precision or checked type=fraction.
% 11/12/12 Added fix for precision if type=rate. Haven't checked type=fraction.
% 4/14/14 Added output option of hit and false alarm rates, measure='rates'.
% 2/8/16   Commented out RT by targ,foil,cost,bene and added Yes,No button press.
% 
% TO DO
% - If .type=fraction, check if need convert to frequency in order to get acc, prec. See type=rate code.
% - considering update the nudge= +/- 0.5 to Brown and White 2005 recommendation of ADDING nudge to all outcomes.
%%%%%%%%%%%%%

if nargin==2;datatype.type='not specified';end
[r c]=size(behavior);
switch c
    case 1 
        %FORMAT 1: A single subject's raw outcomes, in 1 column, each row = a trial. A list of strings 'CD' 'CD' 'CR'...
        %Optional 2nd col=something else (ie, RTs).
        indCDs=strmatch('CD',behavior(1:end)); %'end' is a matlab variable indexing last cell of a matrix.
        indFAs=strmatch('FA',behavior(1:end));
        indMDs=strmatch('MD',behavior(1:end));
        indCRs=strmatch('CR',behavior(1:end));
        
        CDs=length(indCDs);
        FAs=length(indFAs);
        MDs=length(indMDs);
        CRs=length(indCRs);        
        
    case 2 %FORMAT 1b: A single subject's raw outcomes, in 1st column (each row = a trial); 
        indCDs=strmatch('CD',behavior{1:end,1}); %'end' is a matlab variable indexing last cell of a matrix.
        indFAs=strmatch('FA',behavior{1:end,1});
        indMDs=strmatch('MD',behavior{1:end,1});
        indCRs=strmatch('CR',behavior{1:end,1});
        
        CDs=length(indCDs);
        FAs=length(indFAs);
        MDs=length(indMDs);
        CRs=length(indCRs);
        
    case 4 %FORMAT 2: Counts or proportions of outcome frequencies in 4 cols, [CDs FAs MDs CRs], one case/person's data in each row.
        CDs=behavior(:,1);
        FAs=behavior(:,2);
        MDs=behavior(:,3);
        CRs=behavior(:,4);
        
    otherwise
        disp('BEHAVIOR format not recognized in fn EVALUATE.')
        disp('Returning zeros as count values.')
        behavior
        CDs=0;
        FAs=0;
        MDs=0;
        CRs=0;

end %switch behavior data format

switch measure
% NO TRANSFORM REQURIED
    case 'raw_counts'
        performance=[CDs FAs MDs CRs];
    case 'rt' %expects response times as columnn 2 of BEHAVIOR
        %Init logical indices
        CDs_logical=false(numel(behavior{2}),1);
        CDs_logical(indCDs)=true;
        FAs_logical=false(numel(behavior{2}),1);
        FAs_logical(indFAs)=true;
        MDs_logical=false(numel(behavior{2}),1);
        MDs_logical(indMDs)=true;
        CRs_logical=false(numel(behavior{2}),1);
        CRs_logical(indCRs)=true;
        
        %Create conglomerate indicies
        yesbtn_logical=CDs_logical | FAs_logical;
        nobtn_logical=MDs_logical | CRs_logical;
%         targets_logical=CDs_logical | MDs_logical;
%         foils_logical=FAs_logical | CRs_logical;
%         benes_logical=CDs_logical | CRs_logical;
%         costs_logical=FAs_logical | MDs_logical;
        
        %Calc ave response times
        CDrt=mean(behavior{2}(CDs_logical));
        FArt=mean(behavior{2}(FAs_logical));
        MDrt=mean(behavior{2}(MDs_logical));
        CRrt=mean(behavior{2}(CRs_logical));
        yesRT=mean(behavior{2}(yesbtn_logical));
        noRT=mean(behavior{2}(nobtn_logical));
%         targetRT=mean(behavior{2}(targets_logical));
%         foilRT=mean(behavior{2}(foils_logical));
%         beneRT=mean(behavior{2}(benes_logical));
%         costRT=mean(behavior{2}(costs_logical));
        
        performance=[CDrt FArt MDrt CRrt yesRT noRT];
%         performance=[CDrt FArt MDrt CRrt targetRT foilRT beneRT costRT];
        
    case {'proportion' 'accuracy'} %acc eq from Wikipedia 12/7/09
        if isequal(datatype.type,'rate')
            % 11/9/12 - code up rate->freq xform:
            % If datatype.type='rate' convert to frequency in order to get accuracy
            % where: expected#CDs = CDrate*baserate*#trials
            % This will require .baserate, .numTrials values.
            %[CDs FAs MDs CRs] %uncomment to check
            CDs=CDs.*datatype.baserate.*datatype.numTrials;
            CRs=CRs.*(1-datatype.baserate).*datatype.numTrials;
            MDs=MDs.*datatype.baserate.*datatype.numTrials;
            FAs=FAs.*(1-datatype.baserate).*datatype.numTrials;
            %[CDs FAs MDs CRs] %uncomment to check
            performance = (CDs+CRs)./(CDs+MDs+CRs+FAs);
            
        elseif isequal(datatype.type,'fraction')
            disp('fn EVALUATE might not correctly calculate accuracy when datatype.type=fraction.')
            disp('Returning a value; check it.')
            performance = (CDs+CRs)./(CDs+MDs+CRs+FAs);
        else
            performance = (CDs+CRs)./(CDs+MDs+CRs+FAs);
        end
        
    case 'precision'
        if isequal(datatype.type,'rate')
            % rate->freq xform:
            % If datatype.type='rate' convert to frequency in order to get accuracy
            % where: expected#CDs = CDrate*baserate*#trials
            % This will require .baserate, .numTrials values.
            %[CDs FAs MDs CRs] %uncomment to check
            CDs=CDs.*datatype.baserate.*datatype.numTrials;
            CRs=CRs.*(1-datatype.baserate).*datatype.numTrials;
            MDs=MDs.*datatype.baserate.*datatype.numTrials;
            FAs=FAs.*(1-datatype.baserate).*datatype.numTrials;
            %[CDs FAs MDs CRs] %uncomment to check
            performance = CDs./(CDs+FAs);
        
        elseif isequal(datatype.type,'fraction')
            disp('fn EVALUATE might not correctly calculate precision when datatype.type=fraction.')
            disp('Returning a value; check it.')
            performance = CDs./(CDs+FAs);
        else
            performance = CDs./(CDs+FAs);
        end
            
            
        
% TRANSFORM TO RATES        
    case 'diff_rates'
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
%         performance = CDs./(CDs+MDs)-FAs./(FAs+CRs); %stright diff of rates. This will show differences btw subjects that have same d' or CTalpha but different bias
        performance = hitRate-falseRate; %stright diff of rates. This will show differences btw subjects that have same d' or CTalpha but different bias
    case 'dprime' %classic SDT d'
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
%         performance = norminv(CDs./(CDs+MDs))-norminv(FAs./(FAs+CRs)); %SDT d', range 0..~4.65. (norminv does z-transform) -- M&C1991 eq1.3
        performance = norminv(hitRate)-norminv(falseRate); %SDT d', range 0..~4.65. (norminv does z-transform) -- M&C1991 eq1.3
    case {'c' 'bias'}
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
%         performance = -.5*(norminv(CDs./(CDs+MDs))+norminv(FAs./(FAs+CRs))); %SDT bias=c, range~-2.3..+2.3. (norminv does z-transform) -- M&C1991 eq2.2
        performance = -.5*(norminv(hitRate)+norminv(falseRate)); %SDT bias=c, range~-2.3..+2.3. (norminv does z-transform) -- M&C1991 eq2.2
    case {'betag' 'beta'}
        c=evaluate([CDs FAs MDs CRs],'c',datatype);
        d=evaluate([CDs FAs MDs CRs],'dprime',datatype);
        performance=exp(c.*d); %SDT Beta-G (range 0..+inf; ratio of Gausssian likelihoods @ threshold, ie, slope of ROC,indif line), M&C1991 eq2.10
    case ('rates')
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
         performance=[hitRate falseRate];%return hit and false alarm rates.
         
% TRANSFORM TO FREQUENCIES   
    case 'choice_sens' %Choice Theory sensitivity
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
        performance = .5*log((CDs*CRs)./(MDs*FAs)); %=log(ctALPHA) = the Choice Theory sensitivity measure,~SDT d' -- M&C1991 eq1.6
    case {'choice_b' 'logb'} %Choice Theory bias, "b"
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype);
        performance = -.5*log((CDs*FAs)./(MDs*CRs)); %log of Choice Theory "b",~SDT bias, M&C1991 eq.2.5

    otherwise
        disp('Requested MEASURE not recognized in fn EVALUATE.')
        
        
end %switch measure type
end %evaluation


function [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype)
switch datatype.type
        
    case 'frequency'
        %Sometimes a ppt will have zero of one type of outcome.
        %When outcomes are counts, it's  common to add/subract 0.5 from affected outcomes (M&C 1991 p10)
        %USE THIS ONLY FOR FREQUENCIES, NOT FOR PROPORTIONS, since adding 0.5!
        nudge=0.5;
        
        zindex=find(CDs==0);
        CDs(zindex)=CDs(zindex)+nudge;
        MDs(zindex)=MDs(zindex)-nudge;
        
        zindex=find(MDs==0);
        CDs(zindex)=CDs(zindex)-nudge;
        MDs(zindex)=MDs(zindex)+nudge;
        
        zindex=find(FAs==0);
        FAs(zindex)=FAs(zindex)+nudge;
        CRs(zindex)=CRs(zindex)-nudge;
        
        zindex=find(CRs==0);
        FAs(zindex)=FAs(zindex)-nudge;
        CRs(zindex)=CRs(zindex)+nudge;
        
        %Sometimes, a ppt may have both CD+MD=0 (or FA+CR=0). Then, above correction 
        %results in a negative outcome count. Correct by making both zeros=0.5.
        zindex=find(CDs<0);CDs(zindex)=nudge;
        zindex=find(MDs<0);MDs(zindex)=nudge;
        zindex=find(FAs<0);FAs(zindex)=nudge;
        zindex=find(CRs<0);CRs(zindex)=nudge;
        
        hitRate=CDs./(CDs+MDs);
        falseRate=FAs./(FAs+CRs);

        
    case 'rate'
        %CD, etc are already target and foil specific rates. Make small adjustment if hit-rates=0.
        %But, dprime calc can fail for very small values of CDs, like CDs=1.1102e-16 (which are not corrected as zero).
        %So, rather than correct for rates=0 (zindex=find(CDs==0)), correct for rates very near zero.

        nudge=0.0001;
        
%          [CDs FAs MDs CRs sum([CDs MDs]) sum([FAs CRs])] %uncomment to check pre-correction rates

        zindex=find(CDs<nudge);
        CDs(zindex)=nudge;

        zindex=find(FAs<nudge);
        FAs(zindex)=nudge;
        
        zindex=find(MDs<nudge);
        MDs(zindex)=nudge;
                
        zindex=find(CRs<nudge);
        CRs(zindex)=nudge;

%          [CDs FAs MDs CRs sum([CDs MDs]) sum([FAs CRs])] %uncomment to check post-correction rates

        hitRate=CDs;
        falseRate=FAs;

        
    case 'fraction' %Convert to frequencies
        try %if a baserate was passed then use it.
%             [CDs FAs MDs CRs sum([CDs FAs MDs CRs])] %uncomment to check preconversion fractions
            CDs=round(CDs*datatype.numTrials*datatype.baserate);
            FAs=round(FAs*datatype.numTrials*(1-datatype.baserate));
            MDs=round(MDs*datatype.numTrials*datatype.baserate);
            CRs=round(CRs*datatype.numTrials*(1-datatype.baserate));
%             [CDs FAs MDs CRs sum([CDs FAs MDs CRs])] %uncomment to check post-converion rates re fraction->frequency
            datatype.type='frequency'; %reclassify type
            [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype); %call again with transformed data
%             [CDs FAs MDs CRs sum([CDs FAs MDs CRs]) hitRate falseRate] %uncomment to check nudged results.
        catch
            disp('datatype struct incomplete in SAtb fn evaluate.m')
            disp('help evaluate  %<-- triple-click % [RETURN] for more info.' )
        end
        
    otherwise %no valid type specified
        disp('datatype struct incomplete in SAtb fn evaluate.m')
        disp('help evaluate  %<-- triple-click % [RETURN] for more info.' )
        %Does data set seem to contain fractions or integers?
        datatype.type='frequency'; %give default type...
        [maxCD i]=max(CDs);
        [maxMD j]=max(MDs);
        myset=[maxCD MDs(i) maxMD CDs(j)]; %examine max CD and corresponding MD.
        if sum(find(myset==0))<4 %if it's NOT all zero's... %if any part of set ~= zero then make fract
            if ((maxCD<=1 && MDs(i)<=1) || (maxMD<=1 && CDs(j)<=1)) %...and it IS all <0
                datatype.type='fraction'; %reclassify type
            end
        end
        [CDs FAs MDs CRs hitRate falseRate]=do_nudge(CDs,FAs,MDs,CRs,datatype); %call again with transformed data
end %switch datatype.type
% [CDs FAs MDs CRs] %uncomment to check
end