% =========================================================================
%  End-to-End Simulation of 8-PSK Communication System
%  -------------------------------------------------------------------------
%  Simulates an 8-PSK system over an AWGN channel and evaluates the Bit
%  Error Rate (BER) across a range of SNR values.
%  Requires: Communications Toolbox (pskmod, pskdemod, awgn, de2bi)
% =========================================================================

clc;        % Clear the command window
clear;      % Remove all variables from the workspace
close all;  % Close all open figure windows

% --- Parameters ---
M      = 8;               % 8-PSK
N      = 10000;           % Number of symbols
SNR_dB = 0:2:20;          % SNR range

% --- Generate random data ---
data = randi([0 M-1], N, 1);

% --- 8-PSK Modulation ---
tx = pskmod(data, M, 0);

% --- Initialize BER ---
BER = zeros(size(SNR_dB));

%% AWGN Channel
for k = 1:length(SNR_dB)

    % Add AWGN noise
    rx = awgn(tx, SNR_dB(k), 'measured');

    % 8-PSK Demodulation
    data_rx = pskdemod(rx, M, 0);

    % Convert symbols to bits
    tx_bits = de2bi(data,    3, 'left-msb');
    rx_bits = de2bi(data_rx, 3, 'left-msb');

    % Calculate BER
    BER(k) = sum(tx_bits(:) ~= rx_bits(:)) / numel(tx_bits);

end

% --- Display BER ---
disp('   SNR(dB)       BER')
disp([SNR_dB' BER'])

%% Plot BER
figure;
semilogy(SNR_dB, BER, 'o-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('8-PSK BER Performance in AWGN Channel');
