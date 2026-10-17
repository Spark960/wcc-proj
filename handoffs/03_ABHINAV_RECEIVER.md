# Abhinav — Question 20C: receiver and metrics

Read `00_GROUP_PLAN.md` and `DESIGN_FREEZE_AND_HANDOFFS.md` first. You own the **entire C sub-question**: synchronization, channel estimation/equalization, adaptive demodulation, payload recovery and CRC/PER measurement. Log received power/SINR, BER/PER, throughput and a latency or outage proxy across all six scenarios. Start now with a clean waveform plus an 8-sample prefix; Prisha's full channel can be integrated later.

## Deliverables

1. `receiveFrame.m` (or equivalent) that decodes a waveform without access to the true channel or original payload bits.
2. Metric functions or results-table code with exact denominators/units.
3. Receiver constellation and performance plots plus a six-scenario results table.
4. Notes on synchronization, estimation, equalization, adaptation and limitations.
5. Your complete handwritten C pages. Arrange for **all four names and signatures on every handwritten page** before scanning.

## Implementation steps

1. **Agree on the frame format with Lokesh.** Obtain preamble samples, pilots, carrier indices, header format, modulation normalization, CRC settings and padding rules. Make these shared protocol settings, not hard-coded guesses.
2. **Synchronize.** Search for the known preamble (for example by correlation); select the frame start; report failed detection as a frame failure. Demonstrate a received preamble/correlation peak for a representative case. Do not use Prisha's injected delay or truth frame index to choose the start in normal operation.
   Prisha will include a fixed 8-sample leading delay, but your decoder must **discover** it from the waveform.
3. **Demodulate OFDM.** Segment symbols, remove CP, FFT, extract pilot/data bins. Estimate complex channel response from known preamble/pilots and interpolate or use a clearly justified simple equalizer. A one-tap frequency-domain equalizer per active bin is a practical baseline. Show at least one raw and one equalized constellation.
4. **Decode adaptively.** Use the frame header or a documented mode-control rule to know QPSK/16-QAM/64-QAM. For adaptation, estimate channel quality from a prior frame or known pilots and feed a recommended mode to Lokesh for the **next** frame; record the chosen thresholds and default initial mode. Avoid choosing a mode with future/truth information.
5. **Recover and verify payload.** Undo padding, recover CRC bits, calculate CRC and record packet pass/fail. Compare recovered payload against Lokesh's original bits **only in the evaluation script** to calculate BER; the decoder itself must not receive the original bits.
6. **Define metrics exactly.** BER = erroneous payload bits / compared payload bits on aligned/known-length frames; exclude unaligned frames from BER and report their count. PER = failed synchronization/header/payload-CRC frames / attempted frames. Goodput = correctly delivered payload bits / total simulated transmitted frame airtime. Received power/SINR must use a stated receiver estimator; diagnostic truth is for offline checks only. The fixed latency proxy is expected repeated-transmission airtime `frame duration/(1−PER)` under an idealized independent-retry model, **not** measured network latency. Use 20 frames per case for smoke testing and 500 per case for final metrics.
7. **Run and report.** Produce one row for each `near/middle/edge × low/high interference` case. Include counts as well as ratios so PER=0 is understood as “zero observed failures in N frames.” Show BER/PER/goodput versus location/load or SINR, with axes and units.
8. **Functional checks.** First decode a no-impairment or very high-SNR frame and verify exact payload/CRC. Then check that worse channel/load usually degrades aggregate performance. If BER/PER behave unexpectedly, check bit ordering, symbol scaling, carrier indices, noise scaling, equalizer and CRC before producing report figures.

## Handoff contract

Take `rxWaveform`, public scenario settings and protocol/configuration fields. Do not use Prisha's true channel response in the receiver. Return a results table and representative plots to Soukaryo and Lokesh. Keep original payload bits only in the metric-comparison layer.

## What to write by hand for C

Draw Rx blocks; explain preamble synchronization, CP removal/FFT, pilot-based channel estimate, equalization, adaptive mode selection/demapping, CRC and payload recovery. Show formulas and denominators for BER, PER, goodput and the latency proxy. Include representative constellation/receiver plots and six-scenario results with an explanation of the trends. Insert figures/screenshots into the scan. Ensure **all four names and signatures** appear on every handwritten page.

## Done when

A clean test frame is recovered exactly; channel estimation uses only known training/pilots; CRC detects damaged frames; all six scenarios produce consistent counts/metrics; plots and the handwritten section use the same final run data.
