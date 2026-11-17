% =========================================================================
%  Automatic Gain Control (AGC)
%  -------------------------------------------------------------------------
%  Demonstrates a simple AGC loop that automatically adjusts the gain of a
%  dynamically-varying input signal to keep its amplitude near a reference
%  level (V_ref).
% =========================================================================

clc;        % Clear the command window
clear all;  % Remove all variables from the workspace
close all;  % Close all open figure windows

%% 1. Generate a Dynamic Test Signal
% -------------------------------------------------------------------------
Fs           = 1000;                  % Sampling frequency in Hz
t            = 0:1/Fs:5;              % 5-second time vector
carrier_freq = 50;                    % Carrier frequency in Hz

% Create a time-varying amplitude envelope (varies between 0.5 and 1.5)
envelope = 1 + 0.5 * sin(2*pi*0.5*t);

% Generate the dynamic signal (carrier scaled by the envelope)
input_signal = envelope .* (1 * sin(2*pi*carrier_freq*t));

%% 2. AGC Algorithm
% -------------------------------------------------------------------------
V_ref         = 0.5;                        % Desired output amplitude
gain          = 1;                          % Initial gain
output_signal = zeros(size(input_signal));  % Pre-allocate output buffer

% AGC Loop
for n = 1:length(input_signal)

    % Get the absolute value (envelope estimate)
    envelope_est = abs(input_signal(n));

    % Avoid division by zero for an ideal case
    if envelope_est < 1e-6
        gain_update = 1;
    else
        gain_update = V_ref / envelope_est;
    end

    % Update the gain with a smoothing factor (simple low-pass filter)
    gain = 0.99 * gain + 0.01 * gain_update;

    % Apply the gain to the input signal
    output_signal(n) = gain * input_signal(n);

end

%% 3. Plotting the Results
% -------------------------------------------------------------------------
figure;

% --- Input signal ---
subplot(2, 1, 1);
plot(t, input_signal);
title('Input Signal with Dynamic Amplitude');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% --- Output signal (after AGC) ---
subplot(2, 1, 2);
plot(t, output_signal);
title('Output Signal with AGC');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
