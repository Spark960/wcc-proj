# Prisha — Question 20B: channel and propagation

Read `00_GROUP_PLAN.md` first. You own the **entire B sub-question**: path loss, shadowing, multipath fading, AWGN and one additional impairment. The chosen extra impairment is **co-channel interference**. Evaluate three receiver locations under two load conditions, yielding six cases.

## Deliverables

1. `applyChannel.m` (or equivalent) that accepts Lokesh's complex waveform, one scenario and shared config.
2. `scenarios.m` or a CSV/table defining all six cases with values, units and rationale.
3. Link-budget/received-power/SINR table and plots.
4. Technical notes on equations, random processes, assumptions and any calibration against Soukaryo's measurements.
5. Your complete handwritten B pages, with **Prisha and your signature on every page**.

## Implementation steps

1. **Agree on the input waveform and timing.** Obtain Lokesh's sample rate, frame duration, power normalization and pilot/preamble format. Preserve waveform length or document any delay so Abhinav can synchronize.
2. **Define locations.** Use `near`, `middle` and `edge`, linked to the same real-world labels Soukaryo measures. Record approximate distance and obstacles. If the measured Wi-Fi access point parameters are unknown, mark transmitter power and reference path loss as assumptions rather than pretending they were observed.
3. **Path loss and shadowing.** Choose a stated distance-dependent loss formula (for example a log-distance model with reference distance and exponent). Use dB arithmetic for the link budget and a seeded zero-mean shadowing term with stated standard deviation. Explain whether shadowing is fixed per location, varied per frame or both.
4. **Multipath fading.** Use a small tapped-delay impulse response (or a documented MATLAB channel object). State tap delays/powers and whether coefficients vary by frame. Ensure the selected CP is long enough for the delay spread or explicitly discuss ISI if it is not.
5. **AWGN and interference.** Calculate noise from a documented noise density/noise figure/bandwidth or state a controlled SNR model. Add a separately generated complex interfering signal or interference-power term, consistently scaled for `low` and `high` load. Explain exactly what load means; it must change the channel condition and/or resulting performance, not merely relabel a plot.
6. **Field check.** Receive Soukaryo's raw RSSI CSV early. Use it to check or calibrate the *trend* in received power across the three positions. Preserve the original readings and document any fitted path-loss exponent/reference. If absolute calibration is impossible because access-point EIRP is unknown, compare relative changes and explain the limitation.
7. **Run all six cases.** Keep payload, bandwidth and other settings controlled when comparing cases. Use recorded random seeds and enough frames for BER/PER estimates. Save `rxWaveform`, scenario metadata and a separate `truth` object with actual channel/power values for debugging.
8. **Plot and check.** Show predicted/observed received power by location, SINR by location and load, and the link-budget table. Verify that increasing distance usually reduces received power and high interference generally reduces SINR. Because fading is random, compare averages or confidence intervals instead of demanding every single frame be monotonic.

## Handoff contract

Send Abhinav only the impaired waveform, public scenario/configuration information and pilot/preamble definitions needed for a real receiver. Keep true channel coefficients in a **separate diagnostic variable**; do not make the normal receiver equalizer read them. Send Soukaryo the six-scenario channel parameters and average received power/SINR results for analysis.

## What to write by hand for B

Draw the propagation block; give the path-loss, shadowing, fading, AWGN and interference models with variables/units; show a three-location × two-load scenario table; include link-budget and power/SINR results; explain how the RSSI field data affects or validates the model; discuss model limits such as walls and unknown device/access-point parameters. Insert relevant plots/screenshots in the final scan. Write your name and signature on **every** page you handwrite.

## Done when

The same seed recreates the same channel trial; every required impairment is present and documented; all six cases run; receiver input and diagnostic truth are separated; the link-budget and received-power/SINR plots match the numerical configuration.
