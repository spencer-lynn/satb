function roc=roc_from_confidence(direction,stimnames,rating_values,rating_measure,objname,behavior,s_stimname,s_respcode,signalsources,flt_rating,face_outcomes,flt_face_behavior,verboseflag)
%% SAtb fn: roc_from_confidence()
%Calculate, fit, plot, and return points defining participant's ROC plots as determined from confidence ratings
% 
%Parameters 
%     direction='right'; %OPTIONS: 'right' | 'left'= "Go"-side of threshold.
%     stimnames={'stim1.tif' 'stim2.tif' ... };
%     rating_values=1:9;
%     rating_measure='average'  Take mean of ratings for each stimulus
%                    'maximum'  Use maximum of ratings for each stimulus rated. Sounds good but can have the effect of decreasing count of common mid-ratings
%                    'separate' Use each separate rating given
%     incoming data = pairs of rows: row1=stim, row2=rating 
%              - objname=stimnames from filtered dat file
%              - behavior=behavior codes from filtered dat file
%              - s_stimname=stimulus_name field from signal-drawn trials (NOT confidence-rated trials)
%              - s_respcode=response_code field from signal-drawn trials (NOT confidence-rated trials)
%             ...added 7/8/16:
%             - signalsources=bayes estimate of signal source
%             - flt_rating=ratings given to each rated face
%             - face_outcome=decision outcome (preceding the rating), given bayes signal source
% 
%     verboseflag = T/F, controls ploting and writing results to cmd window
%     output = roc is a struct of all the outputs.
% 
%Notes
% - 20160709 Endpoints of ROC are forced to 0,0; 1,1.
% - This fn determines subjectively experienced pCD,pFA for each stimulus, based on the signal-drawn trials
% - This fn expands the rating scale: max rating|FOIL=100% conf that stim was a foil...min rating=indifferce pt, 100% guess, midpt of criterion...max rating|TARGET=100% conf target. 
%   Older verions inverted ratings given to FOILs.
% - 20160709 This fn WAS for confidence intervals sampled just a few times (eg 2x for each stimulus value), not taken on every trial (conventional method).
%    - I think because I obtain conf ratings on few trials (vs every trial), I wasn't doing the actual "rating method" in earlier versions. 
%      So, I was trying to leverage experienced probabilities of each stimulus. But I think that was shaping everyone's data (to look pretty ideal). 
%      This fn now does std rating method....so the more conf rated trials, the better the results.
% - 20160709 For OTD data (with 10 ratings for each stim) this method works pretty well (and clearly original method was bogus).
% 
%ROC
% X-axis: Proportion of FOIL trials rated as conf=1...conf=n.
% Y-axis: Proportion of TARGET trials rated as conf=1...conf=n.
%
%Change Log
% 03/03/09: ~started, as 2nd processing step: open original data files and processed them.
%           In SAP2, objnums (=stim ID#s) were over written by stimdur at run time, so was hardcoded below in stimnames
% 03/07/13: Original version depricated.
%           Rewritten to be called w/in EXPT_process.m scripts, but leaving basic functionality and processes unchanged.
%           But: numsubjects=1; %we'll only be passing in 1 person's data on each call.
% 06/16/15: Adding roc_stats procedure to get area under ROC, slope of zROC
%           Changed output from the ROC points [pCD,pFA] to a struct of all outputs.
%           Added call to trapz rather than my reimann scrip for ROC area.
% 06/19/15: Using MLE rather than OLS/LSE to get zROC slope
%           Removed n>1 ppts nomenclature/referencing (except in PlotROC fn)
%           Moved all verbose reporting to main fn
%           Tried to improve number of usable zROC points via nudge 0,1 in pFA, pCD: DIDN'T WORK
% 20160703 - Depricated prior mfile.
%          - In extract_ratings, assign_rocpts fns: replaced invertion of ratings to foils with expanded ratings scale (100 foils..indifferent guess..100% target. 
%          - This works because ROC is done over rating values, doesn't need to be expressed in terms of target confidence. This is how it's typically done.
% 20160709 - I think because I obtain conf ratings on few trials (vs every trial), I wasn't doing the actual "rating method" in earlier versions. 
%            (I was trying to leverage experienced probabilities of each stimulus). But I think that was shaping everyone's data to look pretty ideal. 
%            This fn now does std rating method.
%          - had to FlipLR for pCD,pFA in roc area fn
% 
%To do
% - subjective experienced base rate and stim presentations not really ROC-calc related, per se, so should be stand alone fns.
% - There will be expts, ppts that generate pFA, pCD = 0 at some confidence levels? I need to implement a correction for those.
%       - currently, looks like the code would return a pXX=0 result.
% - Is the old experienced alphas for each stim still useful at all?
% - Considered norming range w/in ppt (prior to processing) or at least examining the effect of biased scale use on outcomes.
%   -add  myratings=normalizer(myratings,1,17); %Norm each ppts ratings to cover full range, put everyone on same scale.
% 
% - ols and mle routines seem to fail for unknown reasons on some OTD ppts:
%   ...in that case perhaps fall back to a simpler method?
% - get r-sq measure of ROC shape?...for unequal var?
% - replace old nomenclature (eg, objtype) throughout.
% - elimination of for-loops (see "inverse" below for start)
%% %%%%%%%%%%%%%%%%%%%%%

verboseflag=0;

%preallocate matrices
numStimuli=numel(stimnames);
%DEPRICATED roc.ratings=zeros(numStimuli)*NaN; %ratings on each stimulus.
roc.alphas=zeros(numStimuli,2)*NaN; %2d: number presentations for each stim as S+, S-.
roc.pCD=zeros(max(rating_values))*NaN;
roc.pFA=zeros(max(rating_values))*NaN;
roc.zROCstats.slope=NaN;

flt_rating=expand_ratings_range(rating_values,flt_rating,flt_face_behavior);
[roc.pCD,roc.pFA]=assign_rocpts(rating_values,flt_rating,signalsources);


%DEPRICATED roc.ratings=extract_ratings(rating_measure,stimnames,numStimuli,rating_values,objname,behavior); %average of number of times each stimulus was rated, for each subject
[roc.alphas(:,1),roc.alphas(:,2),roc.expr_baserate]=extract_presentations(stimnames,numStimuli,s_stimname,s_respcode);
%DEPRICATED [roc.pCD,roc.pFA]=assign_rocpts_old(direction,rating_values,roc.ratings,roc.alphas,signalsources,flt_rating,face_outcomes,flt_face_behavior);
roc.area=roc_area(roc.pFA,roc.pCD);
roc.zROCstats=zROC_fit(roc.pFA,roc.pCD);

if verboseflag
    roc   
    [roc.pCD' roc.pFA']   
    roc.zROCstats
    
    %plot ROC curve
    plotROCs(roc.pCD,roc.pFA) 
    axis([0 1 0 1]) %square the axes
        
    %plot zROC
    figure; hold on
    xmin=min(roc.zROCstats.zFA(roc.zROCstats.validFA));
    xmax=max(roc.zROCstats.zFA(roc.zROCstats.validFA));
    ymin=xmin;
    ymax=xmax;
    rocy1=roc.zROCstats.slope*xmin+roc.zROCstats.intercept;
    rocy2=roc.zROCstats.slope*xmax+roc.zROCstats.intercept;
    plot(roc.zROCstats.zFA,roc.zROCstats.zCD,'ro')
    plot([xmin xmax],[rocy1 rocy2],'b-')
    plot([xmin xmax],[ymin ymax],'k--')
%     axis([min([xmin ymin]) max([xmax ymax]) min([xmin ymin]) max([xmax ymax])]) %square the axes
end
end %% MAIN


function myratings=expand_ratings_range(rating_values,myratings,mybehavior)
%% Get ratings assigned to each stimulus value

%          Exand range from 1:9 to 1:17 (for a original 9-pt rating scale)
%          9 8 7 6 5 4 3 2 1=1  2  3  4  5  6  7  8  9
%          1 2 3 4 5 6 7 8 9=9 10 11 12 13 14 15 16 17
%           ....foils....indiff....targets....

% size([flt_rating  flt_face_behavior]) %uncomment to check
orig_ratings=myratings; %can be compared to verify mods to flt_rating; see below.

% 1. Invert the ratings given to foils, so that 100% conf in foil = rating value 1.
% (just as in prior inversion code.)
inv_rating_values=fliplr(rating_values); %1..9 -> 9..1
sminus=find(mybehavior==-1); %index to all "No/S-/foil" button presses
r=length(sminus); %c not used
for i=1:r %for each S- button press
    %sminus(r) %points to an S- button press in flt_face_behavior, corresponds to rating in flt_rating
    %c=flt_rating(sminus(r)) %c=the rating value (eg, 1..9) given to the current S- press
    myratings(sminus(i))=inv_rating_values(myratings(sminus(i))); %So, replace exiting S- rating with it's inverse.
end
% - below is pretty clever use of logical indexing rather than for-loop
% ratings=flt_rating;%ratings will contain rating as given to targets and inverse rating as given to foils
% flt_rating_mat=repmat(ratings,1,9);%create repeted matrix of RATINGS for lookup table.
% rating_values_mat=repmat(rating_values,numel(ratings),1);%create repeted matrix for lookup table
% inv_rating_values_mat=fliplr(rating_values_mat); %create repeted matrix for INVERSE RATING lookup table
% replacement_index=rating_values_mat==flt_rating_mat; %create logical index of RATINGS into lookup table
% replacement_mat=inv_rating_values_mat.*replacement_index; %grab the INVERSE values of the ratings
% inv_rating_values=sum(replacement_mat,2); %sqeeze into one column, leveraging the zeros from the logical array
% foil_index=flt_face_behavior==-1; %logical index to faces categorized as foils
% ratings(foil_index)=inv_rating_values(foil_index); %replace ratings given to foils with the inverse rating
% [flt_rating inv_rating_values foil_index ratings ] %uncomment to check


% 2. Bump the ratings given to targets, so that 100% conf in target = rating value 17.
% (This is the new code, expanding the scale.)
bump=length(rating_values)-1;
splus=find(mybehavior==1); %index to all "YES/S+/target" button presses
myratings(splus)=myratings(splus)+bump;

% [orig_ratings mybehavior myratings] %uncomment to check that mybehavior now contains inverted S- ratings and extended S+ ratings.


end%% fn

function [probCD,probFA]=assign_rocpts(rating_values,indiv_ratings,signalsources)
%conservative/origin-->liberal
% Assign P[CD] and P[FA] for each level of confidence+.
% In ratings method, this has nothing to do with ppts YES/NO responses, but do need actual source (target or foil) of the signal.

rating_values=1:(max(rating_values)+(max(rating_values)-1)); %recode rating_values for range expansion in extract_ratings fn, 20160703.
probCD=NaN*ones(1,max(rating_values));
probFA=NaN*ones(1,max(rating_values));

numtargets=sum(strcmp('+',signalsources));
numfoils=sum(strcmp('-',signalsources));
for i=max(rating_values):-1:min(rating_values)
% for i=1:1
    yes_indices=find(indiv_ratings>=i); %get indices to trials rated as >=i.
    numCDs=sum(strcmp('+',signalsources(yes_indices))); %now, how many of those YESes were CDs and how many FAs?
    numFAs=sum(strcmp('-',signalsources(yes_indices)));
    probCD(i)=numCDs/numtargets; %return sum total number of deliveries of all S+ stimuli rated as i
    probFA(i)=numFAs/numfoils; %return sum total number of deliveries of all S- stimuli rated as i
end %for
probCD=[probCD 0]; %Append a 0,0 ROC point
probFA=[probFA 0];

%[probCD' probFA']
end %% fn

function [splusCt,sminusCt,expr_baserate]=extract_presentations(stimnames,numStimuli,myobjname,myobjtype)
%% Get number S+,S- presentations for each stimulus value
%Here, myobjtype and myobjname are response_code and stimulus_name fields from signal-drawn trials (NOT confidence-rated trials).
% - this is objective source of each stimulus (response_code) not ppt's categorization of each time (behavior code)

lgPlus=strcmp('+',myobjtype); %filter for targets
lgMinus=strcmp('-',myobjtype); %filter for foils
splusobjname=myobjname(lgPlus); %get stimulus names of objective TARGETS
sminusobjname=myobjname(lgMinus); %get stimulus name of objective FOILS
for s=1:numStimuli
    splusCt(s)=sum(strcmp(stimnames(s),splusobjname));
    sminusCt(s)=sum(strcmp(stimnames(s),sminusobjname));
end
expr_baserate=sum(splusCt)/sum(sum([splusCt;sminusCt])); %experienced base rate
end %% fn

function area=roc_area(probFA,probCD)
%Area under ROC
probFA=fliplr(probFA); %20160709 need to flip ordering, otherwise area is negative.
probCD=fliplr(probCD);
area=trapz(probFA,probCD); %trapezoid method of curve integration
end

function ols=ols_fit(x,y)
%Get Ordinary Least Squares regression through zROC points 
%(ie, straight-line via least-squares estimates)
[fo g o]=fit(x,y,'poly1'); %fit stright line through zROC points
ols.slope=fo.p1;
ols.intercept=fo.p2;
ols.stdev_resids=std(o.residuals); %st dev of Error (or residuals=y - ls_slope.*x - ls_intercept)
end

function mle=mle_fit(x,y)
% See "Carpenter Zoo 535 notes" for best explanation of the logic, for a straight-line fit.
% We want to determine linear fit parameter values (slope, intercept) via maximum likelihood estimation.
% We'll use a linear programming optimization for this:

%1. Define objective fn
    function logLE=estp_error(p,x,y)
        %All params (slope, intercept, stdev of residuals) will be estimated simulaneously from the Error term (ie, residuals).
        E = y - p(1).*x - p(2); %Errors re: y=mx+b. We'll optimize for param values that are best explained by these Error values.
        LE = (exp((-E.^2)/(2.*p(3).^2)))/sqrt(2*pi*p(3).^2); %Likelihood distn of our fn, E(); the distn of errors. We want to find param values that maximize this, Likelihood(E).
        logLE=sum(log(LE)); %Log of the Likelihood is easier to deal with. We want the sum of likelihood over the entire distn.
        logLE=-1*logLE; %Transform that sum into something that can be minimized, since that's how optimization works.
    end

if numel(x)>1 %if there is more than one pt to fit
    %2. Set optimization params
    ols=ols_fit(x',y'); %Estimate optimization starting values via least-squares regression
    p_init=[ols.slope ols.intercept ols.stdev_resids];
    p_lower_bound=[0 -Inf 0];
    p_upper_bound=[Inf Inf Inf];
    options = optimset('fmincon'); %create an options structure
    options = optimoptions('fmincon','Algorithm','interior-point','Display','off' ); %set some options
    % 'Display','off' supresses stop-notifications, so might hide errors from you.
    
    %3. Call optimization routine
    try
        phat=fmincon( @(p,sd)estp_error(p, x, y), p_init, [], [], [], [], p_lower_bound, p_upper_bound, [], options);
        mle.slope=phat(1);
        mle.intercept=phat(2);
        mle.std_resids=phat(3);
    catch myerr
        disp('Error in roc_from_confidence/mle_fit')
        disp(myerr.message)
        mle.slope=NaN;
        mle.intercept=NaN;
        mle.std_resids=NaN;
    end
else
    mle.slope=NaN;
    mle.intercept=NaN;
    mle.std_resids=NaN;
end %if num of points to fit>1
end

function zROCstats=zROC_fit(probFA,probCD)
% zROC slope
%0,1 in pFA,pCDs => -/+inf in NORMINV, which crash fit.m. and limit the number of useable ROC points. 
% So, consider nudging 0s and 1s a small bit, see what that looks like:
% = leads to bad conditioning errors in optimization step. Oh well.

zFA=norminv(probFA);
zCD=norminv(probCD);
validFA=~(isinf(zFA)|isnan(zFA));
validCD=~(isinf(zCD)|isnan(zCD));
valid=validFA & validCD;

%Get zROC slope, intercept using maximum-likelihood estimates rather than via
%regular regression (least squares estimates) because both x and y (pFA, PCD) are estimated, not just y.
zROCstats=mle_fit(zFA(valid),zCD(valid)); %maximum-likelihood estimates via optimization

zROCstats.zFA=zFA; %all x-axis points
zROCstats.zCD=zCD; %all x-axis points
zROCstats.validFA=validFA; %index to usable pts
zROCstats.validCD=validCD; %index to usable pts
end

function plotROCs(probCD,probFA)
%this version coded to plot multiple ppts
numSubjects=size(probCD,1);
symbol={'o-'; 'x-' ;'*-' ;'s-' ;'d-'; 'v-' ;'p-' ;'h-' ;'^-' ;'<-'; '>-'; '.-'}; %plot symbols, combine with other line types if need more
figure; hold on;
colorOrder=jet(numSubjects);
ca={1:numSubjects}; %cell array for building legend
legendText=cell(numSubjects,1); %cell array for building legend
for s=1:numSubjects %for loop not required for actual plot, but needed for using different symbols, construcing legend
 %   plot(probFA(s,:)+s/50,probCD(s,:)-s/50,symbol{s},'Color',colorOrder(s,:),'LineWidth',2) %+/- s/50 staggers x/y points for readability
    plot(probFA(s,:),probCD(s,:),symbol{s},'Color',colorOrder(s,:),'LineWidth',2)
    legendText(s)={num2str(ca{1}(s))}; %a shame to do this so many times, only needs to be done once for ALL plots
end
title('Reciever Operating Characteristic');
legend(legendText)
xlabel('P[FA]');
ylabel('P[CD]');
end %% fn


%% Old fns
function myratings=extract_ratings(rating_measure,stimnames,numStimuli,rating_values,myobjname,mybehavior)
%% Get ratings assigned to each stimulus value

%          Exand range from 1:9 to 1:17 (for a original 9-pt rating scale)
%          9 8 7 6 5 4 3 2 1=1  2  3  4  5  6  7  8  9
%          1 2 3 4 5 6 7 8 9=9 10 11 12 13 14 15 16 17
%           ....foils....indiff....targets....

orig_behavior=mybehavior; %can be compared to verify mods to mybehavior; see below.
% 1. Invert the ratings given to foils, so that 100% conf in foil = rating value 1.
% (just as in prior inversion code.)

         inv_rating_values=fliplr(rating_values);
         % inv_rating_values=rating_values; %uncomment to check effect of rating-inversion
         
         %If a stimulus was classified as S-, get the inverse of it's rating (ie, what would it have been rated if it had been classified as S+?)
         sminus=find(mybehavior==-1); %get indices of the S- classifications: -1 can ONLY code NO keypress.
         r=size(sminus,1); %c not used
         for i=1:r
             c=find(rating_values==mybehavior(sminus(i)+1)); %shift the indices by 1 to refer to the ratings themselves, rather than to the rated stimuli
             mybehavior(sminus(i)+1)=inv_rating_values(c); %replace S- rating with assumed rating if was classed as S+
         end
         % - below is pretty clever use of logical indexing rather than for-loop
         % ratings=flt_rating;%ratings will contain rating as given to targets and inverse rating as given to foils
         % flt_rating_mat=repmat(ratings,1,9);%create repeted matrix of RATINGS for lookup table.
         % rating_values_mat=repmat(rating_values,numel(ratings),1);%create repeted matrix for lookup table
         % inv_rating_values_mat=fliplr(rating_values_mat); %create repeted matrix for INVERSE RATING lookup table
         % replacement_index=rating_values_mat==flt_rating_mat; %create logical index of RATINGS into lookup table
         % replacement_mat=inv_rating_values_mat.*replacement_index; %grab the INVERSE values of the ratings
         % inv_rating_values=sum(replacement_mat,2); %sqeeze into one column, leveraging the zeros from the logical array
         % foil_index=flt_face_behavior==-1; %logical index to faces categorized as foils
         % ratings(foil_index)=inv_rating_values(foil_index); %replace ratings given to foils with the inverse rating
         % [flt_rating inv_rating_values foil_index ratings ] %uncomment to check
         
                  
% 2. Bump the ratings given to targets, so that 100% conf in targte = rating value 17.
% (This is the new code, expanding the scale.)

         bump=length(rating_values)-1;
         r=size(mybehavior,1); %c not used
         for i=1:r
             if ~isequal(myobjname{i},'confidence.jpg') %If row contains a stimulus presesentation,preceding a rating elicitation
                 if  mybehavior(i)==1 %If ppt categorized this stimulus as a target.
                     mybehavior(i+1)=mybehavior(i+1)+bump; %shift the indices by 1 to refer to the ratings themselves, rather than to the rated stimuli
                 end
             end
         end

%[orig_behavior mybehavior] %uncomment to check that mybehavior now contains inverted S- ratings and extended S+ ratings.

 


switch rating_measure
    case 'separate'
    case 'maximum' %Does this do the right thing for inversed (s-) ratings?
        myratings=zeros(1,numStimuli)*NaN; %2d: numsubjects,ratings on each stimulus. Preallocate prior to for loop
        for s=1:numStimuli
            rate=strmatch(stimnames(s),myobjname); %return indices into objname of stimulus names
            rate=rate+1; %increase each index by 1 to get the rating itself for the stimulus name
            myratings(s)=max(mybehavior(rate)); %the rating the subject gave to his/her confidence in the classification decision
        end %for each stimulus
    case 'average'
        myratings=zeros(1,numStimuli)*NaN; %2d: numsubjects,ratings on each stimulus. Preallocate prior to for loop
        for s=1:numStimuli
            rate=strmatch(stimnames(s),myobjname); %return indices into objname of stimulus names
            rate=rate+1; %increase each index by 1 to get the rating itself for the stimulus name
            myratings(s)=mean(mybehavior(rate)); %the rating the subject gave to his/her confidence in the classification decision
        end %for each stimulus
end %switch
end%% fn
function [probCD,probFA]=assign_rocpts_old(direction,rating_values,indiv_ratings,indiv_alphas)
%conservative/origin-->liberal
% Assign P[CD] and P[FA]

rating_values=1:(max(rating_values)+(max(rating_values)-1)); %recode rating_values for range expansion in extract_ratings fn, 20160703.

for i=rating_values
    stimulus_indices=find(indiv_ratings>=i & indiv_ratings<i+1); %get indices to stimulus values rated from i..i+1. Final bin is truncated (eg, no ratings can be 9-10, only 9.)
    probCD(i)=sum(indiv_alphas(stimulus_indices,1)); %return sum total number of deliveries of all S+ stimuli rated as i
    probFA(i)=sum(indiv_alphas(stimulus_indices,2)); %return sum total number of deliveries of all S- stimuli rated as i
end %for
if strcmp(direction,'right')
    probCD=fliplr(probCD);
    probFA=fliplr(probFA);
end
probCD=cumsum(probCD/sum(indiv_alphas(:,1))); %convert to proportions of stimuli delivered per class
probFA=cumsum(probFA/sum(indiv_alphas(:,2)));

end %% fn


