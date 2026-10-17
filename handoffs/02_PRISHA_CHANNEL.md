# Prisha — Question 20B: channel and propagation

Read `00_GROUP_PLAN.md` and `DESIGN_FREEZE_AND_HANDOFFS.md` first. You own the **entire B sub-question**: path loss, shadowing, multipath fading, AWGN and one additional impairment. The chosen extra impairment is **co-channel interference**. Evaluate three receiver locations under two load conditions, yielding six cases. The shared config now fixes the initial 2.437 GHz, 2/8/20 m locations, 3.2 path-loss exponent, 4 dB shadowing deviation, 0/6/15 dB obstacle losses, four tap delays/powers, 6 dB receiver noise figure and −110/−80 dBm interference levels. Treat these as model assumptions until field evidence supports any calibration.

## Deliverables

1. `applyChannel.m` (or equivalent) that accepts Lokesh's complex waveform, one scenario and shared config.
2. `scenarios.m` or a CSV/table defining all six cases with values, units and rationale.
3. Link-budget/received-power/SINR table and plots.
4. Technical notes on equations, random processes, assumptions and any calibration against Soukaryo's measurements.
5. Your complete handwritten B pages. Arrange for **all four names and signatures on every handwritten page** before scanning.

## Implementation steps

1. **Agree on the input waveform and timing.** Obtain Lokesh's sample rate, frame duration, power normalization and pilot/preamble format. Preserve waveform length or document any delay so Abhinav can synchronize.
2. **Define locations.** Use `near`, `middle` and `edge`, linked to the same real-world labels Soukaryo measures. Record approximate distance and obstacles. If the measured Wi-Fi access point parameters are unknown, mark transmitter power and reference path loss as assumptions rather than pretending they were observed.
3. **Path loss and shadowing.** Implement the 1 m log-distance formula and values in `handoffs/DESIGN_FREEZE_AND_HANDOFFS.md`. Use dB arithmetic for the link budget and one seeded 4 dB-standard-deviation shadowing draw fixed per location for the full run; state and log the realized draw.
4. **Multipath fading.** Use a small tapped-delay impulse response (or a documented MATLAB channel object). State tap delays/powers and whether coefficients vary by frame. Ensure the selected CP is long enough for the delay spread or explicitly discuss ISI if it is not.
5. **AWGN and interference.** Use the fixed −174 dBm/Hz + 20 MHz + 6 dB noise model, and an **independent OFDM interferer** scaled to −110 dBm (`low`) or −80 dBm (`high`) received power. Add a documented 8-sample leading delay for synchronization testing. These two interference levels represent the traffic/load conditions, not two labels for identical waveforms.
6. **Field check.** Receive Soukaryo's raw RSSI CSV early. Use it to check or calibrate the *trend* in received power across the three positions. Preserve the original readings and document any fitted path-loss exponent/reference. If absolute calibration is impossible because access-point EIRP is unknown, compare relative changes and explain the limitation.
7. **Run all six cases.** Keep payload, bandwidth and other settings controlled when comparing cases. Use recorded random seeds and enough frames for BER/PER estimates. Save `rxWaveform`, scenario metadata and a separate `truth` object with actual channel/power values for debugging.
   Run 20 frames per scenario for an early smoke test, then 500 per scenario for final results. Retain the same seeds when comparing candidate power settings.
8. **Plot and check.** Show predicted/observed received power by location, SINR by location and load, and the link-budget table. Verify that increasing distance usually reduces received power and high interference generally reduces SINR. Because fading is random, compare averages or confidence intervals instead of demanding every single frame be monotonic.

## Handoff contract

Send Abhinav only the impaired waveform, public scenario/configuration information and pilot/preamble definitions needed for a real receiver. Keep true channel coefficients in a **separate diagnostic variable**; do not make the normal receiver equalizer read them. Send Soukaryo the six-scenario channel parameters and average received power/SINR results for analysis.

### Lokesh's transmitter is ready to call

After pulling the repository, make its root MATLAB's Current Folder. Then run:

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx                     % optional handoff sanity check
cfg = getConfig();
[txWaveform, txMeta] = transmitFrame(1,'QPSK',cfg);
mean(abs(txWaveform).^2)          % 0.0316228 W at the current 15 dBm setting
numel(txWaveform)                 % 960 samples for this QPSK/96-byte frame
```

`txWaveform` is a complex **column vector** sampled at `cfg.sampleRateHz` (currently 20 MHz). Its complete-frame sample-average `abs(x)^2` equals the configured transmit power in watts under a nominal 1-ohm baseband convention. `cfg.bandwidthHz` controls the sample rate and symbol timing. Each OFDM symbol is 80 samples (64 useful + 16 CP); the first two are known preamble, the third is a QPSK header, and the rest carry payload. The channel function should return a complex column vector. If filtering adds delay or a tail, retain/document it so Abhinav can test synchronization.

`txMeta` carries the frame duration, EIRP, original bits and protocol details. Keep it for offline metrics/debugging, but **do not pass `txMeta.payloadBits` or true channel coefficients into Abhinav's operational decoder**. Apply Tx antenna gain/feeder loss in the RF link budget only; `txWaveform` already has configured Tx *power*, so do not add the 2 dBi gain twice. For a receiver-power calculation, use `EIRP + Rx gain - path loss - other losses` in dB/dBm, then scale complex amplitude by the square root of the intended linear power ratio. Use your own independent random seed(s) for shadowing/fading/noise/interference and record them.

The precise frame format and runnable entry points are in `code/README.md` at the repository root. The full code/parameter rationale and known limitations are in `lokesh/LOKESH_VALUE_JUSTIFICATION_AND_PDF_AUDIT.md`. The `[12 23]` dB modulation thresholds are provisional until receiver PER results exist; they need not constrain your initial channel model.

## What to write by hand for B

Draw the propagation block; give the path-loss, shadowing, fading, AWGN and interference models with variables/units; show a three-location × two-load scenario table; include link-budget and power/SINR results; explain how the RSSI field data affects or validates the model; discuss model limits such as walls and unknown device/access-point parameters. Insert relevant plots/screenshots in the final scan. Ensure **all four names and signatures** appear on every handwritten page.

## Done when

The same seed recreates the same channel trial; every required impairment is present and documented; all six cases run; receiver input and diagnostic truth are separated; the link-budget and received-power/SINR plots match the numerical configuration.
