clear all
close all
clc

% CIC frequency domain example

R = 20; % Decimation ratio
M = 1;  % Samples comb stage
N = 5; % Number of stages

w = -pi:1e-4:pi;

z = e.^(1j * w);

% CIC filter frequency response

H = (1/R * (1 - z .^ (-R*M)) ./ (1 - z .^ (-1))) .^ N;


% Plot CIC filter frequency response

Hdb = 20 * log10(abs(H));

figure
plot(w,Hdb)
title('CIC filter frequency response')
axis([min(w) max(w) -300 10])
xlabel('w (rad/s)')
ylabel('|H| (db)')
grid on
