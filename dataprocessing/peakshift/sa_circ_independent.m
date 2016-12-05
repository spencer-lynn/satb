function results=sa_circ_independent(angles,group,magnitudes)
% - First, use peakshift_vector.m to get vector directions (to create the angles in radians)
% - Then, use this to run circular statistics on the directions, compared between groups.
% - group is a numeric group ID (eg, controls=1, patients=2).
% 
%       circ_wwtest(group1_angles, group2_angles)
% - this will compare angles of n btw-subject groups.
% - This test won't handle NaNs in input columns.
% 
% - Output stat results and polar plot.
% 
% CHANGE LOG
% 11/16/12 - Started, with SAP1 data.
% 
% USES
% - CircStat_toolbox for betw-subj tests, descriptives
% - disptable.m for table of descriptives
% 
% TO DO
% - break up parts
% - add legend to plot

%% Exclude observations with angle=NaN.
excluded=isnan(angles);
angles=angles(~excluded);
group=group(~excluded);


%% parametric test
[pval table]=circ_wwtest(angles,group) 
results.ww_pval=pval;
results.ww_table=table;

%% non-parametric test
[pval med Pstat]=circ_cmtest(angles,group) 
results.cm_pval=pval;
results.cm_median=med;
results.cm_Pstat=Pstat;

%% Descriptives table
unigroups=unique(group); %list of unique values
mu=ones(size(unigroups))*NaN;
sd=ones(size(unigroups))*NaN;
med=ones(size(unigroups))*NaN;
n=ones(size(unigroups))*NaN;
rowlables='group1';
colors={'k' 'r' 'g' 'b'};
for ct=1:length(unigroups)
    theta=angles(find(group==unigroups(ct)));
    rho=magnitudes(find(group==unigroups(ct)));
    
    mu(ct)=circ_mean(theta);
    sd(ct)=circ_std(theta);
    med(ct)=circ_median(theta);
    n(ct)=length(theta);
    polar(theta,rho,strcat('.',colors{ct}));hold on;
    polar([mu(ct) mu(ct)],[0 4],strcat('-',colors{ct}));hold on;
    if ct>1
        rowlables=strcat(rowlables,'|group',num2str(ct));
    end
    results.descriptives=[mu sd med n];
end %for
disptable(results.descriptives,'Mean|SD|Median|n',rowlables) %
% legend('Black','Red','Green')
end

