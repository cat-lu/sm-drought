function SM_withDroughtLabels = classifyWithDroughtCategories(avgSM,DThresholds)

% Given an array of SM values and drought thresholds for an area, return
% the drought category that each pixel location is in for values in structure
% array.
% 
% INPUT: avgSM = structure array
%        DThresholds = 
% OUTPUT: SM_withDroughtLabels = 

Nperiod = length(avgSM);
[Nlat,Nlon] = size(avgSM(1).SM);
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
            else
                count = 1;
            end
            periodDroughtLabels(ilat,ilon) = DValues(count);
        end % ilon
    end % ilat

    SM_withDroughtLabels(iperiod).droughtLabels = periodDroughtLabels;
    disp(['Period ',num2str(iperiod),' of ',num2str(Nperiod)])
end %iperiod
    
end %function