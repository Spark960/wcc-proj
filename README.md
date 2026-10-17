# ICT 3128 Question 20 group project

Start with [the group plan](00_GROUP_PLAN.md), then [the frozen technical handoffs](DESIGN_FREEZE_AND_HANDOFFS.md). Individual responsibilities are in `01_LOKESH_TRANSMITTER.md`, `02_PRISHA_CHANNEL.md`, `03_ABHINAV_RECEIVER.md` and `04_SOUKARYO_ANALYSIS.md`.

**Current implementation status:** Lokesh's transmitter is implemented and clean-loopback tested in MATLAB. Prisha's channel, Abhinav's receiver and Soukaryo's real field measurements/analysis are not yet in this repository. Do not present the baseline assumptions or generated transmitter figures as complete end-to-end results.

## Run the existing transmitter from the repository root

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx
runLokeshTx
cfg = getConfig();
[txWaveform,txMeta] = transmitFrame(1,'QPSK',cfg);
```

The code uses built-in MATLAB functions only in the current transmitter. MATLAB R2026b was used for validation. `code/README.md` describes the frame, output units and interface. `LOKESH_VALUE_JUSTIFICATION_AND_PDF_AUDIT.md` explains design values and exact assignment coverage. `LOKESH_A_WRITEUP_DRAFT.md` is source text for Lokesh's handwritten section.

## Required original inputs and final outputs

- Original Wi-Fi RSSI readings and screenshots must come from real permitted measurements. `data/field_rssi_TEMPLATE.csv` is an empty template, not evidence.
- Save scenario definitions, MATLAB functions, final six-case results, plots and a reproducible run command with the final project ZIP.
- The 25 October handwritten assignment is a separate one-PDF submission. The 1 November project submission is one PDF plus one ZIP. The team lead uploads both.
