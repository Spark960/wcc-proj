# Question 20 final handwritten copy

Use this as the final text to write **by hand**, with one member completing each entire assigned section. The project is a custom, single-antenna WLAN-inspired OFDM simulation, not a standards-compliant Wi-Fi packet. Values called *assumed* are model choices; *simulated* results come from MATLAB; *observed* RSSI values come from the phone export. Bold instructions about figures and assembly are directions to the team, not sentences to copy into the answer. Add all four names and signatures to **every handwritten page** before scanning. Fill the identity blanks with the team's actual details.

## First sheet and contribution table

Write: ICT 3128, Wireless Communication and Computing, assignment date 29-08-2026, section ______, group number ______, Question 20, and all four full names and registration numbers. Contribution table: Lokesh - A transmitter and integration; Prisha - B propagation/channel; Abhinav - C receiver and metrics; Soukaryo - D field measurement, analysis and decision. Replace the short names with the exact names used by the college. The 25 October handwritten submission is one PDF named `GroupNumber_Q20.pdf`; the 1 November project submission is a PDF plus one experiment ZIP.

## A. Transmitter design and implementation - Lokesh

**Aim and design.** We built a reproducible, framed 1 x 1 OFDM transmitter with a known preamble, a control header and a 96-byte payload protected by CRC-16. The payload bits are generated from seed `3128 + frameId`, so a run can be repeated. The first frame uses QPSK. Later frames select QPSK, 16-QAM or 64-QAM using the **previous** receiver-estimated SINR. The final tested thresholds are 40 and 44 dB: below 40 use QPSK, from 40 to below 44 use 16-QAM, and at least 44 use 64-QAM. A missing estimate falls back to QPSK. These thresholds are simulation-specific and do not ensure reliability at every location.

**Block diagram to draw.** Seeded bits -> CRC-16 -> QAM mapping -> 48 data carriers + four pilots -> 64-point IFFT -> 16-sample cyclic prefix -> framed preamble/header/payload -> transmit-power scaling -> channel. Draw a feedback arrow from the receiver's previous-frame SINR estimate to the next-frame mode selector. Do not show the true simulated channel feeding the selector.

**Frame and parameters.** The sample rate and nominal bandwidth are 20 MHz. Of 64 FFT bins, 48 carry data, four are pilots at -21, -7, 7 and 21, and 12 are null including DC. Each OFDM symbol has 64 useful plus 16 CP samples, giving `(64+16)/20 MHz = 4 microseconds`. A frame begins with two repeated known OFDM preamble symbols, followed by one QPSK header symbol containing marker `A7`, frame ID, modulation ID, payload length and CRC-8/ATM. The payload is 96 bytes, followed by CRC-16/CCITT-FALSE and padding. CRC-16 uses polynomial `0x1021`, initial value `0xFFFF`; CRC-8 uses polynomial `0x07` and zero initial value. The transmitted complex waveform is normalized to the configured mean power.

**Rates and link budget.** Assumed transmit power is 15 dBm, transmit antenna gain 2 dBi, and feeder loss 0 dB; hence EIRP is `15+2-0 = 17 dBm`. Receiver gain is 0 dBi. The uncoded continuous-symbol rates are `48 x bits/carrier / 4 microseconds`, namely 24, 48 and 72 Mbps for QPSK, 16-QAM and 64-QAM. For this 96-byte payload, preamble/header/CRC overhead makes the *zero-error payload airtime rates* 16, 24 and 32 Mbps. Those are calculated rates, not measured goodput. At 15 dBm the mean baseband sample power is `10^((15-30)/10) = 0.0316228 W` in the model's nominal one-ohm convention. Antenna gain is applied once in the propagation link budget.

**Validation and limitation.** MATLAB checks reproduced identical seeded frames, confirmed waveform power, and recovered each modulation through a clean ideal loopback. The actual receiver tests and packet error results are in C. A phone Wi-Fi RSSI survey can check the relative propagation trend, but it cannot prove that the phone transmits this custom waveform. MIMO was optional and was not implemented.

**Attach after this section's OFDM explanation:** `lokesh/figures/tx_resource_mapping.png` (label occupied data, pilots, null/DC) and `lokesh/figures/tx_spectrum.png` (label simulated transmitter spectrum). Add captions "Figure A1" and "Figure A2". If the printed spectrum axes are unclear, redraw them by hand with units.

The 15 dBm, 17 dBm-EIRP configuration above is the reference model. Part D reports a separately tested 20 dBm, 22 dBm-EIRP fixed-QPSK fallback; it does not meet the edge reliability target.

## B. Channel and propagation model - Prisha

**Aim and six cases.** We applied path loss, log-normal shadowing, four-tap Rayleigh multipath, thermal AWGN and independent co-channel OFDM interference to the transmitter waveform. Three assumed positions are near (2 m, 0 dB obstacle loss), middle (8 m, 6 dB) and edge (20 m, 15 dB). Each has low and high traffic interference at -110 and -80 dBm receiver input, making six cases. These distances, obstacle losses and traffic powers are simulation assumptions, not field readings.

**Equations.** At 2.437 GHz and one metre, `PL0 = 20 log10(4 pi d0 fc / c)`. At location i, `PL_i = PL0 + 10(3.2) log10(d_i/d0) + wall_i + shadow_i` dB. One seeded Gaussian shadowing value with standard deviation 4 dB is drawn **per location** and held for all frames and both loads there. The realized values are near +1.436 dB, middle +4.618 dB and edge -6.633 dB. With EIRP 17 dBm and zero receive gain, predicted desired power is `17 - PL_i` dBm when the wall and shadow terms are included in PL. The four tap delays are 0, 2, 5 and 9 samples, with average relative powers 0, -3, -6 and -9 dB normalized to unit average total channel power. Taps change each frame but remain constant inside that frame. The 9-sample maximum delay is below the 16-sample CP.

**Noise and interference.** Thermal noise is approximately `-174 + 10 log10(20e6) + 6 = -95 dBm` using a 6 dB noise figure. A separately seeded QPSK OFDM waveform with an asynchronous offset models co-channel traffic; it is scaled to -110 or -80 dBm. Complex amplitude uses `10^(powerGainDb/20)`. We prepend eight samples so the receiver must detect timing. The channel returns received samples separately from diagnostic truth; the decoder does not receive true taps or original bits.

**Calculated and simulated table.** Write a six-row table with columns location/load, assumed distance, obstacle loss, interference power, predicted desired power and diagnostic SINR. The values are: near/low `2, 0, -110, -34.25 dBm, 59.67 dB`; near/high `2, 0, -80, -34.25, 44.70`; middle/low `8, 6, -110, -62.70, 31.28`; middle/high `8, 6, -80, -62.70, 16.30`; edge/low `20, 15, -110, -73.19, 20.80`; edge/high `20, 15, -80, -73.19, 5.83`. These are the 500-frame baseline channel results. The -95 dBm noise and the shadowing draws are model values. The near-to-edge desired-power trend falls by about 39 dB; high interference lowers diagnostic SINR by about 15 dB at each position. Frame fading causes variation around location averages.

**Field link and limitations.** The newest Wi-Fi Analyzer export has three near/middle/far sections. The earlier candidate BSSID `d8:38:0d:1b:40:c1` is absent at far. We instead use one radio present in all sections, AP1 BSSID `d8:38:0d:1b:40:51`, 2.4 GHz channel 7 (2442 MHz). Its 7, 11 and 6 timestamped export rows have descriptive RSSI means of -68.71, -72.45 and -94.00 dBm. The corresponding near-to-middle and near-to-edge drops are 3.74 and 25.29 dB, while the simulated drops are 28.34 and 38.77 dB. Both weaken toward far, but the middle field drop is much smaller. Many repeated RSSI values may be cached scans, so these rows do not establish independent-sample uncertainty. Actual physical distances, obstacles, AP power and phone model were not recorded. This checks only a broad direction, not calibration of the channel model.

**Attach after the six-case table:** `results/received_power_comparison.png` as Figure B1 and `results/sinr_by_scenario.png` as Figure B2. `results/tx_channel_waveform.png` may be Figure B3 beside the eight-sample-delay explanation. Caption all three as **simulated channel diagnostics**.

## C. Receiver design and implementation - Abhinav

**Architecture.** The receiver accepts only impaired samples and the shared configuration. It correlates against the known preamble to locate a frame, removes CP, takes the FFT, estimates the channel from the two training symbols, uses pilots to track a common complex gain, equalizes data bins, decodes the QPSK header, demaps the signaled payload mode and checks CRC-16. Original payload bits and true channel coefficients are used only by the offline evaluator. Draw this chain and the previous-frame SINR feedback arrow.

**Synchronization and equalization.** Normalized correlation is `R(l)=|sum r(l+n)conj(p(n))|^2 / [(sum |r(l+n)|^2)(sum |p(n)|^2)]`. A peak below 0.08 is rejected. The receiver searches timing hypotheses within one CP of the peak, validating marker, header CRC and complete-frame length; it does not use original payload bits to choose timing. For each active carrier, `Hhat=(Y1+Y2)/(2 Xp)` from the two known training symbols. The four pilots estimate a common complex correction per data symbol. Division by the corrected channel estimate equalizes each carrier. Deep fades can amplify noise, and this receiver does not model Doppler or carrier-frequency offset.

**Metrics.** BER equals wrong recovered payload bits divided by compared bits on aligned frames; excluded frames are reported. PER equals failed frames divided by all attempted frames, including sync/header/CRC failures. Goodput equals accepted payload bits divided by total transmitted frame airtime. The latency proxy is mean frame airtime divided by `(1-PER)`; it is not measured network latency and omits contention and ACK overhead. Report 95% Wilson PER intervals from the CSV if space permits. Receiver power includes desired signal, noise and interference. Training-based SINR is an estimate; diagnostic truth is used only for checking it.

**Tests and results.** Functional tests passed clean recovery for QPSK, 16-QAM and 64-QAM, unknown prefix lengths, complex gain, multipath, high-SNR AWGN, corrupted payloads and truncated buffers. Separate calibration selected 40/44 dB previous-frame SINR thresholds. Each final adaptive case attempted 500 frames. Write this table: near/low `1/500 failed, PER 0.2%, goodput 31.872 Mbps`; near/high `38/500, 7.6%, 25.741`; middle/low `50/500, 10.0%, 14.400`; middle/high `403/500, 80.6%, 3.104`; edge/low `285/500, 57.0%, 6.880`; edge/high `499/500, 99.8%, 0.032`. BER and excluded-frame details are in `results/receiver/adaptive_500/receiver_summary.csv`; copy that smaller numeric table if enough space. Near-low used 64-QAM in 499/500 frames. Middle-low and edge-low used QPSK in all 500 but still missed the 5% PER target. The full target is met at only one of three low-load locations.

**Attach after synchronization/equalization:** `results/receiver/adaptive_500/receiver_example.png` as Figure C1. **Attach after the metrics table:** `results/receiver/adaptive_500/receiver_performance.png` as Figure C2 and `results/receiver/adaptive_500/receiver_sinr_validation.png` as Figure C3. State that C3 includes only frames with a valid SINR estimate and compares different SINR definitions.

## D. Analysis, validation and engineering decision - Soukaryo

**Field method and evidence.** We used the three dot-separated near, middle and far Wi-Fi Analyzer AP-list exports provided on 24 October 2026 between 20:15 and 20:20 IST. We tracked the same 2.4 GHz radio by its BSSID `d8:38:0d:1b:40:51`, labeled AP1, on channel 7 (2442 MHz). The original 115,582-byte text is preserved in `data/raw/`; `data/field_rssi.csv` contains only its 24 real AP1 rows, with their actual export timestamps and RSSI values. The rows are 7 near, 11 middle and 6 far. The far AP disappears from the last four export timestamps. Repeated values, especially six identical -94 dBm far entries, may be due to scan throttling and must not be described as independent fresh measurements. The earlier 7:34/7:36/7:38 pm time-graph screenshots belong to a different session and are not the source of the 20:15–20:20 AP1 numbers. The assignment asks for a field input and a trend comparison but does not set a per-location sample count.

| Location | Export rows | RSSI values (dBm) | Descriptive mean |
| --- | ---: | --- | ---: |
| Near | 7 | -67 (five), -73 (two) | -68.71 dBm |
| Middle | 11 | -75 (one), -71 (six), -74 (four) | -72.45 dBm |
| Far/edge | 6 | -94 (six) | -94.00 dBm |

**Three-point trend comparison.** The simulated desired power averages are -34.40, -62.74 and -73.16 dBm at near, middle and edge. Relative to near, the simulated middle and edge drops are 28.34 and 38.77 dB. The mean exported AP1 RSSI drops are 3.74 and 25.29 dB. Thus the field drops are 24.60 and 13.48 dB smaller than simulated. The broad near-to-far direction agrees, but the middle loss does not closely match. Unknown geometry/walls, AP transmit power, phone reporting, scan caching and different RF channels may contribute; this dataset cannot isolate those effects. The measured radio is on channel 7 rather than the simulated channel 6. The phone Wi-Fi RSSI is not a calibrated measurement of our custom OFDM waveform.

**Targets and current evidence.** The group's predeclared low-load targets are PER at most 5%, goodput at least 5 Mbps, and coverage of all three locations meeting both. At the assumed 15 dBm baseline, near-low passes (0.2%, 31.872 Mbps); middle-low fails PER (10.0%, 14.400 Mbps); edge-low fails PER (57.0%, 6.880 Mbps). Thus coverage is only 1/3. High load is a stress test: near PER rises from 0.2% to 7.6%, middle from 10.0% to 80.6%, and edge from 57.0% to 99.8%. High-load interference is a major limitation. At low load, weaker-location reliability is also limited; these results alone do not isolate fading, path loss and receiver behavior to one cause. Bandwidth and mobility were not varied.

**Power study and engineering decision.** MATLAB R2026b passed the transmitter, channel and receiver checks and ran 500 frames for each of six scenarios under each of 12 matched-seed configurations: 10, 15 and 20 dBm crossed with fixed QPSK, 16-QAM, 64-QAM and the 40/44 dB previous-frame adaptive rule. No configuration met the 5% PER and 5 Mbps goodput targets at all three low-load locations. The table below gives low-load PER; each value is based on 500 frames.

| Tx power | Rule | Near PER | Middle PER | Edge PER | Worst-location goodput |
| --- | --- | ---: | ---: | ---: | ---: |
| 10 dBm | QPSK | 0.0% | 26.6% | 80.6% | 3.104 Mbps |
| 10 dBm | 16-QAM | 0.2% | 64.8% | 99.2% | 0.192 Mbps |
| 10 dBm | 64-QAM | 0.6% | 89.6% | 100.0% | 0 Mbps |
| 10 dBm | adaptive | 0.6% | 26.6% | 80.6% | 3.104 Mbps |
| 15 dBm | QPSK | 0.0% | 10.0% | 57.0% | 6.880 Mbps |
| 15 dBm | 16-QAM | 0.0% | 35.6% | 90.4% | 2.304 Mbps |
| 15 dBm | 64-QAM | 0.2% | 69.4% | 99.2% | 0.256 Mbps |
| 15 dBm | adaptive | 0.2% | 10.0% | 57.0% | 6.880 Mbps |
| 20 dBm | QPSK | 0.0% | 3.4% | 33.0% | 10.720 Mbps |
| 20 dBm | 16-QAM | 0.0% | 15.4% | 67.6% | 7.776 Mbps |
| 20 dBm | 64-QAM | 0.0% | 41.4% | 92.6% | 2.368 Mbps |
| 20 dBm | adaptive | 0.0% | 5.4% | 33.0% | 10.720 Mbps |

The lowest worst-location PER is 33.0%, shared by 20 dBm QPSK and adaptive, and both have 10.720 Mbps worst-location goodput. We choose **20 dBm fixed QPSK as the best tested fallback**, because it also meets both low-load targets at near and middle (2/3 locations); the adaptive rule misses middle's PER limit at 5.4%. It does **not** meet the required 3/3 coverage target, so it is not a final validated design. At 20 dBm QPSK, edge-low had 165/500 failed frames, while middle-high and edge-high had 284/500 and 477/500 failures. Raising power reduced low-load errors, but severe interference remained. A specific next experiment is to add forward-error-correction coding and interleaving, then rerun the same 500-frame matched-seed six-case study; its benefit is unverified.

**Attach beside the field method:** a legible excerpt of the new AP-list export table or the 24-row `data/field_rssi.csv`, showing BSSID/channel, timestamps and values; cite the full original text in `data/raw/`. **Attach beside the trend paragraph:** `results/receiver/power_study/field_trend_preliminary.png` as Figure D1, captioned "Means of 7/11/6 timestamped AP1 export rows, possibly cached; simulated curve aligned at near for trend only." **Attach beside the power table:** `results/receiver/power_study/power_study_low_load_per.png` as Figure D2, captioned "MATLAB simulated low-load PER, 500 frames per scenario." The earlier `figures/field/` time graphs may illustrate the app interface only; label them as a separate 19:34–19:38 session if included. Draw the two diagrams in `report/FLOWCHARTS_TO_DRAW.md` and follow `report/FINAL_ASSEMBLY_GUIDE.md` for page order.

**Final tested fallback across all six cases.** Copy this compact table below the power study. It reports the selected 20 dBm fixed-QPSK run, not the 15 dBm reference. Its assumed EIRP is 22 dBm.

| Scenario | Failed / 500 | PER | Goodput |
| --- | ---: | ---: | ---: |
| Near, low traffic | 0 | 0.0% | 16.000 Mbps |
| Near, high traffic | 1 | 0.2% | 15.968 Mbps |
| Middle, low traffic | 17 | 3.4% | 15.456 Mbps |
| Middle, high traffic | 284 | 56.8% | 6.912 Mbps |
| Edge, low traffic | 165 | 33.0% | 10.720 Mbps |
| Edge, high traffic | 477 | 95.4% | 0.736 Mbps |

## Final assembly check

Before scanning, fill the section/group/registration blanks, verify figure captions, and have all four students sign every handwritten page. The handwritten assignment is due 25 October 2026 at 5:00 PM. The project PDF and experiment ZIP are due 1 November 2026 at 5:00 PM. The team lead uploads each submission.
