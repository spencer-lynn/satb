function rsquared=rsq(observed,model)
% SAtb fn: rsquared=rsq(observed,model)
% 
% Determine r^2 between observed data and model, where:
% observed is rows of observations (ppts, cases), with columns of w/in-subject samples
% and model is a single row of expected (predicted) values.
% 
% NOTES:
% <http://www.graphpad.com/faq/viewfaq.cfm?faq=711>, <http://curvefit.com/goodness_of_fit.htm>
% R2 will be negative when the model fits the data worse than a horizontal line at the mean of observed values.
% 
% <http://en.wikipedia.org/wiki/Coefficient_of_determination>
% R2 is a statistic that will give some information about the goodness of fit of a model. 
% In regression, the R2 coefficient of determination is a statistical measure of how well 
% the regression line approximates the real data points. 
% An R2 of 1.0 indicates that the regression line perfectly fits the data.
% 
% Values of R2 outside the range 0 to 1 can occur where it is used to measure the agreement 
% between observed and modelled values and where the "modelled" values are not obtained 
% by linear regression and depending on which formulation of R2 is used. 
% 
% If the "unexplained" formula is used, values can never be greater than one. 
% If the "explained" expression is used, there are no constraints on the values obtainable.
% 
% <http://www.childrens-mercy.org/stats/ask/rsquared.asp>
% R squared is computed by looking at two sources of variation, SStotal and SSerror. 
% SStotal is the variability of the observed data about its mean. 
% SSerror is the variability of the observed data about the predicted values from a model (line, curve, whatever). 
% 
% Think of SStotal as the error in prediction if you did not use any additional information about the data. 
% In that case, our best prediction would just be the mean of the data. 
% Then SSerror is the error in prediction if you use a model of the data. 
% If SSerror is much smaller than SStotal, then we know that the model fits well.

[r c]=size(observed);
rsquared=NaN*ones(r,1);
% model=repmat(model,r,1); %replicate model for each row of observed data

% Determin r^2
for i=1:r
%     rsquared_unexplained
    TotSS = sum((observed(i,:)-mean(observed(i,:))).^2); %Total sum of squares
    ResSS = sum((observed(i,:)-model).^2); %Residual sum of squares
    rsquared(i) = 1 - (ResSS/TotSS);
    
%     rsquared_explained
    % ExpSS = sum((model-observed(i,:)).^2) % Explained (regression) sum of squares
    % if TotSS==ResSS+ExpSS
    % rsquared(i) = (ExpSS/TotSS);
end %for each observation
end %fn
