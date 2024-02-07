function percentInD = calculateTimeSeries(SM_matrix,D_thresholds,datesArray)

% Function that returns root-zone soil moisture using an exponential time
% filter given surface soil moisture matrix

% INPUT: SM_matrix = SMAP matrix (size: Nlat x Nlon x Ndays)
%        D_thresholds = Drought thresholds matrix (size: Nlat x Nlon x
%        12 x 5); 12 months; 5 corresponds to D0-D4 classification
%        datesArray = datetime array size: Ndays
% OUTPUT: percentInD = Percentage of area in each drought threshold for
%         each day (size: Ndays x 5)

                                                 
[Nlat,Nlon,Ndays] = size(SM_matrix);
percentInD = zeros(Ndays,5);
    
for idate = 1:Ndays
    imonth = month(datesArray(idate)); % Get month of current date period
    for ilat = 1:Nlat
        for ilon = 1:Nlon
            for d = 1:5
                % does this skip NaN? double check
                if SM_matrix(ilat,ilon,idate) <= D_thresholds(ilat,ilon,imonth,d)
                    percentInD(idate,d) = percentInD(idate,d)+1;
                end %if  
            end %d
        end %ilon
    end %ilat
end %idate

totalArea = nnz(~isnan(SM_matrix)); % Calculates total area (non-NaN values)
percentInD = percentInD./totalArea; % Turns count into percentage

end  
