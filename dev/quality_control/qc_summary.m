function qc_summary(experimentName)
global myfile qcdata_out

%% Structure of MYFILE once loaded:
%myfile.qcdata.fname (eg, 'sig3p2_11.dat')
%             .starttrial (eg, 10)
%             .behavior (eg 289 x 1 double of 1/-1)
%             .objname (eg 289 x 1 cell of stimulus names)

toggle_warnings('off') %turn various ML computation warnings on/off
cdwork(experimentName)
stimNames={'stim1.tif' 'stim2.tif' 'stim3.tif' 'stim4.tif' 'stim5.tif' 'stim6.tif' 'stim7.tif' 'stim8.tif' 'stim9.tif' 'stim10.tif' 'stim11.tif' };
datafolder='data/';
fid = fopen(strcat(experimentName,'qc_data_out.dat'),'wt'); %open file in disk to write processed data


datafile_suffix='.mat';
d=dir(strcat(datafolder,'*',datafile_suffix)); %get list of all data files
numFiles=length(d);

dataHeaders={'Subject' 'startTrial' 'threshold' 'slope' 'guessed_yes' 'guessed_no'};
formatCell={'%s\t' '%s\t' '%s\t' '%s\t' '%s\t' '%s\n'};
writeCellLine(fid,dataHeaders,formatCell)

qcdata_out=cell(numFiles+1,length(dataHeaders));
qcdata_out(1,:)=dataHeaders;

for i=1:numFiles
    myfile=load(strcat('data/',d(i).name));
    pmetric_output=pmetric(myfile.qcdata.objname,myfile.qcdata.behavior,stimNames,'psychometric');
    sigmoid_fit_output=sigmoid_fit(1:length(stimNames),pmetric_output.pm,'inflection',0,0); %PARAMS=x,y,tmethod,constrain,plot
    formatCell={'%s\t' '%i\t' '%e\t' '%e\t' '%e\t' '%e\n'};
    if isequal(sigmoid_fit_output.threshold,'WARNING')
        formatCell(3)={'%s\t'};
        formatCell(4)={'%s\t'};
        formatCell(5)={'%s\t'};
        formatCell(6)={'%s\n'};
        
        sigmoid_fit_output.threshold=[];
        sigmoid_fit_output.p4slope=[];
        sigmoid_fit_output.guessed_yes=[];
        sigmoid_fit_output.guessed_no=[];
    end
    qcdata_out(i+1,1)={myfile.qcdata.fname};
    qcdata_out(i+1,2)={myfile.qcdata.starttrial};
    qcdata_out(i+1,3)={sigmoid_fit_output.threshold};
    qcdata_out(i+1,4)={sigmoid_fit_output.p4slope};
    qcdata_out(i+1,5)={sigmoid_fit_output.guessed_yes};
    qcdata_out(i+1,6)={sigmoid_fit_output.guessed_no};
    writeCellLine(fid,qcdata_out(i+1,:),formatCell)
end%for each file
%data_out
fclose('all'); %close all open files
toggle_warnings('on') %turn various ML computation warnings on/off
end %main

function writeCellLine(fid,cellLine,formatCell)
for i=1:length(cellLine)
    fprintf(fid,formatCell{i},cellLine{i});%Write data to disk
end
end