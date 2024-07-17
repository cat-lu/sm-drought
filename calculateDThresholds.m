function DThresholds = calculateDThresholds(avgSM,porosity,pct,pctLabels)

% Function that returns drought (D) thresholds given averaged soil moisture
% data, set threshold percentiles, and soil porosity characteristics

% INPUT:  avgSM       = structure array with fields SM, startDate,
%                       centerDate, endDate
%         porosity    = porosity matrix for given area (size: Nlat x Nlon)
%         pct         = array of desired percentiles for beta distribution fitting
%         pctLabels   = string array of labels for desired percentiles
% OUTPUT: DThresholds = structure array with fields Month, percentiles given
%                       in pctLabels, a, and b (beta distribution fitting
%                       parameters)

% Size of given SMAP area
[Nlat,Nlon] = size(avgSM(1).SM);

% Combine SM into single 3D matrix
SM_matrix = transformStructTo3DMatrix(avgSM,'SM');

% Check size equalities
assert(isequal(size(avgSM(1).SM),size(porosity)),...
       'Sizes of SM and porosity matrices do not match')
assert(isequal(length(pct),length(pctLabels)),...
        'Lengths of percentiles and percentile labels provided do not match')

% Initialize D Thresholds structure array with months
DThresholds = struct('Month',{"Jan","Feb","Mar","Apr","May","Jun","Jul",...
                              "Aug","Sep","Oct","Nov","Dec"});      
 
for imonth = 1:12
    [~, monthOfCenter] = ymd([avgSM.centerDate]); % Find month of center dates
    monthIndex = find(monthOfCenter == imonth);
    monthlyDThresholds = NaN(Nlat,Nlon,length(pct)); % D Thresholds for 1 month, all coords
    % Initialize beta parameters (a,b) for each month
    a = NaN(Nlat,Nlon); 
    b = NaN(Nlat,Nlon);

    for ilat = 1:Nlat
        % Display progress in code block
        disp(['Row ' num2str(ilat) ' of ' num2str(Nlat) ' in Month ' num2str(imonth)])

        for ilon = 1:Nlon        
            % Divide by location porosity for Location Relative Soil Saturation 
            % in [0,1] Range for 1 pixel in imonth
            monthlyPixelSM = squeeze(SM_matrix(ilat,ilon,monthIndex))./ porosity(ilat,ilon);
            % NaN for any values outside [0,1] range
            monthlyPixelSM(monthlyPixelSM>1) = NaN;
            monthlyPixelSM(monthlyPixelSM<0) = NaN;
            % Remove NaN for betafit function
            isNull = find(isnan(monthlyPixelSM));
            monthlyPixelSM(isNull) = []; 

            % If enough SM values (<10) and std>0.01 (over land)
            if (length(monthlyPixelSM)>10 && std(monthlyPixelSM)>0.01)
                % Maximum-Likelihood Estimate of Beta PDF Parameters
                betaParameters = betafit(monthlyPixelSM);
                a(ilat,ilon) = betaParameters(1);
                b(ilat,ilon) = betaParameters(2); 
                % Add beta inverse result (threshold) to monthlyDThresholds
                % (remains NaN if time series <= 10)
                monthlyDThresholds(ilat,ilon,:) = ...
                  betainv(pct,a(ilat,ilon),b(ilat,ilon)).*porosity(ilat,ilon);
            end % if over land

        end % ilon
    end % ilat

    for ipct = 1:length(pct) % Add to structure array for each input percentile
        % Use given pctLabels input for fieldname
        DThresholds(imonth).(pctLabels(ipct)) = monthlyDThresholds(:,:,ipct);
    end
    % Add beta parameters to structure array
    DThresholds(imonth).a = a; DThresholds(imonth).b = b;

    disp(['End of Month ' num2str(imonth)]) % Display progress in code block
end % imonth

end %function