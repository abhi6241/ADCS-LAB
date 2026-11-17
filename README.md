# ADCS Lab — MATLAB Scripts

Collection of MATLAB simulation scripts for the ADCS (Advanced Digital Communication Systems) lab.

> **Note:** All scripts except `AGC_code.m` require the **Communications Toolbox**
> (`pskmod`, `pskdemod`, `qammod`, `qamdemod`, `awgn`, `de2bi`).

---

## Scripts

### 1. `AGC_code.m` — Automatic Gain Control

Demonstrates a simple AGC loop that automatically adjusts the gain of a
dynamically-varying input signal to keep its amplitude near a reference level.

- **Test signal:** 50 Hz carrier, 5 s duration, with a sinusoidal envelope
  varying between 0.5 and 1.5 (Fs = 1000 Hz)
- **AGC loop:** envelope estimate via `abs()`, gain update `V_ref / envelope_est`
  with a smoothing low-pass filter (`0.99 * gain + 0.01 * gain_update`)
- **Output:** plots of the input signal vs. the AGC-adjusted output signal

### 2. `PSK8_BER_AWGN.m` — 8-PSK BER in AWGN

End-to-end simulation of an 8-PSK communication system.

- 10,000 random symbols, SNR swept from 0 to 20 dB in 2 dB steps
- Gray-coded modulation/demodulation via `pskmod` / `pskdemod`
- Bit Error Rate computed per SNR point and printed as a table
- **Output:** semilogy plot of BER vs. SNR

### 3. `QAM16_SER_BER_AWGN.m` — 16-QAM SER/BER in AWGN

Estimates the symbol error rate and bit error rate for 16-QAM in an AWGN channel.

- 10,000 random symbols, SNR swept from 0 to 20 dB in 2 dB steps
- `qammod` / `qamdemod` with `UnitAveragePower = true`
- Both SER and BER computed per SNR point and printed as a table
- **Output:** semilogy plots of SER vs. SNR and BER vs. SNR

### 4. `QPSK_performance.m` — QPSK Performance + Spectral Efficiency

Models QPSK modulation and evaluates its performance in noisy environments,
along with its spectral efficiency.

- 10,000 random symbols, SNR swept from 0 to 20 dB in 2 dB steps
- QPSK modulation with π/4 phase offset (`pskmod(data, 4, pi/4)`)
- Computes and prints:
  - Symbol rate — 10.00 ksymbols/sec
  - Bit rate — 20.00 kbps
  - Bandwidth (roll-off α = 0.25) — 12.50 kHz
  - Spectral efficiency — 1.60 bits/sec/Hz
- **Output:** semilogy plot of BER vs. SNR, and a bar plot of spectral efficiency

---

## Usage

Run any script directly in MATLAB:

```matlab
AGC_code
PSK8_BER_AWGN
QAM16_SER_BER_AWGN
QPSK_performance
```

Each script is self-contained (`clc; clear; close all;` at the top) and produces
its own figures and console output.
