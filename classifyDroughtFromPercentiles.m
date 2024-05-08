function droughtLabels = classifyDroughtFromPercentiles(pctSM,pct,pctValues)

% INPUT: pctSM = 2D array of percentiles calculated from SM and a and b
%                parameters (size: Nlat x Nlon)
%        pctLabels = Percentiles associated with drought
%        labelValues = Numbered labels that correspond to pctLabels
% OUTPUT: droughtLabels = 2D array of drought labels (values from
%                         labelValues)

assert((length(pctValues)==length(pct)),...
    "Number of categories do not match with percentiles given")

% Find which percentile each pixel corresponds to
count = zeros(size(pctSM));
for ipct = 1:length(pctValues)
    % Adds to count if less than percentile
    count(pctSM<=pct(ipct)) = count(pctSM<=pct(ipct))+1;
end

% Map percentile back to categories (skip NaN)
droughtLabels = NaN(size(pctSM));
for ipct = 1:length(pctValues)
    droughtLabels(count==ipct) = pctValues(ipct);
end

end