% =========================================================================
%  Modeling QPSK Modulation Scheme and Evaluating its Performance in Noisy
%  Environments with Spectral Efficiency
%  -------------------------------------------------------------------------
%  Simulates a QPSK system over an AWGN channel, evaluates the Bit Error
%  Rate (BER) across a range of SNR values, and computes the symbol rate,
%  bit rate, bandwidth and spectral efficiency.
%  Requires: Communications Toolbox (pskmod, pskdemod, awgn, de2bi)
% =========================================================================

clc;        % Clear the command window
clear;      % Remove all variables from the workspace
close all;  % Close all open figure windows

% --- Parameters ---
M      = 4;               % QPSK
N      = 10000;           % Number of symbols
SNR_dB = 0:2:20;          % SNR range

Rs    = 10000;            % Symbol rate = 10 ksymbols/sec
alpha = 0.25;             % Roll-off factor

% --- QPSK bits per symbol ---
bits_per_symbol = log2(M);

% --- Bandwidth ---
B = Rs * (1 + alpha);

% --- Bit rate ---
Rb = Rs * bits_per_symbol;

% --- Spectral efficiency ---
SE = Rb / B;

% --- Generate random data ---
data = randi([0 M-1], N, 1);

% --- QPSK Modulation ---
tx = pskmod(data, M, pi/4);

% --- Initialize BER ---
BER = zeros(size(SNR_dB));

%% AWGN Channel
for k = 1:length(SNR_dB)

    % Add AWGN noise
    rx = awgn(tx, SNR_dB(k), 'measured');

    % QPSK Demodulation
    data_rx = pskdemod(rx, M, pi/4);

    % Convert symbols to bits
    tx_bits = de2bi(data,    2, 'left-msb');
    rx_bits = de2bi(data_rx, 2, 'left-msb');

    % Calculate BER
    BER(k) = sum(tx_bits(:) ~= rx_bits(:)) / numel(tx_bits);

end

% --- Display results ---
fprintf('Symbol Rate         = %.2f ksymbols/sec\n', Rs/1000);
fprintf('Bit Rate            = %.2f kbps\n',          Rb/1000);
fprintf('Bandwidth           = %.2f kHz\n',           B/1000);
fprintf('Spectral Efficiency = %.2f bits/sec/Hz\n\n', SE);

disp(' SNR(dB)       BER')
disp([SNR_dB' BER'])

%% Plot BER
figure;
semilogy(SNR_dB, BER, 'o-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('QPSK BER Performance in AWGN Channel');

%% Plot Spectral Efficiency
figure;
bar(SE);
grid on;
xlabel('QPSK');
ylabel('Spectral Efficiency (bits/s/Hz)');
title('QPSK Spectral Efficiency');
