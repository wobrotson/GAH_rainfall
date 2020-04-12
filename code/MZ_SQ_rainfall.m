%----------------------------------------------------+
% script to plot rainfall time series data for two   |
% sites in Jordan near to GAH, Siwaqa and Mazar, and |
% observe any trends in rainfall occurring over the  |
% time period being studied.                         ||
%                                                    |
% Rob Watson; 18/12/17                               |
%----------------------------------------------------+

clear all;
close all;

fft_run = 0;

%% read in rainfall time series

% dates from .txt files, rainfall from .xlsx file

fID1 = fopen('date_MZ_rain.txt', 'r');
date_MZ = textscan(fID1, '%s');
fclose(fID1);

fID2 = fopen('date_SQ_rain.txt', 'r');
date_SQ = textscan(fID2, '%s');
fclose(fID2);

filename = 'Rainfall_Swaqa_Karak.xlsx';
sheet_S = 'siwaqa';
sheet_M = 'mazar';

xlR_rain_M = 'A2:B1217';
xlR_rain_S = 'B2:B423';

rain_SQ = xlsread(filename, sheet_S, xlR_rain_S);
rain_MZ = xlsread(filename, sheet_M, xlR_rain_M);

%% plot raw data, rainfall time series
tMZ = datetime(date_MZ{:,1}, 'InputFormat','yyyy/MM/dd');
datnumMZ = datenum(tMZ);
datnumMZ = datnumMZ';

tSQ = datetime(date_SQ{:,1}, 'InputFormat','yyyy/MM/dd');
datnumSQ = datenum(tSQ);
datnumSQ = datnumSQ';

% first period covered by both time series: 1962/10/01 - 1976/04/01

figure(1);
bar(datnumMZ(1:405), rain_MZ(1:405));
dateFormat1 = 'yyyy';
datetick('x', dateFormat1);
xlabel('time');
ylabel('rainfall (mm)');
hold on;
bar(datnumSQ(1:371), rain_SQ(1:371));
%plot(datnumMZ(1:405), rain_MZ(1:405), '*');
%plot(datnumSQ(1:371), rain_SQ(1:371), 'x');
axis tight;
legend('Mazar', 'Siwaqa', 'Location', 'NorthWest');

% first period covered by both time series: 2002/10/09 - 2003/04/27

figure(2);
bar(datnumMZ(1063:1096), rain_MZ(1063:1096));
dateFormat2 = 'yyyy/MM';
datetick('x', dateFormat2);
xlabel('time');
ylabel('rainfall (mm)');
hold on;
bar(datnumSQ(372:422), rain_SQ(372:422));
%plot(datnumMZ(1063:1096), rain_MZ(1063:1096), '*');
%plot(datnumSQ(372:422), rain_SQ(372:422), 'x');
axis tight;
legend('Mazar', 'Siwaqa', 'Location', 'NorthWest');

% plot full mazar time series

figure(3);
bar(datnumMZ, rain_MZ,1, 'r');
datetick('x', dateFormat1);
axis tight;
xlabel('time');
ylabel('rainfall (mm)');
hold on;
bar(datnumSQ, rain_SQ,1,'b');
%plot(datnumMZ, rain_MZ, '*');
%plot(datnumSQ, rain_SQ, 'x');
legend('Mazar', 'Siwaqa', 'Location', 'NorthWest');

%% perform different smoothing functions to reduce noise in data

% Mazar

rain_MZ_movmean = smoothdata(rain_MZ, 'movmean');
rain_MZ_movmed = smoothdata(rain_MZ, 'movmedian');
rain_MZ_rloess = smoothdata(rain_MZ, 'rloess');
rain_MZ_sgolay = smoothdata(rain_MZ, 'sgolay');

figure(4);
subplot(2,2,1);
plot(datnumMZ, rain_MZ);
hold on;
plot(datnumMZ, rain_MZ_movmean, '--');
datetick('x', dateFormat1);
axis tight;
xlabel('time');
ylabel('rainfall (mm)');
title('moving average');
subplot(2,2,2);
plot(datnumMZ, rain_MZ);
hold on;
plot(datnumMZ, rain_MZ_movmed, '--');
datetick('x', dateFormat1);
axis tight;
xlabel('time');
ylabel('rainfall (mm)');
title('moving median');
subplot(2,2,3);
plot(datnumMZ, rain_MZ);
hold on;
plot(datnumMZ, rain_MZ_rloess, '--');
datetick('x', dateFormat1);
xlabel('time');
ylabel('rainfall (mm)');
axis tight;
title('rloess - robust quadratic regression');
subplot(2,2,4);
plot(datnumMZ, rain_MZ);
hold on;
plot(datnumMZ, rain_MZ_sgolay, '--');
datetick('x', dateFormat1);
axis tight;
xlabel('time');
ylabel('rainfall (mm)');
title('Savitzky-Golay');
 

%%  calculate FFT and plot

if fft_run == 1

% Mazar data

[N,m] = size(rain_MZ);

% create cosine taper 

L = round(0.05.*N);
taper = ones(N,1);

for a = 1:L;
    taper(a) = taper(a).*(1-cos(a.*pi/(2.*L)));
end

for b = N - L:N
    taper(b) = taper(b).*(1-cos((N-b).*pi/(2.*L)));
end

% taper data
%taper = taper';
rain_MZ_taperd = taper.*rain_MZ;

% perform FFT on data, with data stream padded with zeros up to 8192
fft_rain_MZ = fft(nonzeros(rain_MZ_taperd), 8192);


% plot tapered rainfall time series of amman airport against raw data
% to see effects of taper


figure(5);
plot(datnumMZ, rain_MZ, 'LineWidth', 1.2);
hold on;
plot(datnumMZ, rain_MZ_taperd,'LineWidth', 1.2);
dateFormat = 'yyyy';
datetick('x', dateFormat);
axis tight;
xlabel('year');
ylabel('precipitation (mm)');
title('monthly rainfall time series, Mazar met station');
legend('raw data', 'cosine tapered data', 'Location', 'NorthWest');

%% plot frequency data as power spectra

M = 8192;
nyquist = 1/2;
periodAS = (1:M/2+1)/(M/2)*nyquist;
w=1./periodAS;

% convert to 1D power spectrum

Pow2raw = zeros(m,M);
Pow1raw = zeros(m,M/2+1);

Pow2raw = abs(fft_rain_MZ./M);
Pow1raw = Pow2raw(1:M/2+1);
Pow1raw(2:end-1) = 2*Pow1raw(2:end-1);

figure(6);
plot(periodAS, Pow1raw, 'LineWidth', 1.5);
xlim([0 0.5]);
ylabel('Power');
xlabel('Cycles per year');
%text(0.42,max(Pow1raw(p5,:))-0.05*max(Pow1raw(p5,:)),num2str(p5), 'FontSize', 16, 'Color', 'blue'); 

end
