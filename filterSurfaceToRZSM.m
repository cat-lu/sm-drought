function RZSM = filterSurfaceToRZSM(avgSM,filterTimeLength)

% Function that returns root-zone soil moisture using Exponential Time
% Filter given a surface soil moisture matrix and length (days) to reach
% root-zone from the surface

% INPUT:  avgSM            = structure array with fields SM, startDate, centerDate, endDate
%         filterTimeLength = days for soil moisture to travel from surface
%                            to root-zone soil level
% OUTPUT: RZSM             = structure array with resulting RZSM as field SM,
%                            startDate, centerDate, endDate

[Nlat,Nlon] = size(avgSM(1).SM);
Nperiod = length(avgSM);
% Calculate length of date period from avgSM structure array
dt = days(avgSM(1).endDate-avgSM(1).startDate)+1;
% Minimum amount of time before reaching root zone (in terms of # of periods)
T = ceil(filterTimeLength/dt); 
RZSM = avgSM; % Initialize RZSM structure array

% Combine SM into single 3D matrix and create list of dates
SM_matrix = transformStructTo3DMatrix(avgSM,'SM');
datesArray = transformStructTo3DMatrix(avgSM,'centerDate');
datesArray = reshape(datesArray,[Nperiod,1]);
RZSM_matrix = NaN(Nlat,Nlon,Nperiod); % Initialize RZSM matrix

for ilat = 1:Nlat
    for ilon = 1:Nlon
        % Isolate time series for a pixel
        pixelSM = squeeze(SM_matrix(ilat,ilon,:));
   
        % NaN values from soil moisture                                
        isNull = isnan(pixelSM);
        pixelRZSM = NaN(size(pixelSM)); % Initialize pixel's RZSM

        % If time series is adequately long
        if (sum(~isNull)>50)

            % From current time tn, calculate dates of all previous times ti
            % Start at T, should have NaN values for first T days (no previous SM data)
            for n = T:length(pixelSM)
                i = n:-1:n-T+1;
                tnti = days(datesArray(n)-datesArray(i)); % tn-ti
                
                % if pixelSM(i) is NaN, do not include in RZSM calculation
                nullSM = isnan(pixelSM(i));
                ipixelSM = pixelSM(i);
                ipixelSM = ipixelSM(~nullSM);
                tnti = tnti(~nullSM);

                % RZSM formula (should not have NaN), divide over total filter time length
                pixelRZSM(n) = sum(ipixelSM.*exp(-tnti/filterTimeLength),'all','omitnan')/sum(exp(-tnti/filterTimeLength),'all','omitnan');
            end %n

        end % if isNull > 50

        % If pixel SM is originally NaN, keep NaN for RZSM
        pixelRZSM(isNull) = NaN;
        % Add result to 3D RZSM matrix
        RZSM_matrix(ilat,ilon,:) = pixelRZSM;

    end % ilon

    % Track progress in code
    disp(['Latitude ',num2str(ilat),' of ',num2str(Nlat)])

end % ilat

% Transform into structure array for consistency and readability
RZSM = transformMatrix3DToStruct(RZSM_matrix,RZSM,'SM');

end