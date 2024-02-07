function [DThresholds,centerDatePeriod,a,b] = calculateDThresholds(SM_matrix,startDate,endDate,dt,porosity,pct)

% Function that returns drought (D) thresholds given soil moisture data and
% set threshold percentiles classified D0-D4 by USDM 

% INPUT: SM_matrix = SMAP matrix (size: Nlat x Nlon x Ndates)
%        startDate = desired start date in array [yyyy,mm,dd]
%        endDate = desired end date in array [yyyy,mm,dd]
%        dt = time step 
%        porosity = porosity matrix (size: Nlat x Nlon)
% OUTPUT: DThreshold = Drought thresholds for each month and each D 
%                      classification (size: Nlat x Nlon x 12 x 5)

% Range of desired inputted dates
dateRange = datetime(startDate(1),startDate(2),startDate(3)):datetime(endDate(1),endDate(2),endDate(3));
Ndate = length(dateRange);
NperiodInput = floor(Ndate/dt);

[Nlat,Nlon,Nperiod] = size(SM_matrix); 
assert(isequal(Nperiod,NperiodInput),'Time steps of soil moisture matrix and given dt do not match')

% Create date array of center dates (middle of date periods)
centerDatePeriod = NaT(Nperiod,1);
i_t = 0;
for i = 1:dt:Ndate-dt
    i_t = i_t + 1;
    i_beg = i;
    i_end = i+(dt-1);
    centerDatePeriod(i_t,1) = dateRange(floor((i_beg+i_end)/2));
end

% % Cut porosity data specific to region
% cut2D(porosity,porosityLat,porosityLon,)
% porosity_region = ones(size(SM_period)).*porosity;            

% Initialize beta parameters for each month in year
a = NaN(Nlat,Nlon,12); 
b = NaN(Nlat,Nlon,12);  
DThresholds = NaN(Nlat,Nlon,12,length(pct));         
              
for ilat = 1:Nlat
    disp(['Row ' num2str(ilat) ' of ' num2str(Nlat)]) % Display progress in code block
    for ilon = 1:Nlon
        for i_month = 1:12
            [~, centerMonth] = ymd(centerDatePeriod); % Find month of center dates
            monthIndex = find(centerMonth == i_month);
            % k_month = find(month(centerDatePeriod(:,2) == i_month); %date time vector for new data
    
            % Location Relative Soil Saturation in [0,1] Range    
            monthlySM = squeeze(SM_matrix(ilat,ilon,monthIndex))./ porosity(ilat,ilon);
            monthlySM(monthlySM>1) = NaN;
            monthlySM(monthlySM<0) = NaN;
            % Remove NaN for betafit function
            isNull = find(isnan(monthlySM));
            monthlySM(isNull) = [];
         
            if (length(monthlySM)>10 && std(monthlySM)>0.01)
                % Maximum-Likelihood Estimate of Beta PDF Parameters
                betaParameters = betafit(monthlySM);
                a(ilat,ilon,i_month) = betaParameters(1);
                b(ilat,ilon,i_month) = betaParameters(2); 
                DThresholds(ilat,ilon,i_month,:) = betainv(pct,a(ilat,ilon,i_month),b(ilat,ilon,i_month)).*porosity(ilat,ilon);
            end % if over land

        end % i_month
    end % ilon
end % ilat

end %function