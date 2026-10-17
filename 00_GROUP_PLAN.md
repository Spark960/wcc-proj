# ICT 3128 Question 20 — group plan

Share this file and the four named instruction files with the group. The source assignment sheets are `ICT3128_Group-Assignment_Project_Questions.pdf` and `ICT3128_Group-Assignment-Writeup_Project_Questions.pdf` in this folder. The assignment sheets take priority if any interpretation here is disputed.

## Ownership

| Member | Complete sub-question | Responsibility |
| --- | --- | --- |
| Lokesh | A | Transmitter, shared configuration, integration, team lead and submission |
| Prisha | B | Channel and propagation model, six scenarios |
| Abhinav | C | Receiver, decoding and performance metrics |
| Soukaryo | D | Field measurements, validation, analysis and engineering decision |

Each member writes their **entire assigned sub-question** by hand. Every handwritten page must have that student's name and signature. Lokesh checks all sections, adds the assignment details and contribution table, scans/combines the pages, and submits.

## Project objective and scope

Build one reproducible MATLAB end-to-end link: **framed OFDM transmitter → path-loss/shadowing/fading/noise/interference channel → synchronized and equalized receiver → quantitative results and engineering decision**. Use a single transmit/receive antenna. The 2×2 MIMO option is deliberately omitted because it is optional; do not describe MIMO as implemented. Use actual permitted Wi-Fi RSSI measurements from a listed mobile app to validate or calibrate one coverage trend. Never invent field data.

### Proposed baseline (freeze together before coding)

| Parameter | Baseline | Note |
| --- | --- | --- |
| FFT / cyclic prefix | 64 / 16 samples | Match channel delay spread to CP |
| Active subcarriers | 48 data + 4 pilots | Agree on exact indices and guard/DC bins |
| Modulations | QPSK, 16-QAM, 64-QAM | Adaptive selection; document thresholds |
| Payload | Fixed known byte sequence or seeded pseudo-random bits | Save seed and payload length |
| Error check | CRC-16 | Save polynomial, init, bit order |
| Frames | At least 100 per scenario for first run | Report actual count; increase only if needed to resolve uncertainty |
| Locations | Near, middle, edge | Record measured labels/distances/obstructions |
| Load conditions | Low and high co-channel interference | Six total scenario combinations |
| Antennas | 1×1 | MIMO is optional |
| Bandwidth | Configurable; propose 20 MHz | Set sample rate and symbol time consistently |

These are **group design choices**, not values given by the assignment. If a toolbox or model constraint requires changing them, update this table, code and all four write-ups together.

## Interface contract — agree before implementation

Create `config.m` (or a structure returned by `getConfig.m`) as the only source of numerical settings. Use consistent units: Hz, seconds, metres, watts internally and dBm/dB for reported RF levels. Set and record RNG seeds. Keep the original payload bits and a frame ID for comparison.

1. **Lokesh → Prisha:** `txWaveform` complex column vector, `txMeta` containing preamble, frame start, modulation, payload bits, CRC method, data/pilot indices, OFDM symbol count and timing, plus `cfg`.
2. **Prisha → Abhinav:** `rxWaveform` complex column vector, public scenario settings (location/load) and `cfg`. Keep any true channel response separately as `truth` for debugging and validation; the normal receiver must estimate its channel rather than read `truth`.
3. **Abhinav → Soukaryo:** One result row per scenario: distance/location, load, selected modulation, received power dBm, SINR dB, bit errors, tested bits, bad packets, tested packets, BER, PER, delivered payload bits, elapsed time, goodput bps and outage/latency proxy.
4. **Soukaryo → all:** Original measurement CSV/screenshots, measurement method, comparison plot, target table and final recommended configuration.

Adaptive modulation must have a causal rule. Proposed approach: use estimated SINR from a previous pilot/preamble or previous frame, then choose the next frame's modulation. Record thresholds and include a robust first-frame/default mode. Do not choose the modulation using the true simulated channel or the current frame's decoded outcome.

## Evidence and validation checklist

- End-to-end architecture and frame diagram.
- Parameter and link-budget tables with units and assumptions.
- Transmitter spectrum and resource map; receiver constellation/estimation evidence.
- Six-scenario results, with BER, PER, goodput, received power/SINR and an explicitly defined outage or latency proxy.
- Field app name, device, time, location labels, original RSSI readings and screenshots; compare at least one simulated trend and explain deviations.
- Final engineering configuration justified against explicit reliability, throughput and coverage targets.
- Reproducible run instructions; all `.m` files, inputs and generated figures in one ZIP for the project submission.

Do not treat one clean frame as statistical evidence of PER. Use a clean high-SNR frame as a functional test, then repeated frames for reported metrics. If results contradict basic expectations, diagnose the model or implementation before writing conclusions.

## Dates and submission

| Date (2026) | Handoff |
| --- | --- |
| 17 Oct | Freeze interface contract, baseline parameters and location labels; Soukaryo starts field data |
| 20 Oct | Working A/B/C modules, initial six-case run and original field data |
| 22 Oct | Integrated results, tables, figures and handwritten A/B/C/D drafts |
| 24 Oct | Check calculations and pages; scan and assemble handwritten write-up |
| **25 Oct, by 5:00 PM** | Lokesh submits **one handwritten write-up PDF** |
| 26–30 Oct | Final project code, reproducibility check, report PDF and experiment ZIP |
| **1 Nov, by 5:00 PM** | Lokesh submits **one project PDF and one ZIP** |

Both assignment sheets specify a PDF name in the form `GroupNumber_QuestionNumber`, e.g. `G01_Q20.pdf`. Keep the two deliverables clearly separated because they have different deadlines and submission rules. The write-up PDF is handwritten; the later project submission includes a PDF and a ZIP of all experiment files.

## Report front matter and contribution table

Put subject code **ICT 3128**, subject name **Wireless Communication and Computing**, assignment date, section, group number, all four names and registration numbers on the assignment sheet. Use a contribution table with the four rows above, then fill in exact names/registration numbers from the group. Do not guess missing details.

## Suggested folder layout

```text
Gxx_Q20/
  code/           config, transmitter, channel, receiver, run script
  data/           original RSSI CSV and scenario definitions
  figures/        generated plots and original field screenshots
  results/        six-scenario results table and logs
  report/         diagrams, tables and scanned handwritten pages
  README.md       MATLAB version, toolbox use and exact run command
```

## Decisions that must be documented

Record exact OFDM carrier indices, pilot values, preamble, CRC settings, path-loss formula/reference power, shadowing variance, multipath taps, noise formula, interference level, frame count, adaptation thresholds, metric definitions and the field measurement method. Any assumption without a measured or assignment-given value should be marked as a design assumption.
