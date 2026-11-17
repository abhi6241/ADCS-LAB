# ADCS Lab — Theory & Explanation

This file explains the theory behind each of the four MATLAB simulations in
this lab folder, how each algorithm works, and what results to expect.

---

## 1. Automatic Gain Control (`AGC_code.m`)

### What is AGC?

**Automatic Gain Control (AGC)** is a feedback loop that continuously adjusts
the amplification (gain) applied to a signal so that its output amplitude
stays close to a desired reference level, regardless of how much the input
amplitude fluctuates. It is used in receivers, hearing aids, radios and audio
processors — anywhere the input signal strength is unpredictable.

### How the simulation works

**Step 1 — Test signal.**
A 50 Hz carrier is multiplied by a slowly-varying envelope:

```
envelope(t) = 1 + 0.5 · sin(2π · 0.5 · t)     → varies between 0.5 and 1.5
input(t)    = envelope(t) · sin(2π · 50 · t)
```

The envelope changes over a 2-second period, simulating fading / varying
signal strength.

**Step 2 — AGC loop (runs once per sample):**

1. **Envelope estimate:** `env_est = |input(n)|`
2. **Gain update:** the gain needed to bring the current sample to the
   reference level `V_ref = 0.5`:
   - if `env_est < 1e-6` → `gain_update = 1` (guard against division by zero
     at signal zero-crossings)
   - otherwise → `gain_update = V_ref / env_est`
3. **Smoothing:** the raw update is noisy (it changes every sample), so it is
   low-pass filtered — a simple exponential smoother with α = 0.01:
   ```
   gain = 0.99 · gain + 0.01 · gain_update
   ```
   This gives the loop a time constant of ≈ 1/(Fs·α) = 0.1 s: fast enough to
   follow the 2-second envelope, slow enough not to chase every sample.
4. **Apply gain:** `output(n) = gain · input(n)`

**Step 3 — Plots:** input signal (amplitude visibly breathing between 0.5 and
1.5) vs. output signal (amplitude roughly constant).

### Expected result

- **No errors.** The zero-crossing guard prevents division by zero.
- The input peak swings between ≈ 1.0 and 1.5, while the output peak stays
  roughly constant around 0.8–1.0.
- **The output does not settle exactly at V_ref = 0.5.** Because the loop uses
  the *instantaneous* |x| rather than a filtered envelope, the steady-state
  gain converges to the *average* of 0.5/|sin| over a carrier cycle (≈ 0.87),
  not exactly 0.5. This is a known simplification — a true envelope detector
  (rectify + low-pass, or Hilbert transform) would converge exactly to V_ref.

---

## 2. 8-PSK BER in AWGN (`PSK8_BER_AWGN.m`)

### What is 8-PSK?

**Phase Shift Keying (PSK)** encodes bits in the *phase* of a constant-amplitude
carrier. In **8-PSK**, each symbol carries **3 bits** (log₂8) and is mapped to
one of 8 phases equally spaced 45° apart on the unit circle.

### How the simulation works

1. **Random data:** 10,000 symbols drawn uniformly from {0,…,7}.
2. **Modulation:** `pskmod(data, 8, 0)` maps each symbol to a complex point
   `e^(j·2πk/8)` on the unit circle (unit average power).
3. **Channel:** for each SNR in 0:2:20 dB, `awgn(..., 'measured')` adds
   complex white Gaussian noise calibrated to the measured signal power.
4. **Demodulation:** `pskdemod` finds the constellation point nearest in
   phase to each received sample.
5. **BER:** symbols are expanded to 3-bit groups with `de2bi`, and the BER is
   the fraction of mismatched bits.

### Theory — expected BER

For M-PSK over AWGN, the symbol error rate is approximately

```
SER ≈ 2·Q( √(2·SNR) · sin(π/M) )        (for high SNR, M > 4)
BER ≈ SER / log2(M)                      (Gray coding)
```

With Gray coding (default in `pskmod`), adjacent constellation points differ
in only one bit, so most symbol errors cause a single bit error.

### Expected result

The BER curve decreases monotonically from ≈ 0.15–0.2 at 0 dB down to
≈ 10⁻⁴–10⁻⁵ at 20 dB. As a rule of thumb, every 3 dB of SNR gains roughly one
order of magnitude of BER improvement in the high-SNR region.

---

## 3. 16-QAM SER/BER in AWGN (`QAM16_SER_BER_AWGN.m`)

### What is 16-QAM?

**Quadrature Amplitude Modulation (QAM)** encodes data in *both* amplitude and
phase. **16-QAM** uses a 4×4 grid of 16 points (4 bits per symbol), giving
better bandwidth efficiency than PSK at the cost of amplitude sensitivity.

### How the simulation works

1. **Random data:** 10,000 symbols from {0,…,15}.
2. **Modulation:** `qammod(data, 16, 'UnitAveragePower', true)` maps symbols
   onto the 16-point constellation, scaled so the average symbol energy is 1.
3. **Channel:** AWGN added at each SNR in 0:2:20 dB.
4. **Demodulation:** `qamdemod` performs minimum-distance detection on the grid.
5. **Error rates:**
   - `SER = (number of symbol mismatches) / N`
   - `BER = (mismatched bits after de2bi expansion) / total bits`

### Theory — expected error rates

For square M-QAM with unit average power (SNR per symbol):

```
SER ≈ 4·(1 − 1/√M)·Q( √( 3·SNR / (M−1) ) )
BER ≈ SER / log2(M)                       (Gray coding)
```

16-QAM sits between QPSK and 64-QAM: it needs about 4 dB more SNR than QPSK
for the same BER, but carries twice the bits per symbol.

### Expected result

Two semilogy curves: SER and BER. At high SNR, BER ≈ SER/4 (Gray coding).
Both fall from ≈ 0.1–0.2 at 0 dB to ≈ 10⁻⁴–10⁻⁶ at 20 dB.

---

## 4. QPSK Performance & Spectral Efficiency (`QPSK_performance.m`)

### What is QPSK?

**Quadrature Phase Shift Keying (QPSK)** is 4-PSK: 2 bits per symbol, with the
four constellation points at 45°, 135°, 225°, 315° (π/4 offset, so no points
lie on the axes). QPSK has the same BER as BPSK but doubles the data rate for
the same bandwidth — making it the workhorse of satellite and wireless links.

### Part A — Spectral efficiency

Using raised-cosine pulse shaping with roll-off factor **α = 0.25**:

```
Bandwidth            B  = Rs · (1 + α) = 10000 · 1.25 = 12.5 kHz
Bit rate             Rb = Rs · log2(M) = 10000 · 2    = 20 kbps
Spectral efficiency  SE = Rb / B       = 20k / 12.5k  = 1.6 bits/sec/Hz
```

These values are printed to the console and shown as a bar plot.
(With α → 0 the efficiency would reach the theoretical maximum of
2 bits/s/Hz for QPSK.)

### Part B — BER in AWGN

Same procedure as the 8-PSK script, but with M = 4 and π/4 phase offset:

1. 10,000 random 2-bit symbols → `pskmod(data, 4, pi/4)`
2. AWGN added at each SNR in 0:2:20 dB
3. `pskdemod` → `de2bi` expansion → BER per SNR point

### Theory — expected BER

QPSK (with Gray coding) has exactly the same *bit* error rate as BPSK:

```
BER = Q( √(2·SNR) )
```

At 8 dB ≈ 10⁻², at 10 dB ≈ 4×10⁻⁴, falling below 10⁻⁵ around 10.5 dB.

### Expected result

A BER curve matching theoretical QPSK/BPSK performance, plus a bar chart
showing the 1.6 bits/s/Hz spectral efficiency.

---

## Comparison Summary

| Scheme | Bits/symbol | BER @ 10 dB (approx.) | Spectral efficiency | Key trade-off |
|---|---|---|---|---|
| QPSK   | 2 | 4×10⁻⁴ | 1.6 b/s/Hz (α=0.25) | Lowest SNR needed, simple |
| 8-PSK  | 3 | ~10⁻²  | 3 b/s/Hz            | Constant envelope, but 3 dB worse than QPSK per bit |
| 16-QAM | 4 | ~10⁻²  | 4 b/s/Hz            | Best efficiency, needs amplitude linearity + more SNR |

**General rule:** moving to a denser constellation buys more bits per symbol
but requires more SNR for the same error rate — roughly 3 dB per extra bit/symbol
for PSK, and QAM exploits amplitude as well as phase to do somewhat better.

---

## Common building blocks (Communications Toolbox)

| Function | Purpose |
|---|---|
| `pskmod` / `pskdemod` | M-PSK modulation / demodulation (Gray-coded by default) |
| `qammod` / `qamdemod` | Square M-QAM modulation / demodulation |
| `awgn(x, snr, 'measured')` | Adds white Gaussian noise scaled to the measured power of `x` |
| `de2bi` | Converts integer symbols to binary row vectors for BER counting |
| `semilogy` | Log-scale y-axis — the standard way to plot BER/SER curves |

> **Note:** `de2bi` is the older Communications Toolbox function; in newer
> releases `bit2int` / `int2bit` are the recommended replacements.
