% =========================================================================
%  Estimate Symbol Rate / Bit Error Rate for QAM Modulation in AWGN Channel
%  -------------------------------------------------------------------------
%  Simulates a 16-QAM system over an AWGN channel and evaluates both the
%  Symbol Error Rate (SER) and Bit Error Rate (BER) across a range of SNR
%  values.
%  Requires: Communications Toolbox (qammod, qamdemod, awgn, de2bi)
% =========================================================================

clc;        % Clear the command window
clear;      % Remove all variables from the workspace
close all;  % Close all open figure windows

% --- Parameters ---
M      = 16;              % 16-QAM
N      = 10000;           % Number of symbols
SNR_dB = 0:2:20;          % SNR range

% --- Generate random symbols ---
data = randi([0 M-1], N, 1);

% --- QAM Modulation ---
tx = qammod(data, M, 'UnitAveragePower', true);

% --- Initialize BER and SER ---
BER = zeros(size(SNR_dB));
SER = zeros(size(SNR_dB));

%% AWGN Channel
for k = 1:length(SNR_dB)

    % Add AWGN noise
    rx = awgn(tx, SNR_dB(k), 'measured');

    % QAM Demodulation
    data_rx = qamdemod(rx, M, 'UnitAveragePower', true);

    % Symbol Error Rate
    SER(k) = sum(data ~= data_rx) / N;

    % Convert symbols to bits
    tx_bits = de2bi(data,    log2(M), 'left-msb');
    rx_bits = de2bi(data_rx, log2(M), 'left-msb');

    % Bit Error Rate
    BER(k) = sum(tx_bits(:) ~= rx_bits(:)) / numel(tx_bits);

end

% --- Display results ---
disp('SNR(dB)       SER          BER')
disp([SNR_dB' SER' BER'])

%% Plot SER
figure;
semilogy(SNR_dB, SER, 'o-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Symbol Error Rate (SER)');
title('16-QAM Symbol Error Rate in AWGN Channel');

%% Plot BER
figure;
semilogy(SNR_dB, BER, 's-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('16-QAM Bit Error Rate in AWGN Channel');
