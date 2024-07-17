function SM_withDroughtLabels = classifyWithDroughtCategories(avgSM,DThresholds)

% Given an array of SM values and drought thresholds for an area, return
% the drought category that each pixel location is in for values in structure
% array (based on percentiles from the USDM drought categories D0-D4).
% 
% INPUT:  avgSM       = structure array with fields SM, startDate,
%                       centerDate, endDate
%         DThresholds = structure array with fields Month, drought categories 
%                       (and subsequent SM values), a, and b (beta distribution 
%                       fitting parameters)
% OUTPUT: SM_withDroughtLabels = structure array with same fields as avgSM, with 
%                                additional droughtLabels field to categorize each 
%                                location as D0-D4 drought at a given time 
%                                (NaN = No Drought/Missing Data, 0 = D0, 1 = D1, 
%                                2 = D2, 3 = D3, 4 = D4)

% Size of given area and time frame
Nperiod = length(avgSM);
[Nlat,Nlon] = size(avgSM(1).SM);

% Names and values of drought categories
DNames = ["D0","D1","D2","D3","D4"];
DValues = [NaN 0 1 2 3 4]; % Values for No Drought, D0, D1, D2, D3, D4
SM_withDroughtLabels = avgSM; % Initialize output struct array with existing SM

for iperiod = 1:Nperiod
    %Initialize droughtLabels array for each period
    periodDroughtLabels = NaN(Nlat,Nlon);

    [~, imonth] = ymd(avgSM(iperiod).centerDate); % Find month of center date
    periodSM = avgSM(iperiod).SM;

    % Combine D0-D4 for a specific month into a 3D matrix
    monthD_matrix = NaN(Nlat,Nlon,length(DNames));
    for D = 1:length(DNames)
        monthD_matrix(:,:,D) = DThresholds(imonth).(DNames(D));
    end % D

    for ilat = 1:Nlat
        for ilon = 1:Nlon 
            pixelD = squeeze(monthD_matrix(ilat,ilon,:));
            if sum(isnan(pixelD))==0 && ~isnan(periodSM(ilat,ilon))
                % Count number of DThresholds that SM value is less than
                count = numel(pixelD(pixelD>=periodSM(ilat,ilon)))+1;
            else % No drought (SM is higher than all thresholds)
                count = 1; % Index 1 of DValues
            end
            periodDroughtLabels(ilat,ilon) = DValues(count);
        end % ilon
    end % ilat

    SM_withDroughtLabels(iperiod).droughtLabels = periodDroughtLabels;

    % Print to track progress of code
    disp(['Period ',num2str(iperiod),' of ',num2str(Nperiod)])

end %iperiod
    
end %function