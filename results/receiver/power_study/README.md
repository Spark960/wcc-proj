# Matched-seed power study (24 October 2026)

Run from the repository root in MATLAB R2026b:

```matlab
addpath(fullfile(pwd,'code'))
runPowerStudy(500)
plotPowerStudy
```

`runPowerStudy` first runs the transmitter, channel-integration and receiver checks. All three passed in the local run. It then evaluates 10, 15 and 20 dBm with fixed QPSK, 16-QAM, 64-QAM and the previous-frame adaptive rule. The rule uses the baseline-calibrated 40/44 dB thresholds. All candidates use the same payload/channel seeds, six simulated scenarios and 500 frames per scenario. This produced 36,000 frame attempts and `power_study_500.csv` with 72 scenario rows. The six 15 dBm adaptive failure counts and goodput values exactly matched the previous baseline.

`power_study_low_load_per.png` summarizes the simulated low-load PER. `field_trend_comparison.csv` and `field_trend_preliminary.png` are generated directly from the 24 **observed AP-list export rows** in `data/field_rssi.csv` (7 near, 11 middle, 6 far) and the simulated channel CSV. The values plotted are descriptive means of export rows; repeated RSSI may be cached. The simulated curve is shifted to share the near value for visual comparison, not calibration. Synthetic RSSI values are excluded from this figure and all MATLAB tests. The assignment does not prescribe a minimum field sample count.

The 2.437 GHz channel-6 simulation baseline was retained for comparability. The observed AP used 2.442 GHz channel 7, and its actual transmit power, field distances and obstacles are unknown. The field data therefore cannot calibrate the channel model yet. The earlier 19:34–19:38 time-graph screenshots are a separate session from the 20:15–20:20 exports.

No candidate met 3/3 low-load coverage. The selected fallback is 20 dBm fixed QPSK: near/middle/edge PER 0.0%, 3.4%, 33.0%; goodput 16.000, 15.456, 10.720 Mbps. Adaptive at 20 dBm ties on worst PER and worst goodput but misses the middle 5% PER target (5.4%). High-load 20 dBm QPSK PER is 0.2%, 56.8%, 95.4% at near/middle/edge. This is a simulated result, not a real Wi-Fi throughput test.
