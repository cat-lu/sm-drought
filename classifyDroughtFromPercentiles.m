function droughtLabels = classifyDroughtFromPercentiles(pctSM,pct,pctValues)

% Function that classifies SM percentiles from a set area and date as
% categories of drought (given by pct and pctValues) and returns these
% drought labels. 
% 
% INPUT:  pctSM     = 2D array of percentiles calculated from SM values, a,
%                     and b parameters (size: Nlat x Nlon)
%         pct       = Percentiles associated with drought
%         pctValues = Numbered labels that correspond to pct
% OUTPUT: droughtLabels = 2D array of drought labels (same size as input)
%                         consisting of values from pctValues 

assert((length(pctValues)==length(pct)),...
    "Number of categories do not match with percentiles given")

% Find which percentile each pixel corresponds to
count = zeros(size(pctSM));
for ipct = 1:length(pctValues)
    % Adds to count if SM percentile is less than given percentile
    count(pctSM<=pct(ipct)) = count(pctSM<=pct(ipct))+1;
end

% Map percentile back to categories (skip NaN)
droughtLabels = NaN(size(pctSM));
for ipct = 1:length(pctValues)
    droughtLabels(count==ipct) = pctValues(ipct);
end

end