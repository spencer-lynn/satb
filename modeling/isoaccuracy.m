function isoaccuracy(scenario)%SAtb Function: isoaccuracy%Estimate accuracy (proportion correct)  in (d',c) SxB/LOR-space for a scenario as dist'n variance changes.%%Usage: isoaccuracy(group)%       where group is a set of signal parameters defined at top of the .m-file%% Requires ML's Statistics Toolbox because uses NORMCDF fn. % (Will return an error about normcdf and doubles if tb not available.)%% (Based on util_space, 12/23/10)% (Based on compare_params (6/11/08))% (Based on siggy.m, but with bug fixes)% Implementation of classic SDT util function using NORMCDF (whereas older SigBE program uses Weibull fn)% Implementation of hotspot util using NORMPDF%% Change log:% 11/10/12 - started% %TO DO:%-still some out of range errors when x_range not big enough?%%%%%%%%%%%%%%%global sxb %a struct with params for running "iso" calcs in SxB space.%clc %clear ML command windowrunflag=1;sxb.flag=0;scenario=num2str(scenario); %in case user enters just a numberswitch scenario %controls which group of param sets to run    case 'sap2'         vary_sim_sap2brate %use for SAP2,SIG4    otherwise        runflag=0;        disp('Scenario not recognized.')endif runflag==1    mainendend %compare paramsfunction vary_sim_sap2brate %bxd for sap2 base rate scenarioglobal h j a m muSplus muSminus var1 var2 alphaglobal sxb isospace gmiscsxb.flag=1;gmisc.roc=false; %plot some type of ROC curvegmisc.rocbias=false; %plot an isobias curvegmisc.isobias=[nan nan nan nan]; %init four collums for appending later%Resolution of possible threshold locations%-sacrifice this for higher #reps, if necc.%(causes big increase in #pts but not spread out efficientlysxb.xstep=.5;%set lower range for threhold (contrains liberalness of modeled bias).%- fill in bias points at end of a d' columnsxb.x_range.min=-20; %set upper range for threshold (contrains conservativeness of modeled bias)%- x_range need to encompass full threshold range or d',c get truncated.sxb.x_range.max=130; %number variants in varied variable. %- More variants = higher res util surface plotsxb.reps=150; sxb.rows=((sxb.x_range.max-sxb.x_range.min)/sxb.xstep)isospace=zeros(((sxb.rows+1)*sxb.reps),3)*NaN; %init for filling in for-loop below%Init params as array of values for each manipulation run%To plot relationship of optimal bias for decreasing d' at given pay,base rate% varies d' over several steps (payoff, baserate = constant)% Successively lower d' by increase S+ & S- variance in sync.%starting MIN sets max d' and controls max threshold range%ending MAX gets data nearer d'=0.var1=linspace(.75,15,sxb.reps); %variance of signal 1h=ones(1,sxb.reps)*10; %h cd of mimic, benea=ones(1,sxb.reps)*-7; %a fa of model, costm=ones(1,sxb.reps)*-3; %m md of mimic, costj=ones(1,sxb.reps)*10; %j cr of model, benealpha=ones(1,sxb.reps)*.25; %P[signal 1], S+muSplus=ones(1,sxb.reps)*7; %mean of signal 1 (S+)muSminus=ones(1,sxb.reps)*5; %mean sig 2, usu S- to right of S+var2=var1; %variance signal 2checkerr%Parameter Error Checkingend %parameter set def'n%% BEGIN MAIN CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%function mainglobal h j a m muSplus muSminus var1 var2 alphaglobal response measures x_range threshold hs_ara cl_ara fa_ara cd_ara md_ara cr_ara Splus_distn Sminus_distn pfa2 yint hstloc minhotspotloc maxhotspotlocglobal sxb isospace gmiscif sxb.flag    x_range=sxb.x_range.min:sxb.xstep:sxb.x_range.max; %set wide x-range to deal with extreme threshold arising from high var    diary('util_sxb-space diary.txt')else    % xstep=.02; %controls sensory acuity after a fashion    % x_range=rounder(-15:xstep:15,50);    xstep=.1; %controls sensory acuity after a fashion    x_range=1:xstep:11; %overwrite above xrangeend%init plot windowssigplot=figure;%h2=axes %('Position',[0.1300 0.1100 0.7750 0.8150])%h1=axes('Position',get(h2,'Position')) %make a 2nd axishold on; zoom onif gmisc.roc    rocplot=figure;    hold on; zoom onend%init measurements data matrixmeasures=ones(length(muSplus),11)*NaN; %cols=P[CD] P[FA] Slope Tloc HSloc prec accur dpr biasfor i=1:length(muSplus) %loop for each series of param settings    % settings for EVALUATE    datatype.type='fraction';    datatype.baserate=alpha(i);    datatype.numTrials=20000; %Adjust this higher if get non-monotonic hiccoughs in performance measures (d', betag)            %CLASSIC CALCS = use normCDF. normcdf=integral from -INF to x:    %if muSplus(=S+) is less than muSminus(=S-) (attack to left of threshold) CD & FA =normcdf, MD & CR =1-normcdf    %if muSplus(=S+) is more than muSminus(=S-) (attack to right of threshold) CD & FA =1-normcdf, MD & CR =normcdf        if(muSplus(i)<muSminus(i)) %S+ to left of S- on increasing x-axis        cd_ara=normcdf(x_range,muSplus(i),var1(i));        fa_ara=normcdf(x_range,muSminus(i),var2(i));    else %S+ to right of S- on increasing x-axis        cd_ara=1-normcdf(x_range,muSplus(i),var1(i));        fa_ara=1-normcdf(x_range,muSminus(i),var2(i));    end    md_ara=1-cd_ara;    cr_ara=1-fa_ara;            %Calc slopes of ROC at each point = [(y2-y1)/(x2-x1)].    diff_cd=diff(cd_ara);    diff_fa=diff(fa_ara);    slope_ara=diff_cd./diff_fa;        S=eval('((1-alpha(i))*(j(i)-a(i)))/(alpha(i)*(h(i)-m(i)))'); %Slope of indifference line.    classic_util='cd_ara*alpha(i)*h(i)+alpha(i)*m(i)*md_ara+(1-alpha(i))*a(i)*fa_ara+(1-alpha(i))*j(i)*cr_ara'; %Classic Utility.    cl_ara=eval(classic_util); %Generate utilty curve        %% Extra bits for sxb util space    if sxb.flag %For each version of the utility fn (ie, each change in variances) output the util and it's coordinates.        %         size(evaluate([cd_ara' fa_ara' md_ara' cr_ara'],'dprime',datatype))        %         size(cl_ara)         us=[evaluate([cd_ara' fa_ara' md_ara' cr_ara'],'dprime',datatype) evaluate([cd_ara' fa_ara' md_ara' cr_ara'],'c',datatype) cl_ara'];        if i>1             first=last+1;        else                        first=i;            [r c]=size(us);        end        last=(first+r-1);        isospace(first:last,:)=us;         %         first=(i*sxb.rows)-(sxb.rows)+1;%         last=(i*sxb.rows)+2;%         [first last (last-first)]%         isospace(first:last,:)=us;    end    %%    %Find best match to S in slope_ara:    %hitlist: this is inherited from SigBE.m, siggy.m and is buggy for var2>var1    %Original: hitlist=find(slope_ara<=S); %slope_ara index numbers to hits.    %I think I also mistakenly used this loc to read into cd,fa aras to get pCD at    %t-loc...but that's incorrect. To get t-loc from hitlist, back-calc to    %get loc of pCD from cd-ara into cl_ara.    %New hitlist 3/21/08:    s_ara=ones(1,length(slope_ara))*S; % make array of size, filled with S value    s_ara=slope_ara-s_ara; %subtract one from another    s_ara=s_ara.*s_ara; %square the differences    hitlist=find(s_ara==min(s_ara)); %the smallest sqare difference locates the closest match to S.    hitslope=slope_ara(hitlist); %return array of matches to S (identical-value, closest match)        %Used to use old hitlist to get these, but was incorrect. Now use CDF.    pCD=cd_ara(find(cl_ara==max(cl_ara)));    pFA=fa_ara(find(cl_ara==max(cl_ara)));    threshold=x_range(find(cl_ara==max(cl_ara))); %Get the threshold location        %Some params settings will force extreme t's; result in multiple identical    %extreme values. Just pick one.    if (length(pCD)>1 || length(pFA)>1 || length(threshold)>1)%         pCD=pCD(end); %use last%         pFA=pFA(end);%         threshold=threshold(end); %some params will force multiple extreme t's (all equal, eg at max)        pCD=pCD(1); %use first        pFA=pFA(1);        threshold=threshold(1); %some params will force multiple extreme t's (all equal, eg at max)        disp('Multiple pCD, pFA or threshold estimates. Using first.')    end    if (S==0 || S>100)        disp('Extreme threshold location')    end        %Indifference Line using using new HitSlope and accurate pCD,pFA    yint=pCD-(hitslope(1)*pFA); %y-intercept    pfa2=((1-pCD)/hitslope(1))+pFA; %pFA value when pCD=1 = top of indifference line: based on S=[(y2-y1)/(x2-x1)]        %HOTSPOT CALCS = use normPDF    Splus_distn=normpdf(x_range,muSplus(i),var1(i));    Sminus_distn=normpdf(x_range,muSminus(i),var2(i));    hotspot_util='(Splus_distn*alpha(i)*h(i)+Sminus_distn*(1-alpha(i))*a(i))-(Splus_distn*alpha(i)*m(i)+Sminus_distn*(1-alpha(i))*j(i))'; %HotSpot utility fn.    hs_ara=eval(hotspot_util); %Generate utilty curves        %Get the max hotspot location on x-axis.    maxhotspotloc=x_range(find(hs_ara==max(hs_ara)));    minhotspotloc=x_range(find(hs_ara==min(hs_ara)));        pMD=1-pCD;    pCR=1-pFA;        precision=evaluate([pCD pFA pMD pCR],'precision',datatype);    accuracy=evaluate([pCD pFA pMD pCR],'accuracy',datatype);    dprime=evaluate([pCD pFA pMD pCR],'dprime',datatype);    bias=evaluate([pCD pFA pMD pCR],'bias',datatype);                %Get the zero of hotspot location on x-axis. There's an easier way to do this with calculus, but...    if ~isempty(find(hs_ara<0)) %Eg, for extreme threshold locations HS doesn't cross zero..."has no zero"        [mx maxi]=max(hs_ara);        [mn mini]=min(hs_ara);        if maxi>mini            hszero_ara=hs_ara(mini:maxi); %get portion of HS encompassing zero        else            hszero_ara=hs_ara(maxi:mini); %get portion of HS encompassing zero        end        hs2_ara=hszero_ara.*hszero_ara; %sqare values so can find point closest to zero        zero2=min(hs2_ara); %min value, sqaured        zero2loc=find(hs2_ara==zero2); %index to min sqaured value within partial array        hszero=hszero_ara(zero2loc); %unsquared value nearest zero within partial array; can be >1 value (=symmetric +/- 0)        if length(hszero)>1            hszero        end        hszeroloc=find(hs_ara==hszero(1)); %index within full array to "zero" value(s).        hstloc=x_range(hszeroloc); %x-range location of HS-derived threshold    else        disp('Hotspot fn has no zero. Cannot determine threshold location.')    end        %Transform hotspot in to response probability gradient    response=(hs_ara-min(hs_ara))/(max(hs_ara)-min(hs_ara)); %Linear scaling to [0,1].        %Log results    measures(i,:)=[pCD pFA S threshold maxhotspotloc precision accuracy dprime bias max(cl_ara) max(hs_ara)];            %Update plots    plotsignals(sigplot)    if gmisc.roc        plotroc(rocplot)    end    end %for-loop of param settings%figure(sigplot) %activate specified figure%set(h1,'YAxisLocation','right','Color','none','XTickLabel',[])%set(h1,'XLim',get(h2,'XLim'),'Layer','top')%Write estimates at optimal (ie, max util) for the scenario (and any variations)disp('AT MAXIMUM UTILITY:')disp('    P[CD]     P[FA]     Slope     Threshold    HotSpot')measures(:,1:5)disp('  Precision  Accuracy   dPrime      Bias   maxCl Util  maxHS Util')measures(:,6:end)writefiles %write datafile of utility at each x-axis point (only for last variant of scenario if >1 requested)if sxb.flag    isospace    surfaceplotting2('isospace','Sensitivity','Bias','Utility','Utility')end;if gmisc.rocbias%     gmisc.isobias% Trim output if bias = betaG:% i=gmisc.isobias(:,3)>3;% gmisc.isobias(i,:)=NaN;surfaceplotting2('isobias','P[FA]','P[CD]','Bias','Bias',gmisc.isobias)end%% plot series of measures over variation in a parameter%plot(measures(:,4),measures(:,6),'go',measures(:,4),measures(:,7),'ro')end %%%%%%%%%%%%% End MAIN %%%%%%%%%%%%%%%%%%%function writefilesglobal response hs_ara cl_ara x_range fa_ara cd_ara Splus_distn Sminus_distn measuresdisp('comp_params__out.dat column headings:')disp('hotspot_util x_range classic_util cd_ara fa_ara Splus_distn Sminus_distn Response_Probs')dataout=[transpose(hs_ara) transpose(x_range) transpose(cl_ara) transpose(cd_ara) transpose(fa_ara) transpose(Splus_distn) transpose(Sminus_distn) transpose(response)];cd('/Users/spencer/Downloads') %path to expt programing folder on Spencer's laptopsave 'comp_params_out.dat' dataout -ASCII -TABSend %%%%%%%%%%%%% End WRITEFILES %%%%%%%%%%%%%%%%%%%function plotsignals(fighandle)%    FIGURE 1: Plot signal PDFs, threshold, hotspot util fn.%    PDF1 - blue (model: CR/FA), mean=0; PDF2 - red (mimics:CD/MD). Eat everything to right of t.global  response x_range threshold hs_ara cl_ara cd_ara fa_ara    Splus_distn Sminus_distn hstloc minhotspotloc maxhotspotlocfigure(fighandle) %activate specified figureplot(x_range,Splus_distn,'g','LineWidth',2) %Distn of S+.plot(x_range,Sminus_distn,'b','LineWidth',2) %Distn of S-.%plot(x_range,cd_ara,'g') %CDF envelope of S+.%plot(x_range,fa_ara,'b') %CDF envelope of S-.plot(x_range,cl_ara,'k') %classic util fnplot([threshold threshold],[-.1 .2],'r','LineWidth',2) % threshold% plot([hstloc hstloc],[-.1 .1],'k') % threshold as zero of HotSpot fn% plot(x_range,hs_ara,'r') %hotspot util fn% plot([minhotspotloc minhotspotloc],[-5 5],'r') % min  of HotSpot fn% plot([maxhotspotloc maxhotspotloc],[-5 5],'r') % max of HotSpot fn% plot(x_range,response,'r') %HS response probability gradient (lin scaled HS fn)%   SEE: edit 'unused eqs.m' for more plots.end %%%%%%%%%%%%% End  %%%%%%%%%%%%%%%%%%%function plotroc(fighandle)%    FIGURE 2: Plot ROC & Indifference Lineglobal cd_ara fa_ara md_ara cr_ara pfa2 yint gmiscfigure(fighandle)if gmisc.rocbias %make isobias curve    datatype.type='frequency';    biases=evaluate([cd_ara' fa_ara' md_ara' cr_ara'],'betag',datatype); %get bias values for each point on roc    plot3(fa_ara,cd_ara,biases)    gmisc.isobias=[gmisc.isobias;[fa_ara' cd_ara' biases biases]];else    plot(fa_ara,cd_ara,'m')    plot([0 pfa2],[yint 1],'k') %Indif line.end%   SEE: edit 'unused eqs.m' for more plots.end %%%%%%%%%%%%% End  %%%%%%%%%%%%%%%%%%%function checkerrglobal h j a m muSplus muSminus var1 var2 alphadirection='left';for i=1:length(h)    if (h(i)<j(i) || j(i)<a(i) || h(i)<a(i))        disp('Note: odd payoff values')    end    if (j(i)<a(i) || h(i)<m(i))        disp('Error: bad payoff values; negative indifference slope')    endendend %check errors