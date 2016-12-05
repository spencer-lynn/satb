function regdat=registrator(keys,data)
% for data = rows of ppts, cols of data and keys = registration key
% Say, data=responses over 11 stim continuum
% and we want to express all responses relative to idiographic threshold
% location (the key)
% 
%NOTE: registrator puts these data off by one col because the Threshold is w/rt 11 stims, but the first stim in the data file is stim2.
% - not a code problem per se, I'm passing in a key (threshold loc) that is assuming data
% starts at stim1... I should subtract 1 from the keys.
% 
dataname=(strcat(inputname(2),'.dat'));
[r c]=size(data);
[rk ck]=size(keys);
if r~=rk
    error('Row count mismatch between key and data')
end


%regdat.r = a matrix to hold data in registration, where:
% key col of data will be put into midpoint of register, = a zero-point.
% with data to left of key beging less than midpt, right of key greater
% than midpt
regdat.r=zeros(r,c*2+1)*NaN; %the registration matrix, 2x #cols of data, +1 for the centered key 
midpt=ceil((c*2+1)/2); %mid-point of expanded data columns will become threshold location

for i=1:r
    regdat.r(i,(midpt-keys(i)+1):(midpt-keys(i)+c)) = data(i,:);
    %= row:i, col: midpt offset by key-value

end
regdat.x=(midpt-(c*2+1)):1:c;
regdat.y=nanmean(regdat.r,1);



figure;
plot(regdat.x,regdat.y) %plot mean at each col, over all rows, centered key=0
regdat.r

export(dataset(regdat.r),'File',dataname)
end