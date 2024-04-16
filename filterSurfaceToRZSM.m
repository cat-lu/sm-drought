function RZSM = filterSurfaceToRZSM(avgSM,filterTimeLength)
% Function that returns root-zone soil moisture using Exponential Time
% Filter given a surface soil moisture matrix

% INPUT: avgSM = structure array with fields SM, startDate, centerDate, endDate
%        filterTimeLength = 
% OUTPUT: RZSM = 

[Nlat,Nlon] = size(avgSM(1).SM);
Nperiod = length(avgSM);
dt = days(avgSM(1).endDate-avgSM(1).startDate)+1;
T = ceil(filterTimeLength/dt); % Minimum amount of time before reaching root zone
% rootDatePeriod = datePeriod(T+1:end);
RZSM = avgSM;
% RZSM = NaN(Nlat,Nlon,Ndate);

% Combine SM into single 3D matrix
SM_matrix = NaN(Nlat,Nlon,Nperiod); 
RZSM_matrix = NaN(Nlat,Nlon,Nperiod);
datesArray = NaT(Nperiod,1);
for iperiod = 1:Nperiod
    SM_matrix(:,:,iperiod) = avgSM(iperiod).SM;
    datesArray(iperiod) = avgSM(iperiod).centerDate;
end

for ilat = 1:Nlat
    for ilon = 1:Nlon

        % Select Pixel Time-Series
        pixelSM = squeeze(SM_matrix(ilat,ilon,:));
   
        % NaN Values from Soil Moisture                                
        isNull = isnan(pixelSM);
        pixelRZSM = NaN(size(pixelSM)); % should have NaN values for first T days
        % count = 1;
        % datesN = dates_num(~isNull);
        % pixelSM_trimmed = pixelSM(~isNull);

        % If Time-Series is Adequately Long
        if (sum(~isNull)>50)

            % Find n (tn-ti) from current time ti and Define Time Scale T [Days]

            % for i = 1:length(pixelSM)-T
            %     count = count+1;
            %     n = i+T-1; % Inclusive end date (subtract 1)
            %     tnti = days(datePeriod(n)-datePeriod(i:n)); % days elapsed between dates
            %     pixelRZSM(count) = sum(pixelSM(i:n).*exp(tnti/T)','all','omitnan')/sum(exp(tnti/T),'all','omitnan');
            % end %n
            for n = T:length(pixelSM)
                i = n:-1:n-T+1;
                tnti = days(datesArray(n)-datesArray(i));
                
                % if pixelSM(i) is NaN do not include in RZSM calculation
                nullSM = isnan(pixelSM(i));
                ipixelSM = pixelSM(i);
                ipixelSM = ipixelSM(~nullSM);
                tnti = tnti(~nullSM);

                % RZSM formula (should not have NaN)
                %% Over filter time length??
                pixelRZSM(n) = sum(ipixelSM.*exp(-tnti/filterTimeLength),'all','omitnan')/sum(exp(-tnti/filterTimeLength),'all','omitnan');
            end %n

        end % if isNull > 50

        pixelRZSM(isNull) = NaN;
        RZSM_matrix(ilat,ilon,:) = pixelRZSM;

    end % ilon
    disp(['Latitude ',num2str(ilat),' of ',num2str(Nlat)])
end % ilat

for iperiod = 1:Nperiod
    RZSM(iperiod).SM = RZSM_matrix(:,:,iperiod);
end

end