%---------------------------------------------------+
% script to calculate the wavelet coherence between |
% rainfall time series in the dead sea region and   |
% plot them as periodograms over time.              |
%                                                   |
% Rob Watson; 21/12/17                              |
%---------------------------------------------------+

clear all;
close all;

%% load in time series and pad shorter ones with zeros

% data is sampled monthly from 01/1973 to 07/2015

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

rawdata = [amman_airport';ghor_safi';queen_alia';gilgal';sdom'];

% get rid of null data at start and end of time series

ipt = zeros(1,5);

for p1 = 1:5
    ipt(p1) = findchangepts(rawdata(p1,:));
end

% move data to new matrix padded with zeros at the ends

rainfall = zeros(size(rawdata));
rainfall(1,:) = amman_airport;

for p1 = 2:5
   rainfall(p1,1:(length(amman_airport)-ipt(p1))) = rawdata(p1,ipt(p1):end-1); 
end

[m,N] = size(rainfall);

% get rid of null data at ends of time series

for l = 1:N
    for pr = 1:m
    if rainfall(pr,l) <= -100
    rainfall(pr,l) = 0;
    end
    end
end

t = datetime(1973,01,01):calmonths(1):datetime(2015,07,01);
datnum = datenum(t);
datnum = datnum';

%% perform fourier-domain wavelet coherence on raw data:
% measure linear correlation between different time series
% as a function of recurrence period

wav_coh=figure(1);

for p1 = 1:m-1
    for p2 = 2:m
        for p3 = 1:10
subplot(5,2,p3);
wcoherence(rawdata(p1,ipt(p1):end-1), rawdata(p2,ipt(p2):end-1), years(1/12),'PhaseDisplayThreshold',0.7);

        end
    end
end