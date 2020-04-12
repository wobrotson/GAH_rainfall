%----------------------------------------------------+
% script to plot rainfall time series data for a     |
% number of sites across Jordan and deteermine if    |
% any of them are similar enough that they could be  |
% used as proxies for others which are less complete.|
%                                                    |
% Rob Watson; 18/12/17                               |
%----------------------------------------------------+

clear all;
close all;

%% read in rainfall time series from xls

% data is sampled monthly from 01/1970 to 07/2015

filename = 'Ibn_Hamad_GW_SW_Flow_1970-2016_Tino.xlsx';
sheet = 'monthly_rain_data';
xlRange_amn_apt = 'B50:B560';
xlRange_safi = 'C50:C560';
xlRange_Qal = 'D50:D560';
xlRange_gilgal = 'E50:E560';
xlRange_sdom = 'F50:F560';

amman_airport = xlsread(filename, sheet, xlRange_amn_apt);
ghor_safi = xlsread(filename, sheet, xlRange_safi);
queen_alia = xlsread(filename, sheet, xlRange_Qal);
gilgal = xlsread(filename, sheet, xlRange_gilgal);
sdom = xlsread(filename, sheet, xlRange_sdom);

t = datetime(1973,01,01):calmonths(1):datetime(2015,07,01);
datnum = datenum(t);
datnum = datnum';
rainfall = [amman_airport';ghor_safi';queen_alia';gilgal';sdom';];
[m,n] = size(rainfall);

%% find abrupt changes in time series and use to get rid of null data:

ipt_safi = findchangepts(rainfall(2,:));
ipt_Qal = findchangepts(rainfall(3,:));
ipt_gg = findchangepts(rainfall(4,:));
ipt_sdom = findchangepts(rainfall(5,:));

datnum_safi = datnum(ipt_safi:n);
datnum_Qal = datnum(ipt_Qal:n);
datnum_gg = datnum(ipt_gg:455);
datnum_sdom = datnum(ipt_sdom:455);

%% plot rainfall time series

set(0, 'DefaultAxesFontName', 'Calibri');
set(0, 'DefaultAxesFontSize', 14);

tplot=1;

if tplot ==1
rain_all = figure(1);
plot(datnum, rainfall(1,:), 'LineWidth', 1.2);
hold on;
plot(datnum_safi, rainfall(2,ipt_safi:n), 'LineWidth', 1.2);
plot(datnum_sdom, rainfall(5,ipt_sdom:455), 'LineWidth', 1.2);
plot(datnum_Qal, rainfall(3,ipt_Qal:n), 'LineWidth', 1.2);
plot(datnum_gg, rainfall(4,ipt_gg:455), 'LineWidth', 1.2);
dateFormat = 'yyyy';
datetick('x', dateFormat);
axis([datnum(1) datnum(n) 0 250]);
xlabel('year');
ylabel('precipitation (mm)');
title('monthly rainfall time series, Dead Sea region');
legend('amman airport', 'ghor safi', 'sdom', 'queen alia', 'gilgal', 'Location', 'NorthWest');
end

%% plot safi and amman airport together and test correlation:

amm_saf = amman_airport(ipt_safi:n); %amman airport
saf_amm = ghor_safi(ipt_safi:n); % ghor safi

comp = 0;

if comp==1
safi_amm_comp = figure(2);
plot(datnum_safi, amm_saf, 'LineWidth', 1.2);
hold on;
plot(datnum_safi, saf_amm, 'LineWidth', 1.2);
dateFormat = 'yyyy';
datetick('x', dateFormat);
axis tight;
xlabel('year');
ylabel('precipitation (mm)');
end

% calculate autocorrelation functions of both signals

[ACF_amm,lags_amm,bounds_amm] = autocorr(amm_saf);
[ACF_saf,lags_saf,bounds_saf] = autocorr(saf_amm);

% plot autocorrelation functions

autop=0;

if autop==1
auto_corr = figure(3);
subplot(1,2,1);
autocorr(amm_saf);

subplot(1,2,2);
autocorr(saf_amm);
end

% perform cross correlation of time series

Fs = 1/length(amm_saf); % sample rate
[acor,lag] = xcorr(saf_amm,amm_saf);
[~,I] = max(abs(acor));
lagDiff = lag(I); % time difference as a no.samples
timeDiff = lagDiff/Fs; % time difference in 

% plot cross-correlation function

xcorr_amm_saf = figure(4);
hold on;
plot(lag,acor, 'LineWidth', 1.2);

% find maximum peak of x correlation to see lag between the two:

max_lag_plot1 = lagDiff*ones(size(acor));
max_lag_plot2 = linspace(-2*10^4,16*10^4,length(acor));
max_lag_plot = [max_lag_plot1,max_lag_plot2'];

plot(max_lag_plot(:,1), max_lag_plot(:,2), 'r-',  'LineWidth', 1.3);
text(50,14*10^4, 'lag time = 21 months', 'FontSize', 14);
xlabel('Lag (months)');
ylabel('correlation function');
title('cross correlation function of amman airport and ghor safi rainfall time series');
