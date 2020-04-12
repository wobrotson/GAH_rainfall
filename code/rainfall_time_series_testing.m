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
xlRange_dragot = 'C50:C560';

amman_airport = xlsread(filename, sheet, xlRange_amn_apt);
ghor_safi = xlsread(filename, sheet, xlRange_safi);
queen_alia = xlsread(filename, sheet, xlRange_Qal);
gilgal = xlsread(filename, sheet, xlRange_gilgal);
sdom = xlsread(filename, sheet, xlRange_sdom);
%dragot = xlsread(filename, sheet, xlRange_dragot);

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
%ipt_drgt = findchangepts(rainfall(6,:));

datnum_safi = datnum(ipt_safi:n);
datnum_Qal = datnum(ipt_Qal:n);
datnum_gg = datnum(ipt_gg:455);
datnum_sdom = datnum(ipt_sdom:455);

%% plot rainfall time series
test=1;
if test ==1
rain_t_ser = figure(1);
plot(datnum, rainfall(1,:));
hold on;
plot(datnum_safi, rainfall(2,ipt_safi:n));
plot(datnum_sdom, rainfall(5,ipt_sdom:455));
plot(datnum_Qal, rainfall(3,ipt_Qal:n));
plot(datnum_gg, rainfall(4,ipt_gg:455));
dateFormat = 'mmm,yy';
datetick('x', dateFormat);
axis([datnum(1) datnum(n) 0 250]);
end

test2 = 0;
if test2==1
figure(2);
for a = 1:n
if amman_airport(a)~=-9999
plot(datnum(a),amman_airport(a));
end
if ghor_safi(a)~=-9999
plot(datnum(a),ghor_safi(a));
end
end
dateFormat = 'mmm,yy';
datetick('x', dateFormat);
axis tight;
end

%% trying to automate plotting better

test3 = 0;
if test3 ==1
figure(3);
for a = 1
    for b=1
if rainfall(b,a)~=-9999
plot(datnum(a),rainfall(b,a));
if b >=m+1
    break
if i>=n+1
    break
j=j+1;
i=i+1;
    end
    end
end
end
end
dateFormat = 'mmm,yy';
datetick('x', dateFormat);
axis tight;
end
