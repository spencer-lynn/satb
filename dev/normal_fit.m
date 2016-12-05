function normal_fit()
x=(-3:.1:3); %make an x-range
n=normpdf(x,0,1); %generate some normal data
a=-1;b=1; r=((a+(b-a).*rand(length(n),1))/5)'; %make some noise
y=n+r;%add noise to the data

% [x' y']

m=0; %seed initial mean for model fit
v=1; %seed initial variance for mode fit
f = @(p,x) (1 ./ (p(2).*sqrt(2.*pi)))*exp((-(x-p(1)).^2)/(2*p(2).^2)); %Specify the Gaussian fn (from ML helpdesk "Normal Distn")
b0=[m v]; %define seeds b0s->ps


[p,R,J,COVB,MSE] = nlinfit(x,y,f,b0); %fit the fn, returning best estimates of Ps
yfit=f(p,x); %get the model points

%Calc r^2
TSS = sum((y-mean(y)).^2);
RSS = sum((y-yfit).^2);
Rsquared = 1 - RSS/TSS

%plot it all
figure; hold on;
plot(x,y,'bo')
line(x,f(p,x),'color','r') %overlay the fitted curve

end %main fn


function unused
% CP can be investigated as: 
% (1) use identification-task data to determine shape of psychometric fn (should be sigmoid)
% (2) take derivative of psychometric (should be Gaussian)
% (3) fit ABX-accuracy data to the derivative

x=(-3:.1:3); %make an x-range
n=normpdf(x,0,1); %generate some normal data
a=-1;b=1; r=((a+(b-a).*rand(length(n),1))/5)'; %make some noise
y=n+r;%add noise to the data


m=0; %seed initial mean for model fit
v=1; %seed initial variance for mode fit
f = @(p,x) (1 ./ (p(2).*sqrt(2.*pi)))*exp((-(x-p(1)).^2)/(2*p(2).^2)); %Specify the Gaussian fn (from ML helpdesk "Normal Distn")
b0=[m v]; %define seeds b0s->ps


[p,R,J,COVB,MSE] = nlinfit(x,y,f,b0); %fit the fn, returning best estimates of Ps
yfit=f(p,x); %get the model points

%Calc r^2
TSS = sum((y-mean(y)).^2);
RSS = sum((y-yfit).^2);
Rsquared = 1 - RSS/TSS

%plot it all
figure; hold on;
plot(x,y,'bo')
line(x,f(p,x),'color','r') %overlay the fitted curve

end %main fn