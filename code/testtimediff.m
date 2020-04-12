clear all;
close all;
t1 = linspace(0,2*pi,100);
t2 = linspace(pi,2*pi,50);

y1 = sin(t1);
y2 = cos(t2);

figure;
plot(t1,y1,t2,y2);
