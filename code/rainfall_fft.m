%----------------------------------------------------+
% script to plot frequency spectra of rainfall time  |
% series in Jordan and Israel using FFT and compare  |
% the frequency content of the time series.          |
%                                                    |
% Rob Watson; 20/12/17                               |
%----------------------------------------------------+

clear all;
close all;

%% load in time series and pad shorter ones with zeros

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

rawdata = [amman_airport';ghor_safi';queen_alia';gilgal';sdom'];

% get rid of null data at start and end of time series

ipt = zeros(1,5);

for p = 1:5
    ipt(p) = findchangepts(rawdata(p,:));
end

% move data to new matrix padded with zeros at the ends

rainfall = zeros(size(rawdata));
rainfall(1,:) = amman_airport;

for p1 = 2:5
   rainfall(p1,1:(length(amman_airport)-ipt(p1))) = rawdata(p1,ipt(p1):end-1); 
end

[m,N] = size(rainfall);

% get rid of null data at ends of time series

for l = 1:N;
    for pr = 1:m
    if rainfall(pr,l) <= -100;
    rainfall(pr,l) = 0;
    end
    end
end


%%  calculate FFT and plot

% create cosine taper 

for p2 = 1:m;
L = round(0.05.*N);
taper = ones(N,1);

for a = 1:L;
    taper(a,1) = taper(a,1).*(1-cos(a.*pi/(2.*L)));
end

for b = N - L:N
    taper(b,1) = taper(b,1).*(1-cos((N-b).*pi/(2.*L)));
end

% taper data
taper = taper';
rainfall_taperd(p2,:) = taper.*rainfall(p2,:);

% perform FFT on data, with data stream padded with zeros up to 8192
fft_rainfall(p2,:) = fft(nonzeros(rainfall_taperd(p2,:)), 8192);

end

% plot tapered rainfall time series of amman airport against raw data
% to see effects of taper

t = datetime(1973,01,01):calmonths(1):datetime(2015,07,01);
datnum = datenum(t);
datnum = datnum';

taperd_time_series = figure(1);
plot(datnum, rainfall(1,:), 'LineWidth', 1.2);
hold on;
plot(datnum, rainfall_taperd(1,:),'LineWidth', 1.2);
dateFormat = 'yyyy';
datetick('x', dateFormat);
axis tight;
xlabel('year');
ylabel('precipitation (mm)');
title('monthly rainfall time series, Amman Airport');
legend('raw data', 'cosine tapered data', 'Location', 'NorthWest');

%% plot frequency data as power spectra

M = 8192;
nyquist = 1/2;
periodAS = (1:M/2+1)/(M/2)*nyquist;
w=1./periodAS;

% convert to 1D power spectrum

Pow2raw = zeros(m, M);
Pow1raw = zeros(m,M/2+1);

for p3 = 1:m;
    Pow2raw(p3,:) = abs(fft_rainfall(p3,:)./M);
    Pow1raw(p3,:) = Pow2raw(p3,1:M/2+1);
    Pow1raw(p3,2:end-1) = 2*Pow1raw(p3,2:end-1);
end

fft_power_freq = figure(2);

locations = ["amman airport","ghor safi","queen alia","gilgal","sdom"];

for p5 = 1:m;
subplot(2,3,p5);
plot(periodAS, Pow1raw(p5,:), 'LineWidth', 1.5);
axis([0 0.5 0 max(Pow1raw(p5,:))+0.05*max(Pow1raw(p5,:))]);
ylabel('Power');
xlabel('Cycles per year');
text(0.42,max(Pow1raw(p5,:))-0.05*max(Pow1raw(p5,:)),num2str(p5), 'FontSize', 16, 'Color', 'blue'); 
end

%% perform fourier-domain wavelet coherence on raw data:
% measure linear correlation between different time series
% as a function of frequency

% coherence between amman and safi

[wcohAS,wcsAS,periodAS,coiAS] = wcoherence(rawdata(1,ipt(2):end-1), rawdata(2,ipt(2):end-1), years(1/12));
periodAS = years(periodAS);
coiAS = years(coiAS);

wav_coh_amm_saf = figure(3);
pcolor(datnum(ipt(2):end-1),log2(periodAS),wcohAS);
wavcorr.EdgeColor='none';
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
ax = gca;
ax.XLabel.String='Year';
ax.YLabel.String='Period (years)';
ax.Title.String = 'wavelet coherence between amman airport and ghor safi';
hold on;
plot(ax,datnum(ipt(2):end-1),log2(coiAS),'w--','linewidth',2);
dateFormat = 'yyyy';
datetick(ax,'x', dateFormat);

% coherence between amman airport and queen alia

[wcohAQ,wcsAQ,periodAQ,coiAQ] = wcoherence(rawdata(1,ipt(3):end-1), rawdata(3,ipt(3):end-1), years(1/12),'PhaseDisplayThreshold',0.7);
periodAQ = years(periodAQ);
coiAQ = years(coiAQ);

wav_coh_amm_qal = figure(4);
pcolor(datnum(ipt(3):end-1),log2(periodAQ),wcohAQ);
wavcorr.EdgeColor='none';
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
ax = gca;
ax.XLabel.String='Year';
ax.YLabel.String='Period (years)';
ax.Title.String = 'wavelet coherence between amman airport and queen alia';
hold on;
plot(ax,datnum(ipt(3):end-1),log2(coiAQ),'w--','linewidth',2);
dateFormat = 'yyyy';
datetick(ax,'x', dateFormat);




