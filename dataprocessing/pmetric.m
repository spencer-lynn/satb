function response_gradient=pmetric(flt_objname,flt_behavior,stimnames,measure)
%% Find mean response for each stimulus -- psychometric fn for threshold response data (x=stim num, y=p(response1))
%  flt_objname,flt_behavior are the data, filtered from the raw data file, on which to operate
%
%Updates:
% 11/23/09 - added "numshows" to psychometric output. Older code must be modified to handle new struct output.
% 2/20/11  - added new outputs beyond first 4 basic summations.. 
%          - changed var names: response_gradient.sum -> ".pstim"; .behav -> ".sum"
% 6/12/11  - added new summation output = response_gradient.ppress: signed proportion relative to each local stim presses. 
% 9/7/11   - added gradient expressions as proportion of total presses +
%            #stims (see adj = adjusted, below). Now using adj rather than pstim,norm for
%            further processing.
% 1/24/12  - added Grusec mean output for separate pos and neg button use.
% 3/8/13   - Added "target" and "foil" keypress gradient output to psychometric measure (same as summation measure)

numStimuli=length(stimnames);
stimuli=zeros(1,numStimuli);
switch measure
    case 'summation' %Summation of behavior (eg, for peak shift), y=0 is threshold
       %% Summation gradient (return NaNs when stimct=0).
        rgradient=zeros(1,numStimuli);
        stimct=zeros(1,numStimuli);
        for t=1:size(flt_objname,1) %Check every trial (if use numbers rather than stimnames, could make logidx)
            matchindex=strmatch(flt_objname(t),stimnames); %find the current stim's ID#
            rgradient(matchindex)=rgradient(matchindex)+flt_behavior(t); %Update the behavioral record
            stimct(matchindex)=stimct(matchindex)+1; %keep running ttl of #presentations each stim
        end
        response_gradient.sum=rgradient; %return summed behavior at each stim. Can be used in "mean shift" analysis.
        response_gradient.stimct=stimct; %return the number of times each stim shown (barring any response time filters)
       
        
        %% Count gradients: Get count of different beh codes given to each stim (can be used for Grusec's "mean shift")
        %These peaks will show less shift than "pstim" and derivatives because the influence of the competing responses are not included.
        for i=1:numStimuli
            matchindex=strcmp(stimnames(i),flt_objname); %get all trials of stimID=i
            response_gradient.ct_nonzero_presses(i)=numel(nonzeros(flt_behavior(matchindex))); %Count (not sum!) of non-zero responses to ea stim.
            response_gradient.ct_pos_presses(i)=numel(find(flt_behavior(matchindex)==1)); %Freq ppt said "target"
            response_gradient.ct_neg_presses(i)=numel(find(flt_behavior(matchindex)==-1)); %Freq ppt said "foil"
        end %for each stim
        
        
        %% Gradients as proportions
        numpresses=sum(response_gradient.ct_nonzero_presses);%ttl# target + foil presses (ie, non-zero response codes).
        response_gradient.pstim=rgradient./stimct; %return P["go"] per ea stim's #shows. (Was called .sum)
        %response_gradient.pttlstim=rgradient./sum(stimct); %return P["go"] per ttl #stims shown. May differ from others if #trial/stim not equal.
        response_gradient.padj=rgradient./(stimct.*numpresses); %Summation gradient adjusted for #stims (eg, in case some lost to RT-filter) and for ttl#presses (ie, vigor)
        response_gradient.ct_nz_adj=response_gradient.ct_nonzero_presses./(stimct.*numpresses);
        response_gradient.ct_pos_adj=response_gradient.ct_pos_presses./(stimct.*numpresses);
        response_gradient.ct_neg_adj=response_gradient.ct_neg_presses./(stimct.*numpresses);
 
        
        %% arc-sine trasform of proportions
        response_gradient.sum_asin=asin_xform(response_gradient.sum,stimct.*numpresses);
        response_gradient.posct_asin=asin_xform(response_gradient.ct_pos_presses,stimct.*numpresses);
        response_gradient.negct_asin=asin_xform(response_gradient.ct_neg_presses,stimct.*numpresses);
        %Uncomment to check uncomment to check. Expect only an approximate match for F&T xform.
        %reverse_check=[abs(response_gradient.ct_pos_adj);sind(response_gradient.posct_asin).^2]

                
        %% Signed P(press) at each stim relative to LOCAL #presses (rather than tt#presses or #stims shown).
        %response_gradient.ppress=response_gradient.sum./response_gradient.ct_nonzero_presses; %return signed press rate relative to #presses delivered to each stim (whether as S+ or S-)       
        % - this can overweight "strength" of stims that received few presses, leading to broader peasks.
        % - but can "correct" for errant foil responses in strongly target ranges, for example.
        % = Consider using for corrections of indiv ppts odd data, but I don't think this is right for primary processing.
        
        
        %% Linear scaling of "padj" summation gradient
        %...such that P["target"]is >0, P["foil"] is <0 :
        %-Deterimin maxPOS minNEG by which to scale preserving relative p-target vs p-foil probabilities.
        %-The largest (abs val) util (whether to target or foil) becomes
        %the P[response]=1 limit on the scale.
        %-The rest of the utility values are scaled relative to that.
        %-Rel. to other measures, this will fine tune curve of ppts who did not have 100% hits to any stim -- norm them to rest of sample.
        maxHS=max(response_gradient.padj);
        minHS=min(response_gradient.padj);
        if abs(maxHS)>=abs(minHS)
            new_max=maxHS/maxHS;
            new_min=minHS/maxHS;
        else
            new_min=(minHS/minHS);
            if minHS<0;new_min=new_min*-1;end %make negative if needed.
            new_max=abs(maxHS/minHS); %should be positive
        end%if
        response_gradient.norm=normalizer(response_gradient.padj,new_min,new_max); %Linear Scaling
        
        
        
        %% Grusec's location of ave response strength (must use raw count gradients for this shortcut calc method)
        %-over all stimuli: sum(response strength * signal value)/numpresses
        %         For example:
        %         Grusec_bsln_pos=(
        %         (BSLN_testing_pos1*1)+
        %         (BSLN_testing_pos2*2)+
        %         (BSLN_testing_pos3*3)+
        %         (BSLN_testing_pos4*4)+
        %         (BSLN_testing_pos5*5)+
        %         (BSLN_testing_pos6*6)+
        %         (BSLN_testing_pos7*7)+
        %         (BSLN_testing_pos8*8)+
        %         (BSLN_testing_pos9*9)+
        %         (BSLN_testing_pos10*10)+
        %         (BSLN_testing_pos11*11)
        %         )/BSLN_testing_numPOSPresses;
        response_gradient.pos_grusec=sum(response_gradient.ct_pos_presses.*(1:1:numStimuli))/sum(response_gradient.ct_pos_presses);
        response_gradient.neg_grusec=sum(response_gradient.ct_neg_presses.*(1:1:numStimuli))/sum(response_gradient.ct_neg_presses);

        

        %% "ave-peak" locations: Return indice(s) (ie, stim IDs) locating the max response probabily (for POS and NEG shift). 
        %- Get average of tied response strengths over different stim-values: Mean (vs median) appears to give larger shift.
        
        %From adj count gradients
        max_indices=find(response_gradient.ct_pos_adj==max(response_gradient.ct_pos_adj)); %Return indice(s) of max response probabilies.
        min_indices=find(response_gradient.ct_neg_adj==max(response_gradient.ct_neg_adj)); %Return indice(s) of max response probabilies.
        response_gradient.pos_ctpeak_stimid=mean(max_indices); %POS peak location (mean of ties)
        response_gradient.neg_ctpeak_stimid=mean(min_indices); %NEG peak location (mean of ties)        

        %From adj summation gradient. Using summation gradient has difficulty w/ min peak =0 (rather than <0).
        max_indices=find(response_gradient.padj==max(response_gradient.padj)); %Return indice(s) of max response probabilies.
        min_indices=find(response_gradient.padj==min(response_gradient.padj)); %Return indice(s) of min response probabilies.
        response_gradient.pos_sumpeak_stimid=mean(max_indices); %POS peak location (mean of ties)
        response_gradient.neg_sumpeak_stimid=mean(min_indices); %NEG peak location (mean of ties)

        %Use ppress summation gradient 
        % max_indices=find(response_gradient.ppress==max(response_gradient.ppress)); %Return indice(s) of max response probabilies.
        % min_indices=find(response_gradient.ppress==min(response_gradient.ppress)); %Return indice(s) of min response probabilies.
        % response_gradient.pos_peak_stimid=mean(max_indices); %POS peak location (mean of ties)
        % response_gradient.neg_peak_stimid=mean(min_indices); %NEG peak location (mean of ties)

       
        %% GET X-INTERCEPT RE y=mx+b
        % Turns out trying to suss this via mean min/max location isn't very
        % effective. So I wrote separate code neededing user input.
        %         minx1=response_gradient.neg_pstim_stimid;
        %         miny1=minHS;
        %         maxx2=response_gradient.pos_pstim_stimid;
        %         maxy2=maxHS;
        %         slope=(maxy2-miny1)/(maxx2-minx1); %calc. slope
        %         yint=miny1-slope*minx1; %solve for y-intercept
        %         response_gradient.xint=(0-yint)/slope %x-intercept
        
        
    case 'psychometric' %Classic sigmoid psychometric fn
        response_gradient.pm=zeros(1,numStimuli); %2d: subblocks,stimuli. preallocate prior to for loop
        numshows=response_gradient.pm*NaN; %track number of times each stimulus shown to ppt. prealloc prior to loop
        xobjname=flt_objname;
        xbehavior=flt_behavior;
        go=xobjname(find(xbehavior==1)); %list of all stims that got "go" responses; a cell array so use strcmp
        for c=1:numStimuli
            numshows(c)=sum(strcmp(stimnames(c),xobjname)); %number of times stim c was shown
            pm=strcmp(stimnames(c),go); %use strcmp to return logical mask of every time stim c recieved a go response.
            stimuli(c)=sum(pm)/numshows(c); %MEAN =p(go)|number of opportunities to go.
            %   Returns NaN if numshows=0 so that non-presented stimuli do not get a response rate = 0
            %   (important for accurate threshold calc re extreme >t stims)
            
            %Count or "key-press" gradients: Get count of different beh codes given to each stim
            matchindex=strcmp(stimnames(c),flt_objname); %get all trials of stimID=i
            response_gradient.ct_pos_presses(c)=numel(find(flt_behavior(matchindex)==1)); %Freq ppt said "target"
            response_gradient.ct_neg_presses(c)=numel(find(flt_behavior(matchindex)==-1)); %Freq ppt said "foil"

        end %for each stim
        response_gradient.pm=stimuli;
        response_gradient.ct=numshows;
        
end %switch

% response_gradient
end %%fn

function asin_gradient=asin_xform(numerator,denominator)
%SAtb fn asin_gradient: Get arc-sine transform of proportions
%From Zar, p240
%Proportions, percentages are binomial distn.
%p'=arcsin(sqrt(p)) (in units of degrees or rads)
%can transform from degrees back to proportion by p = (sin p')^2.
%eq 14.5 = Freeman & Tukey (1950) modification if numerator & denominator are known.
% =0.5*(ASIN(SQRT(cellct/(ttl+1)))+ASIN(SQRT((cellct+1)/(ttl+1))))

negindx=(numerator<0)*-1; %get indices of negatative values (S- responses).
posindx=(numerator>=0); %get indices of negatative values (S- responses).
logindx=negindx+posindx;

%% Basic transform; easy but inaccurate near p=0,1.
% gradient=[0 0.0145 0.0326 0.0435 0 0.0109 0.0435 0.0326 0.0109 0 0];
% asin_gradient=asind(sqrt(abs(gradient)));
% reverse_check=[abs(gradient);sind(asin_gradient).^2] %uncomment to check uncomment to check. Will match approximately for F&T, exactly for Basic.

%% Overwrite using Freeman & Tukey (1950) modification
asin_gradient=0.5 * (asind(sqrt(abs(numerator)./(denominator+1))) + asind(sqrt((abs(numerator)+1)./(denominator+1))));
%reverse_check=[abs(gradient);sind(asin_gradient).^2] %uncomment to check uncomment to check. Will match approximately for F&T, exactly for Basic.

asin_gradient=asin_gradient.*logindx; %code S- responses back to negative
%This will now perhaps have negative degrees (-90..0.+90) but not a circular-data problem (where ave(270,10)~320 deg).
end
