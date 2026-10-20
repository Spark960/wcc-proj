# Question 20C - Receiver design and implementation

Status: updated from the corrected MATLAB Online export. The latest run's
transmitter, channel and receiver checks passed and all eight run tables were
reconciled against their per-frame logs. The full diary retains older attempts;
its latest run completed without a logged error. The earlier timing-bug results
are preserved separately under `results/receiver_diagnostic_before_timing_fix/`.
Use the numerical tables below for the handwritten Part C contribution.

## 1. Objective and receiver architecture

My contribution is the receiver and performance evaluation of a single-antenna,
WLAN-inspired OFDM link. The receiver accepts the impaired complex waveform and
shared protocol configuration. It estimates timing and channel response, recovers
the transmitted payload, verifies its CRC and supplies a channel-quality report
for the next transmission. True channel taps and original payload bits are kept
outside the receiver and used only for offline validation.

Draw this block diagram:

Received samples -> preamble correlation/timing -> CP removal -> FFT ->
training-based channel estimation -> pilot correction/equalization ->
QPSK header and CRC-8 -> signaled QAM payload demapping -> CRC-16 -> recovered bits.

Draw a feedback arrow from the SINR estimator to the next frame's modulation
selector. Draw a separate evaluation block receiving the original payload and
the decoded output to calculate BER. This makes the separation from truth clear.

## 2. Shared frame parameters

| Parameter | Group baseline |
| --- | --- |
| Sampling rate / bandwidth | 20 MHz |
| FFT / cyclic prefix | 64 / 16 samples |
| Symbol duration including CP | 80 / 20e6 = 4 microseconds |
| Active carriers | 48 data and 4 pilots |
| Preamble | Two repeated known OFDM symbols |
| Header | One QPSK OFDM symbol |
| Payload | 96 bytes by default, followed by CRC-16 and padding |
| Modulations | QPSK, 16-QAM, 64-QAM |
| Antennas | 1 transmit, 1 receive; no MIMO detection |

These are shared design assumptions, not measurements from a real Wi-Fi device.
The maximum modeled path delay is 9 samples, below the 16-sample CP. The channel
is constant within a frame. No carrier-frequency offset or Doppler is currently
injected, so the implementation does not claim separate CFO/Doppler recovery.

## 3. Synchronization

For known preamble p[n], the receiver computes normalized correlation:

R[l] = |sum_n r[l+n] conj(p[n])|^2 /
       (sum_n |r[l+n]|^2 * sum_n |p[n]|^2).

A peak below 0.08 is rejected. This gate is a baseline algorithm parameter, not
a statistically optimized detection threshold. Timing hypotheses within one
CP length of the strongest peak are tested in correlation order. The first
hypothesis with a valid header marker, mode, length and CRC-8, and enough
received samples for the complete declared frame, is retained.
This helps when multipath creates delayed correlation peaks. Header validation,
not original payload bits or the injected 8-sample delay, selects timing.
If no valid header is recovered, the packet is counted as a failure.

Insert the correlation plot and explain the detected start. In multipath the
chosen FFT window need not equal the first physical arrival exactly.

## 4. Channel estimation and equalization

After CP removal, a normalized 64-point FFT produces Y[k]. The two received
training symbols Y1[k], Y2[k] and known training values Xp[k] give:

Hhat[k] = (Y1[k] + Y2[k]) / (2 Xp[k]).

This effective response includes propagation, transmitter amplitude scaling and
any timing-induced phase slope. The known preamble occupies all active carriers,
so an estimate is directly available on every data carrier.
For each header/payload symbol, the four pilots estimate a common complex gain:

g = sum_p conj(Hhat[p] P[p]) Y[p] / sum_p |Hhat[p] P[p]|^2.

The equalizer uses the conjugate response divided by its squared magnitude,
with a small numerical floor. Away from that floor this is a zero-forcing
one-tap equalizer: Xhat[k] = Y[k] / (g Hhat[k]). Deep fades can amplify noise.
Insert before/after constellation plots and the estimated channel magnitude.
Pilot correction tracks a common gain; it does not estimate independently
changing multipath on every payload symbol.

Reference: MathWorks, OFDM Resource Grid and Channel Estimation:
https://www.mathworks.com/help/comm/ug/ofdm-channel-estimation.html

## 5. Header, adaptive demapping and CRC

The QPSK header carries marker A7, a 16-bit frame ID, a 2-bit mode ID, a 16-bit
payload length in bits, CRC-8/ATM and padding. Mode IDs 0, 1 and 2 indicate QPSK,
16-QAM and 64-QAM. CRC-8 uses polynomial 0x07 and initial state zero.

Nearest-constellation-point decisions use the exact transmitter mapping and
unit-average constellation normalization. The payload length determines how
many OFDM symbols to read and where padding begins. The payload CRC is
CRC-16/CCITT-FALSE (polynomial 0x1021, initial state 0xFFFF, MSB first).
A packet is accepted only after valid framing and a passing payload CRC.
A CRC detects errors; it does not correct them and cannot guarantee that every
possible error pattern is detected. Offline undetected-error counts are logged.

The first frame uses QPSK. Later modes use the previous frame's estimated SINR;
a missing report falls back to QPSK. The current frame's mode always comes from
its header. Initially the group proposed 12/23 dB thresholds. The project runner
uses separate seeded calibration runs of all three fixed modes to choose new
thresholds from 0 to 60 dB. A candidate requires at least 50 selected frames and
observed PER <= 5% when selected by PRIOR-frame SINR. Unsupported modes receive
an infinite threshold and are disabled. This is an empirical pooled rule, not
a guarantee for every location or an optimal adaptation algorithm. Final tests
use separate channel seeds. The calibrated thresholds in this run were 40/44 dB.

## 6. Receiver power and SINR estimates

Total received power is calculated over the received sample buffer:

Prx(dBm) = 10 log10(mean(|r[n]|^2) / 0.001).

This includes desired signal, interference and noise; it is not desired-signal
power alone. It also includes the modeled leading buffer samples.
With averages over occupied training carriers, define:

D = mean(|Y1 - Y2|^2) / 2,
S = max(mean(|(Y1 + Y2)/2|^2) - D/2, small positive value),
SINRhat(dB) = 10 log10(S/D).

The difference estimates disturbance while the average estimates signal plus
residual disturbance. These assumptions are approximate: repeated interferer
pilots and correlated interference can bias the estimate. Training estimates
are logged only for valid headers; therefore report the number of valid SINR
estimates and avoid interpreting their mean as unbiased across all attempts.
The scatter plot compares this effective occupied-carrier estimate with offline
whole-waveform truth; their definitions differ as well as their errors.

## 7. Performance metrics

- BER = erroneous recovered payload bits / compared payload bits. Include
  CRC-failed but aligned payloads. Exclude unaligned or incomplete payloads and
  report the excluded count. If no bits are comparable, report BER as undefined.
- PER = failed packets / attempted packets. Synchronization, header, truncation
  and CRC failures count. Always show the numerator and denominator.
- Goodput = accepted payload bits / total transmitted frame airtime. Headers,
  preambles and CRC consume airtime but are not useful delivered bits.
- Latency proxy = mean frame airtime / (1 - PER); infinite when PER = 1.
  It is an idealized independent-retry approximation, not measured latency.
  Adaptive frame durations and failure dependence limit this approximation.
- Report a Wilson 95% PER interval. Zero observed failures does not prove zero
  underlying error probability. Interpret intervals conditional on this model
  and this location's fixed shadowing realization.

The time denominator excludes MAC contention, queueing, ACKs, interframe gaps,
feedback cost and actual retransmissions. Thus reported goodput is a PHY-level
metric. The model is uncoded and custom OFDM, not standards-compliant Wi-Fi.

## 8. Validation and measured simulation results

The latest MATLAB run reports passing transmitter, channel and receiver checks.
The receiver test suite covers all three modes, prefixes 0/8/23, complex gain,
multipath, high-SNR AWGN, CRC rejection and truncated/empty inputs. A regression
was added for dominant delayed paths at 2 and 5 samples after an initial run
revealed an early-return timing error. In the corrected final near-low run,
all 500 frames had comparable payload bits; the former 107 empty-payload
failures are absent. One 64-QAM payload now fails CRC with one bit error.

Evaluation used 20-frame smoke cases, separate seeded calibration with 100
frames per mode per scenario, and 500 frames per scenario for each fixed mode
and the final adaptive policy. Calibration selected thresholds of **40 dB and
44 dB**, confirmed in the saved MAT configuration. With a valid prior report,
use QPSK below 40 dB, 16-QAM from 40 to below 44 dB, and 64-QAM at or above
44 dB. Missing reports and the first frame use QPSK. These thresholds belong
to this experiment, not to all OFDM links.

### Final adaptive results

Every row represents 500 attempted packets. BER is conditional on comparable
payloads, whereas PER includes every failed packet.

| Scenario | Failed/500 | BER | BER-excluded frames | PER (%) | 95% PER interval (%) | Goodput (Mbps) | Latency proxy (us) |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: |
| near low | 1/500 | 2.604e-06 | 0 | 0.2 | 0.04–1.12 | 31.872 | 24.10 |
| near high | 38/500 | 0.000224 | 0 | 7.6 | 5.59–10.26 | 25.741 | 29.84 |
| middle low | 50/500 | 0.0003031 | 6 | 10.0 | 7.67–12.94 | 14.400 | 53.33 |
| middle high | 403/500 | 0.008941 | 155 | 80.6 | 76.91–83.83 | 3.104 | 247.42 |
| edge low | 285/500 | 0.003494 | 52 | 57.0 | 52.62–61.27 | 6.880 | 111.63 |
| edge high | 499/500 | 0.03646 | 466 | 99.8 | 98.88–99.96 | 0.032 | 24000.00 |

| Scenario | Total received power (dBm) | Estimated SINR (dB) | SINR estimates/500 | QPSK / 16-QAM / 64-QAM frames |
| --- | ---: | ---: | ---: | --- |
| near low | -34.48 | 60.40 | 500/500 | 1 / 0 / 499 |
| near high | -34.46 | 44.93 | 500/500 | 18 / 169 / 313 |
| middle low | -62.74 | 32.19 | 497/500 | 500 / 0 / 0 |
| middle high | -62.66 | 17.30 | 361/500 | 500 / 0 / 0 |
| edge low | -73.13 | 22.01 | 454/500 | 500 / 0 / 0 |
| edge high | -72.32 | 8.73 | 46/500 | 500 / 0 / 0 |

### Interpretation and comparison

Near-low operation predominantly used 64-QAM and achieved 31.872 Mbps at 0.2%
PER. In the matched fixed-QPSK run, near-low achieved 16 Mbps with zero observed
failures. Thus adaptation increased throughput in this case, with one observed
packet failure. Fixed 64-QAM achieved 31.936 Mbps at the same 0.2% PER; adaptation
has small initial-mode overhead and does not beat that fixed mode here.

Near-high adaptation achieved 25.741 Mbps but 7.6% PER, missing the 5% reliability
target. Fixed 16-QAM achieved 23.232 Mbps at 3.2% PER, so it provides a better
reliability/throughput trade-off for that scenario under the stated target.
The pooled calibration rule therefore does not guarantee per-scenario reliability.

At middle-low and edge-low, adaptation used QPSK throughout but PER was 10%
and 57%, respectively. Their goodputs, 14.4 and 6.88 Mbps, exceeded 5 Mbps, yet
both failed the reliability criterion. Only **1 of 3 low-load locations** met
both predeclared targets. High interference increased PER to 80.6% at middle
and 99.8% at edge. The edge-high latency proxy is 24000 us (24 ms), based on just
one successful packet out of 500; it is a model-based proxy with high uncertainty.

These results support an interference limitation under high load and inadequate
reliability under the combined fading/receiver model at weaker locations.
They do not isolate path loss, deep fades, synchronization or equalizer noise
amplification sufficiently to name a single dominant low-load mechanism.
Independent frame-to-frame fading also limits predictive SINR feedback. A
coding/interleaving or improved equalizer experiment would be a justified next
step, but no improvement from those changes has been demonstrated in this run.

The estimator plot broadly follows diagnostic SINR, with low-SINR outliers.
Only header-valid frames have estimates: edge-high contributes 46/500 estimates.
Consequently, the mean estimated SINR is conditional on successful header
recovery, not an unbiased summary of all channel realizations.

Insert these actual exported figures:

1. `results/receiver/final/receiver_example.png`: correlation, estimated channel,
   and before/after equalization for the first successful QPSK frame. It is an
   example, not the constellation for all adaptive frames.
2. `results/receiver/final/receiver_performance.png`: six-case BER, PER, goodput
   and latency proxy. Small BER values are better read from the table.
3. `results/receiver/final/receiver_sinr_validation.png`: effective training SINR
   versus offline diagnostic SINR, including estimation outliers.

### Source files and audit

The final numerical source is `results/receiver/final/receiver_summary.csv`;
`receiver_frames.csv` contains all 3000 attempts. Configuration, data and example
samples are retained in `receiver_run.mat`. Fixed-mode comparisons use the
corresponding `fixed_QPSK`, `fixed_16QAM` and `fixed_64QAM` summary files.
All eight run pairs reconcile in attempted frames, failures, bit errors,
compared bits, delivered bits, BER exclusions and goodput. No undetected payload
errors are logged. This audit is not proof that CRC can detect all possible errors.

## 9. Conclusion and handoff

The receiver recovered **1724 of 3000 packets** in the six-case adaptive
run. It performs synchronization, channel estimation/equalization, mode-aware
payload recovery and CRC checking without true-channel or original-payload
inputs. The 40/44 dB feedback rule delivered 31.872 Mbps at near-low with 0.2%
PER, but only 1/3 low-load locations met PER <= 5% and goodput >= 5 Mbps.
The implementation demonstrates the complete receiver chain; the tested system
configuration does **not** meet the full coverage/reliability objective.

Adaptive modulation is useful for near-low throughput but is not uniformly
superior to fixed modes. Report the failures and fixed-mode comparison honestly.
Give these results, figures, configuration and log to the analysis member for
the engineering decision. The 10/15/20 dBm power-selection study and real field
RSSI validation remain group analysis work; this receiver evaluation uses the
15 dBm baseline and does not establish an optimal transmit power.

Include your contribution in the group table and follow the assignment's
handwritten-page name/signature requirements.
