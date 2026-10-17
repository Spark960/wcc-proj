# Lokesh's transmitter: value justifications and assignment audit

**Audit date:** 17 October 2026. **Scope:** Question 20A and its interface to the rest of Question 20. The two assignment PDFs in this folder have the same Question 20 technical text, but different FISAC submission instructions and deadlines. This document separates what the PDFs require from what we chose for the prototype. The MATLAB code is a **generic, WLAN-inspired OFDM link**, not an IEEE 802.11-compliant Wi-Fi transmitter or a deployed cellular radio.

## What the PDFs actually require

For **A**, the assignment requires (1) framed preamble/payload/CRC traffic and OFDM with adaptive QPSK/16-QAM/64-QAM or justified equivalent; (2) configurable transmit power, antenna gain and bandwidth, with 2×2 MIMO **optional**; (3) one permitted app dataset used to calibrate or validate a link parameter; and (4) transmitter spectrum/resource mapping plus nominal throughput and EIRP/link calculations. The common requirements also demand a reproducible payload, complete transmitter→channel→receiver chain, quantitative validation and a justified final engineering decision. The later project evidence list includes architecture, field evidence, parameter/link-budget tables, Tx/Rx plots and BER/PER/throughput/coverage results.

**Present status:** The code implements A's frame/OFDM/configuration/plots/calculations and a *causal mode-selection function*, but adaptive operation across frames is not yet demonstrated because the receiver's previous-frame SINR feedback is pending. No field dataset has yet been supplied, so the field-calibration/validation requirement is **not complete**. The complete project is likewise incomplete until Prisha, Abhinav and Soukaryo's parts are integrated. Do not tell the teacher the full assignment is finished.

## Why each chosen value exists

| Value in `code/getConfig.m` or frame code | Reason you can defend | Status / caution |
| --- | --- | --- |
| **1×1 antennas; no MIMO** | The PDF makes 2×2 MIMO optional. One antenna isolates the required OFDM, propagation and receiver features while keeping the four sections integrable. | Valid scope choice; do not claim MIMO results. |
| **20 MHz channel and sample rate** | A familiar WLAN-sized baseline. The 20 MHz non-HT OFDM example in MathWorks uses 20 MHz sampling, 64 FFT samples, 16 CP samples, 48 data carriers and 4 pilots. `sampleRateHz` now derives from `bandwidthHz`, so changing the chosen bandwidth also changes timing/rate calculations. | Design choice, **not measured channel occupancy**. All group modules must use this same sample rate. If the measured AP uses a different channel width, state that mismatch. |
| **64-point FFT** | Gives 64 orthogonal subcarrier positions at manageable computational cost and matches the cited non-HT reference geometry. Spacing = 20 MHz/64 = **312.5 kHz**. | WLAN-inspired, but the custom frame is not an 802.11 PPDU. |
| **16-sample CP** | One quarter of the useful 64-sample symbol. At 20 MHz, useful time = **3.2 µs**, CP = **0.8 µs**, total = **4 µs**. The CP can guard a modeled multipath delay spread shorter than its duration. | Prisha must keep channel delays within this assumption or explain residual ISI. CP consumes 20% of transmitted symbol time, so it reduces rate. |
| **48 data + 4 pilots; 12 nulls including DC** | Four known pilot positions give the receiver channel/phase references; null DC and edge guards avoid using every FFT bin. The data/pilot counts match the non-HT example. Carriers are `-26:-1` and `1:26`; pilots `[-21 -7 7 21]`, leaving 48 data positions. | Need Abhinav to use the **same exact bins and pilot values**. 52 active-bin spacings span about **16.25 MHz** of a nominal 20 MHz channel; do not call 20 MHz the exact occupied width. |
| **Pilot values `[1 1 1 -1]`** | Nonzero, known BPSK reference values allow a complex channel estimate by comparing received to sent pilots. The particular signs are a reproducible custom choice. | Fixed signs are sufficient for a baseline static/slowly varying channel; no Wi-Fi pilot polarity sequence is implemented. |
| **Two identical known preamble OFDM symbols** | Repetition gives the receiver a recognizable timing structure; known occupied-bin BPSK values allow initial channel estimation. | A custom training preamble. This is **not** the official Wi-Fi short/long training field. Abhinav must implement actual synchronization; the current clean loopback assumes a known start. |
| **One QPSK header symbol** | QPSK is the most robust of our three payload modulations. The header conveys marker, frame ID, modulation and payload length so the receiver can decode the following symbols. One symbol carries 48×2 = **96 coded bits**. | The custom header occupies 50 bits and has 46 zero-fill bits; no forward error correction. Under a poor channel, header failure must count toward PER. |
| **Header marker `0xA7`** | A fixed nonzero marker helps reject a false header after candidate synchronization. The exact byte is an arbitrary protocol identifier. | It is not a standard sync word; header CRC and preamble provide the stronger checks. |
| **16-bit frame ID and 16-bit payload length** | Large enough for this experiment's repeated frames and 96-byte payload. It gives explicit bookkeeping and decoding length. | ID wraps after 65,536; code rejects values outside 0…65,535. |
| **2-bit mode ID** | Three modes need two bits (`00` QPSK, `01` 16-QAM, `10` 64-QAM; `11` reserved). | Must be decoded from the header, not passed as hidden truth to the final receiver. |
| **Header CRC-8/ATM (`0x07`, init 0)** | Small additional error-detection check for header control fields. It fits in the single QPSK header symbol. | Extra design choice; the assignment does not demand a header CRC. Header check implementation is custom, so match exact bit order at receiver. |
| **96-byte = 768-bit payload** | Small fixed frame makes repeated six-scenario simulation quick and exposes preamble/header/CRC overhead in throughput calculations. | Arbitrary baseline, not assignment-specified. It must stay fixed when comparing scenarios. |
| **Seed `3128 + frameId`; preamble seed `2026`** | `3128` recalls the course code; frame ID changes payload deterministically; `2026` fixes the training sequence. Runs are reproducible without deriving private registration numbers. | The exact seed values carry no physical meaning. Do not claim registration-derived traffic. Original payload bits are metric truth only, not decoder input. |
| **Payload CRC-16/CCITT-FALSE, polynomial `0x1021`, init `0xFFFF`, MSB-first** | CRC is explicitly required to detect a corrupted frame. A 16-bit CRC gives modest overhead (16/768 ≈ **2.08%** of payload size) and is straightforward for the receiver to reproduce. | No error correction. This precise *variant* is custom for the project and must not be confused with every standard using the same polynomial. The known `123456789` vector produces `0x29B1` in MATLAB. |
| **Gray-coded QPSK / 16-QAM / 64-QAM** | These are the modulation choices named by the PDF. Bits per data carrier = **2 / 4 / 6**. Gray coding limits the number of bit changes between adjacent constellation points. | No FEC/interleaving. The resulting raw rates are **not standard Wi-Fi data rates**. |
| **Unit-average-power QAM constellation and frame-average power normalization** | Makes power comparisons across modulation modes consistent. After complete-frame normalization, the mean sample power is set to the configured watts. | The normalization is a complex-baseband simulation convention, not a calibrated radio voltage measurement. The channel and noise model must use the same convention. |
| **15 dBm transmit power** | A moderate numerical example that lets link-budget and waveform scaling be tested. It corresponds to `10^((15−30)/10) = 0.0316228 W` under the chosen convention. | **Assumption, not measured access-point power or a regulatory claim.** Soukaryo/Prisha must replace or calibrate it if an absolute RSSI comparison is attempted. |
| **2 dBi Tx gain, 0 dB feeder loss, 0 dBi Rx gain** | Simple reference link-budget assumptions; `0 dBi` means isotropic reference gain, and zero cable loss avoids pretending to know a cable. | None is measured. Do not silently equate phone/AP antennas with these values. |
| **12 and 23 dB mode thresholds; QPSK first frame** | A placeholder ordering: use more robust modulation at lower reported quality and higher-order modulation at higher quality. Initial QPSK avoids needing a non-existent previous report. The feedback is applied to the **next** frame, so it is causal. | **Not yet justified numerically.** Abhinav and Soukaryo must obtain PER-vs-SINR results, choose target PER/throughput, tune cutoffs, and run the adaptive loop. Until then, say “provisional thresholds,” not “optimized.” |

MathWorks references for the WLAN-like 20 MHz/64/16/48/4 geometry and timing: [non-HT OFDM information](https://www.mathworks.com/help/wlan/ref/wlannonhtofdminfo.html), [non-HT timing and modulation table](https://www.mathworks.com/help/wlan/ref/wlannonhtconfig.html). Known pilots and CP roles: [OFDM resource grid and channel estimation](https://www.mathworks.com/help/comm/ug/ofdm-channel-estimation.html). Modulation and normalization: [QAM documentation](https://www.mathworks.com/help/comm/ref/qammod.html). CRC polynomial/error-detection context: [CRC configuration](https://www.mathworks.com/help/comm/ref/crcconfig.html), [CRC explanation](https://www.mathworks.com/help/comm/ug/cyclic-redundancy-check-codes.html). These references explain the concepts and geometry; they do **not** certify this custom waveform as Wi-Fi compliant.

## Recalculate the key numbers at the board

- **Subcarrier spacing:** `20,000,000 / 64 = 312,500 Hz`.
- **Useful symbol/CP/whole symbol:** `64/20e6 = 3.2 µs`; `16/20e6 = 0.8 µs`; `80/20e6 = 4 µs`.
- **Continuous uncoded OFDM rate:** `48 data carriers × {2,4,6} bits ÷ 4 µs = {24,48,72} Mbps`. This includes CP time but excludes frame preamble/header and assumes no FEC. As a channel-bandwidth-normalized reference, that is `{1.2,2.4,3.6}` bit/s/Hz.
- **Payload-frame airtime rate (zero errors):** 768 payload bits + 16 CRC bits; payload OFDM symbols = `ceil(784 / (48 × bits/carrier)) = {9,5,3}`. Add 2 preamble + 1 header symbol to obtain `{12,8,6}` symbols and `{48,32,24} µs`. Thus `768 bits / frame time = {16,24,32} Mbps`. This includes our preamble/header/CRC/padding, but **not** MAC overhead, errors or retransmissions. It is a nominal payload rate, not measured goodput.
- **EIRP:** `15 dBm + 2 dBi − 0 dB = 17 dBm`. Received power later requires `Pr(dBm) = EIRP + Gr − path loss − other losses` with Prisha's calibrated/assumed model. The group must not add Tx gain a second time when applying path loss.
- **Power scaling:** `P(W) = 10^((15−30)/10) = 0.0316228 W`. MATLAB verified `mean(abs(txWaveform).^2)` at this value for all three modes. This uses the simulation's nominal 1-ohm convention.

## What was actually verified in MATLAB R2026b

On 17 October 2026, `code/checkLokeshTx.m` and `code/runLokeshTx.m` completed without error in the installed MATLAB R2026b. The checks covered the CRC-16 known vector; deterministic waveform from identical seeds/configuration; expected QPSK/16-QAM/64-QAM frame lengths; configured mean waveform power; clean, zero-impairment OFDM recovery of header, payload and CRC; and the raw/frame rate table. Figures `figures/tx_resource_mapping.png` and `figures/tx_spectrum.png` were generated.

**Verification boundary:** `txIdealLoopback.m` knows the frame boundary and uses a flat pilot gain. It is a transmitter sanity check, **not** Abhinav's required receiver. The transmitter spectrum is an uncalibrated relative-power plot of one frame, **not** a regulatory spectral-mask or measured RF spectrum. The field Wi-Fi app has not measured our generated complex baseband signal; it can support a path-loss/RSSI trend comparison only after actual field readings are recorded and model assumptions are stated.

## Requirement-by-requirement status against Question 20

| PDF requirement | Evidence now | What remains |
| --- | --- | --- |
| A: framed preamble/payload/CRC, OFDM, QPSK/16-QAM/64-QAM | Implemented and clean-loopback tested in `code/` | Final channel/receiver validation; show adaptive **sequence** driven by prior SINR |
| A: configurable Tx power, gain, bandwidth; MIMO optional | `getConfig.m` and derived sample rate; 1×1 selected | Keep group channel/link budget consistent; no MIMO claim |
| A: permitted field dataset used for link parameter | Planned RSSI trend comparison | **Missing** real readings/screenshots and documented calibration/validation |
| A: spectrum/resource map, throughput/EIRP | Generated figures and checked rates/EIRP | Insert into handwritten A pages; use final parameters |
| B: path loss, shadowing, fading, AWGN, extra impairment; ≥3×2 scenario | Interface and assumptions defined | **Missing** Prisha's channel and six-case run |
| C: sync, estimation/equalization, demodulation, CRC/PER and metrics | Header/preamble/pilots provided as receiver inputs | **Missing** Abhinav's actual receiver and BER/PER/goodput/outage or latency proxy |
| D: app trend, limiting factor, final configuration against explicit targets | Analysis plan defined | **Missing** Soukaryo's real dataset, comparison, targets and decision |
| Common: complete reproducible end-to-end MATLAB project | Transmitter seed and MATLAB sanity checks | **Not yet complete** until B/C/D integration, README and result reproduction |

## Likely teacher questions — direct answers

**“Why these OFDM numbers?”** They make a reproducible 20 MHz OFDM baseline and match MathWorks' non-HT 64 FFT / 16 CP / 48 data / 4 pilot geometry. We use custom framing and no FEC, so we call it WLAN-inspired rather than standards-compliant.

**“Why is your 64-QAM rate 72 Mbps when Wi-Fi lists 54 Mbps?”** Our 72 Mbps is `48×6/4 µs`, the **uncoded gross OFDM bit rate**. A standard 54 Mbps non-HT mode applies a 3/4 coding rate. Our custom frame's zero-error payload airtime rate is 32 Mbps after its preamble/header/CRC/padding. Actual goodput is lower when frames fail or are retransmitted.

**“Why 15 dBm and 2 dBi?”** They are explicit simulation assumptions for a reproducible example, not claims about the measured access point. They give a calculable 17 dBm EIRP. We can calibrate/replace them if the field measurement supports an absolute link budget; otherwise we validate the RSSI *trend* and state the uncertainty.

**“How is modulation adaptive?”** The transmitter has three QAM modes and a function that selects the next frame's mode from the prior received SINR report; the first frame uses QPSK. The current 12/23 dB thresholds are placeholders. We will justify final thresholds using receiver PER/goodput curves and a stated reliability target. We cannot claim adaptive performance yet.

**“Does your phone measure this simulated transmitter?”** No. The phone observes a real permitted Wi-Fi link. Its RSSI readings are used to calibrate/validate a propagation or coverage trend, with unknown AP EIRP/device bias documented. We do not claim byte-for-byte waveform identity.

**“Why no MIMO or mobility?”** The PDF makes 2×2 MIMO optional and permits **interference** as the extra impairment instead of Doppler. The required 3-location × 2-load coverage scenario still needs to be completed. We will not claim a MIMO or mobility evaluation that we did not run.

**“How many frames are enough for PER?”** A zero-error result over 100 frames does not prove PER below 1%. The simple upper 95% bound is approximately `3/N`, so about 300 clean frames are needed even for a rough <1% bound, and around 3000 for <0.1%. The group should set frame count from the chosen reliability target and report both failure count and trial count.

## Submission audit

The **FISAC-2 handwritten write-up** is due **25 October 2026, 5:00 PM** as **one PDF**. Each person completes one entire sub-question. The PDF says each student writes their name and signature on **every page**; safest literal practice is for **all four students to sign every handwritten page**. Lokesh merges and uploads. The **FISAC-1 project** is due **1 November 2026, 5:00 PM** as **one PDF plus one ZIP** of all experiment files; only the lead uploads. Both require front matter with ICT 3128, subject name, assignment date **29-08-2026**, section, group number, all names and registration numbers, plus a contribution table. Use a PDF name of the form `GroupNumber_QuestionNumber`, e.g. `G01_Q20.pdf`. The group number, section and registration numbers still need to be filled from real group details.
