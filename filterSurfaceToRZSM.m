function RZSM = filterSurfaceToRZSM(SM_matrix,filterTimeLength,dt)

% Function that returns root-zone soil moisture using Exponential Time
% Filter given a surface soil moisture matrix

% INPUT: SM_matrix = SMAP matrix (size: Nlat x Nlon x Ndates)
% OUTPUT: rzsm = filtered SMAP matrix (size: Nlat x Nlon x Ndates)

[Nlat,Nlon,Ndate] = size(SM_matrix);
%fulldates = (datetime(2015,4,1):datetime(2022,8,6))'                     ;
%dates_num = convertTo(fulldates,'datenum')                               ;

%rzs = cell(Nlat,Nlon,2)                                                  ;

for ilat = 1:Nlat
    for ilon = 1:Nlon

        % Select Pixel Time-Series
        pixelSM = squeeze(SM_matrix(ilat,ilon,:));
   
        % Remove NaN Values from Soil Moisture                                
        isNull = isnan(pixelSM);
        datesN = dates_num(~isNull);
        pixelSM_trimmed = pixelSM(~isNull);

        % If Time-Series is Adequately Long
        if (sum(~isNull)>50)

            % Find n (tn-ti) from current time ti and Define Time Scale T [Days]
            T = filterTimeLength/dt;
            pixelRZSM_trimmed = NaN(size(pixelSM_trimmed));
            datesRZSM = NaN(size(datesN));
            % n = round(T/2); %why is this true
            for n = T+1:length(pixelSM)
                i = (n-T)/dt;
                tnti = dates(n)-dates(i:n);
                pixelRZSM(n) = sum(pixelSM(i:n).*exp(tnti),'omitnan')/sum(exp(tnti),'omitnan'); %check output size
                dateRZSM = dates(n);
            end %n 
        end % if isNull > 50
        RZSM(ilat,ilon,:) = pixelRZSM;
    end % ilon
    ilat
end % ilat


end