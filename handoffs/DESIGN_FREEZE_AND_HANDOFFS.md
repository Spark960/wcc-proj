# Question 20 design freeze and executable handoffs

**Decided by Lokesh for the group on 17 October 2026.** Use this file as the shared specification for A/B/C/D. Paths here are relative to the repository root. Each member still owns and writes their complete assigned sub-question. The two assignment PDFs in the repository are authoritative for grading and submission. These settings are a reproducible engineering **baseline**, not claims that the measured access point has these characteristics. Preserve raw field data and label assumptions in every plot/table.

## 1. System and protocol — fixed now

- **System:** one 1×1, WLAN-inspired OFDM link. MIMO is optional and omitted. Extra channel impairment is **co-channel interference**, not Doppler. Evaluate three receiver locations × two load conditions.
- **Carrier and channel:** nominal 2.437 GHz (2.4 GHz channel-6 baseline), 20 MHz sampled/channel bandwidth. Soukaryo should measure one permitted 2.4 GHz Wi-Fi access point, preferably channel 6; if the available AP is on another 2.4 GHz channel, record it and update only `cfg.centerFrequencyHz` before the final run. The simulation is not a standards-compliant Wi-Fi packet.
- **OFDM:** 64-point FFT, 16-sample CP, 48 data bins, 4 fixed pilots, 12 null bins including DC. The exact indices/pilot values are in `code/getConfig.m`; use them everywhere.
- **Frame:** two known repeated preamble OFDM symbols, one QPSK control-header symbol, then payload symbols. The header conveys marker, frame ID, modulation and payload length with CRC-8. Each 96-byte seeded payload has CRC-16/CCITT-FALSE. The transmitter handles padding.
- **Modulation:** QPSK, 16-QAM, 64-QAM. First frame QPSK. Thereafter choose the **next** frame's mode from the receiver's previous-frame estimated SINR. The current 12/23 dB cutoffs are provisional: tune them from receiver performance before the final adaptive run. Never choose the mode from true channel state or a future decode outcome.
- **Transmit settings:** 15 dBm sample-average Tx power, 2 dBi Tx antenna gain, 0 dB feeder loss, 0 dBi Rx reference gain. EIRP = 17 dBm. These are model assumptions; they are not the field AP's measured specifications.
- **Code of record:** `code/getConfig.m`, `code/transmitFrame.m` and `code/README.md`. Change a shared value in config only, then rerun all results. Use MATLAB R2026b or a compatible release.

MathWorks' [non-HT OFDM information](https://www.mathworks.com/help/wlan/ref/wlannonhtofdminfo.html) supports the 20 MHz / 64 FFT / 16 CP / 48 data / 4 pilot geometry. This is a practical reference geometry; our preamble, header and lack of forward error correction make the resulting waveform custom.

## 2. Exactly six scenarios

| Location | Target measurement point | Baseline distance | Additional obstacle loss | Low load | High load |
| --- | --- | ---: | ---: | ---: | ---: |
| `near` | same room / clear path | 2 m | 0 dB | −110 dBm interferer | −80 dBm interferer |
| `middle` | corridor / one obstruction | 8 m | 6 dB | −110 dBm interferer | −80 dBm interferer |
| `edge` | far point / more obstructions | 20 m | 15 dB | −110 dBm interferer | −80 dBm interferer |

The distances and obstacle losses are **scenario assumptions**. Soukaryo should choose the closest practical physical positions and record actual estimates/obstacles; do not invent a 20 m measurement if the available site is shorter. The final report must distinguish physical measurement positions from simulated scenario coordinates. If the physical layout differs substantially, Lokesh updates config once and all members rerun with the revised values.

### Channel formula and random behavior for Prisha

Use a 1 m reference log-distance model:

```text
PL0(dB) = 20 log10(4π × 1 m × fc / c)
PL_i(dB) = PL0 + 10 × 3.2 × log10(d_i / 1 m) + wallLoss_i + shadow_i
shadow_i ~ N(0, 4² dB²), one fixed draw per location per full run
Pdesired_i(dBm) = EIRP + 0 dBi Rx gain − PL_i
Pnoise(dBm) = −174 dBm/Hz + 10 log10(20 MHz) + 6 dB NF ≈ −95 dBm
```

These 3.2/4 dB/6 dB/obstacle values are explicit *starting assumptions*, chosen to produce distinguishable indoor coverage conditions. The MathWorks [WLAN TGn channel documentation](https://www.mathworks.com/help/wlan/ref/wlantgnchannel-system-object.html) gives indoor examples with distance-dependent exponents and shadowing deviations; it does not validate our exact room. The [RF noise reference](https://www.mathworks.com/help/simrf/ug/noise-in-rf-systems.html) gives the room-temperature −174 dBm/Hz baseline. Soukaryo's measurements should check the near-to-edge RSSI trend; they can support updating model assumptions only if the change and measurement uncertainty are documented.

Use four **integer-spaced multipath taps** at sample delays `[0 2 5 9]`, average relative tap powers `[0 −3 −6 −9]` dB, normalized to unit average channel power. Draw independent complex Gaussian tap coefficients per frame and hold them constant for the short frame. The maximum 9-sample delay is below the 16-sample CP. Do not put an independent log-distance gain inside the fading taps: apply large-scale power **once**, then unit-average fading. Draw one 4 dB shadowing value per location for the run using `cfg.channelSeed`, keep it fixed for the 500 frames there, and document it in the result table. That separates location loss from frame-to-frame fading.

Add complex AWGN with total mean power −95 dBm under the same 1-ohm complex-baseband convention as `txWaveform`. Add an **independent OFDM interferer waveform** scaled to −110 dBm (`low`) or −80 dBm (`high`) at the receiver; give it an independent payload/seed and a small asynchronous offset so it is genuinely co-channel traffic. Do not replace the interferer with a second AWGN term and call it traffic. Use `cfg.channelSeed` plus documented offsets for reproducible streams. The fixed interference powers are stress-test assumptions, not field measurements.

The channel input is a complex column vector from Lokesh. Output a complex column vector, public scenario label, and a **separate** `truth` structure with actual channel taps/powers/SINR for offline verification. Add a documented fixed 8-sample leading delay to the channel output so Abhinav must detect timing. Do not give `truth` or original payload bits to his decoder. Tx antenna gain is counted in `EIRP`; do not add it twice. Convert a desired dB *power* gain/loss to a complex *amplitude* scale with `10^(gainDb/20)`.

MathWorks explains pilot-based channel estimation and why the CP must cover the delay spread in its [OFDM resource-grid guide](https://www.mathworks.com/help/comm/ug/ofdm-channel-estimation.html).

## 3. Receiver contract and evaluation rule for Abhinav

Use this function boundary (names can vary, fields cannot):

```matlab
decoded = receiveFrame(rxWaveform,cfg)
```

`decoded` must report timing/header success, decoded frame ID/mode/length, recovered payload bits, CRC pass/fail, estimated received power and effective SINR. It receives no original payload, `txMeta` truth or true channel taps. Detect the preamble by correlation over the received stream (the channel adds an 8-sample prefix). Remove CP/FFT; estimate frequency response from the known preamble; use pilots to correct or track the estimate across data symbols; equalize; demap the QPSK header and then the signaled payload mode; validate header CRC and payload CRC. If timing/header fails, count a packet error rather than inventing decoded bits.

For a first receiver smoke test, use the clean transmitter waveform with an 8-sample prefix, then add AWGN only, then use Prisha's complete channel. This work can start **now**, in parallel with Prisha. `code/txIdealLoopback.m` is only a transmitter sanity check and **does not** satisfy receiver requirements because it knows the frame boundary and assumes flat gain.

Collect these per-scenario metrics over `cfg.smokeFramesPerScenario = 20` first and `cfg.finalFramesPerScenario = 500` in the final run:

- **PER:** frames with failed synchronization/header/payload CRC divided by attempted frames. Report numerator and denominator.
- **BER:** wrong recovered payload bits divided by payload bits compared on frames with an identifiable decoded length. Exclude unaligned sync/header failures from BER but include them in PER, and report the excluded count.
- **Goodput:** successfully recovered payload bits divided by total simulated transmitted frame airtime. This assumes no MAC contention or retransmission.
- **Latency proxy:** `frame airtime / (1 − PER)` for PER < 1, interpreted as expected repeated-transmission airtime under an idealized independent retry model; infinity if PER = 1. Label it a proxy, not measured network latency.
- **Received power/SINR:** show the receiver estimate; compare it with Prisha's separate truth only during validation. State the estimator. A practical effective-SINR estimate can use the difference of the two known repeated preamble symbols to estimate disturbance power and their average to estimate channel-weighted signal power. It is imperfect under correlated interference, so explain any bias.

The final 500-frame run should include 95% PER intervals where useful; MathWorks documents [Monte Carlo error-rate confidence intervals](https://www.mathworks.com/help/comm/ref/berconfint.html). A zero-failure result over 500 frames has a rough upper 95% PER bound of `3/500 ≈ 0.6%`; show this as an upper bound, not as proof of PER = 0. Repeat exact scenario seeds when comparing candidate configurations.

## 4. Field protocol and final choice for Soukaryo

Measure **one permitted 2.4 GHz Wi-Fi access point** with a listed app such as WiFi Analyzer. Use the same phone and AP at `near`, `middle`, `edge`, matching the scenario order. At each location, take **10 RSSI readings** in dBm over about one minute, with phone orientation held approximately constant; record date/time, approximate distance, obstacles, app, phone model, band/channel and an AP label. Save raw rows in `data/field_rssi.csv` and original app screenshots in `figures/field/`. If screenshots reveal personal network identifiers, crop/redact those while keeping the reading and app visible. Analyze only permitted measurements and the group's own traffic. Give Prisha the raw table early.

Compare *relative* mean RSSI change from near to middle/edge against the simulated received-power change. Align the curves at near only if explicitly labeled as a visual reference; do not call that an absolute calibrated match. Report mean/spread and explain differences from obstacles, unknown AP EIRP, phone reporting and time variation. A measured channel not equal to 20 MHz or 2.437 GHz must be recorded, then explain the model-to-field mismatch or rerun with adjusted `cfg`.

**Predeclared low-load targets:** at each of the three locations, PER ≤ **5%**, goodput ≥ **5 Mbps**, and a successfully delivered payload in at least **95%** of frames. Coverage = **3/3 locations** meeting those limits. High-load cases are a required interference stress test and must be reported honestly; do not hide failures or move the targets after seeing results. These thresholds are group engineering requirements, **not** assignment-given values. The 95% delivery criterion is numerically equivalent to PER ≤5%, but is presented as the location coverage definition. Report both metrics and counts.

Run the **same** scenario seeds for candidate Tx powers `[10 15 20]` dBm and the three fixed modulations; use the measured/estimated SINR and PER curves to choose defensible adaptive thresholds. The final decision rule is:

1. Among tested configurations meeting all low-load targets, choose the **lowest Tx power**.
2. At that power, choose the modulation rule maximizing the **minimum goodput across the three locations**, while retaining the PER limit.
3. Report all high-load results and the dominant impairment based on matched comparisons (high versus low at the same location isolates interference; edge versus near at the same load exposes coverage).
4. If none meets the targets, state the failure and choose the best tested configuration by lowest worst-location PER, then highest worst-location goodput. Recommend a **specific** further engineering change and mark it unverified unless simulated.

The selected configuration may differ from the 15 dBm baseline. No one should claim it is optimal in an absolute sense; it is the best **among the explicitly tested candidates under the stated model and targets**.

## 5. Handoff sequence, files and done gates

| Owner | Start now | Handoff to next person | Done gate |
| --- | --- | --- | --- |
| Lokesh (A) | Push `code/`, figures, docs | `cfg`, `txWaveform`, header/preamble specification and original-bit truth kept offline | Existing MATLAB checks pass; integrate final project |
| Prisha (B) | Build six-scenario channel from this spec | `rxWaveform` + public scenario to Abhinav; separate `truth` and RF table to Lokesh/Soukaryo | All five impairment types present, power/SINR trend and seeds documented |
| Abhinav (C) | Build clean/noisy receiver now | Six-case decode table, plots and SINR feedback to Lokesh/Soukaryo | No true channel/payload leakage; clean test passes; 500-frame final run |
| Soukaryo (D) | Measure RSSI now | Raw data to Prisha; comparison, target table and selected config to all | Real evidence, deviations explained, numerical decision |

**17 Oct:** share the repository and start B/C/measurements. **20 Oct:** B/C working smoke run plus raw RSSI. **22 Oct:** integrated 500-frame results and A/B/C/D handwritten drafts. **24 Oct:** final write-up scan/check. **25 Oct 5:00 PM:** FISAC-2 handwritten PDF. **1 Nov 5:00 PM:** FISAC-1 project PDF plus experiment ZIP. The write-up PDF's literal wording says each student signs **every page**; arrange all four names/signatures on every handwritten page before scanning.

## 6. Reproduction and communication rules

1. Start MATLAB in the cloned repo root and run `addpath(fullfile(pwd,'code')); checkLokeshTx` to verify A. Avoid absolute paths tied to Lokesh's computer.
2. Keep `getConfig.m` as the single source of chosen numerical values. If changed, record what changed and rerun all results/figures. Do not silently modify a copied local config.
3. Save `code/`, original `data/`, `figures/`, result tables and a root run README in the final ZIP. Never replace raw field rows with smoothed or simulated values.
4. Use the same scenario labels and units in code, figures and handwritten sections. Distinguish: **measured**, **assumed**, **simulated**, and **calculated** values.
5. Each member checks and writes their assigned entire sub-question. Lokesh checks consistency, the contribution table, all signatures and both submission formats.
