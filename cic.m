clear all
close all
clc

% CIC frequency domain example

%% Setup parameters

Fs_in = 125e6; % Input sample rate
Fs_out = 10e3; % Output sample rate

K = 5; % Number of stages

Fs = 125e6; % Sample rate (Hz)

ntaps_comp = 20; % Number of taps for the compensation filter

bits = 8;  % Number of bits for filter coefficients


%% CIC filter design

M = Fs_in / Fs_out; % Decimation ratio

fprintf('Designing a CIC filter for a decimation ratio of %f\n', M);

freq = (-1:1e-4:1) / M;

f_Hz = freq * Fs / 2;

w = 2 * pi * freq;

z = e.^(1j * w);

% CIC filter frequency response

H = (1 / M * (1 - z .^ (-M)) ./ (1 - z .^ (-1))) .^ K;


% Plot CIC filter frequency response and phase response

Hdb = 20 * log10(abs(H));

H_phase = atan2(imag(H),real(H));

figure
subplot(2,1,1)
plot(f_Hz, Hdb)
title('CIC magnitude response')
ylabel('|dB|')
xlabel('Frequency (Hz)')
axis([min(f_Hz) max(f_Hz) -350 0])
grid on
subplot(2,1,2)
plot(f_Hz, H_phase)
title('CIC phase response')
ylabel('angle (rad)')
xlabel('Frequency (Hz)')
axis([min(f_Hz) max(f_Hz) -pi pi])
grid on


% Create correction FIR filter (decimate by 2)

%%%%%% CIC filter parameters %%%%%%
R = M;				%% Decimation factor
M = 1;				%% Differential delay
N = K;				%% Number of stages
B = bits;			%% Coeff. Bit-width

%%%%%%% fir2.m parameters %%%%%%
L = ntaps_comp; 		%% Filter order; must be even
Fo = 0.5; 	%% Normalized Cutoff freq; 0<Fo<=0.5/M;

%%%%%%% CIC Compensator Design using fir2.m %%%%%%
p = 2e3; 		%% Granularity
s = 0.25/p; 	%% Step size
fp = [0:s:Fo]; 	%% Pass band frequency samples
fs = (Fo+s):s:1; %% Stop band frequency samples
f = [fp fs]; 	%% Normalized frequency samples; 0<=f<=1
Mp = ones(1,length(fp)); %% Pass band response; Mp(1)=1
Mp(2:end) = abs( M*R*sin(pi*fp(2:end)/R)./sin(pi*M*fp(2:end))).^N;
Mf = [Mp zeros(1,length(fs))];
f(end) = 1;
h = fir2(L,f,Mf); %% Filter length L+1
h = h/max(h); %% Floating point coefficients
hz = round(h*power(2,B-1)-1); %% Fixed point coefficients

[H_fir, w_fir] = freqz(h, 1, -pi:2*pi/(numel(w)-1):pi, "whole");

figure
subplot(2,1,1)
plot(f_Hz, 20 * log10(abs(H_fir)))
title('Compensation FIR frequency response')
grid on
subplot(2,1,2)
plot(f_Hz / M, atan(imag(H_fir)./real(H_fir)))
title('Compensation FIR phase response')
grid on

% Compensated response

H_comp = H .* H_fir;

figure
subplot(2,1,1)
plot(f_Hz, 20 * log10(abs(H_comp)))
axis([min(f_Hz) max(f_Hz) -250 0])
grid on
title('Compensated frequency response')
subplot(2,1,2)
plot(f_Hz, atan(imag(H_comp)./real(H_comp)))
axis([min(f_Hz) max(f_Hz) -pi pi])
grid on
title('Compensated phase response')


% Write fixed point coefficients to a Verilog file

fid = fopen('coeff.v','w');

fprintf(fid,'`timescale 1ns/1ns\n\n');
fprintf(fid,'// File containing filter coefficients (does not compile: include in filter module)\n');
fprintf(fid,'\n\nwire signed [%d:0] mem[0:%d];\n\n',bits-1,numel(hz)-1);
for i = 1:numel(hz)
	fprintf(fid,'assign mem[%d] = %d;\n',i-1,hz(i));
end

fclose(fid);
