# ICT 3128 Question 20 group project

Start with the [group plan](handoffs/00_GROUP_PLAN.md) and [frozen technical decisions](handoffs/DESIGN_FREEZE_AND_HANDOFFS.md). The individual handoffs are [Lokesh](handoffs/01_LOKESH_TRANSMITTER.md), [Prisha](handoffs/02_PRISHA_CHANNEL.md), [Abhinav](handoffs/03_ABHINAV_RECEIVER.md) and [Soukaryo](handoffs/04_SOUKARYO_ANALYSIS.md). A [group-chat message](handoffs/SEND_TO_GROUP.md) is ready to share.

**Current implementation status:** Lokesh's transmitter is implemented and clean-loopback tested in MATLAB. Prisha's channel, Abhinav's receiver and Soukaryo's real field measurements/analysis are not yet in this repository. Do not present the baseline assumptions or generated transmitter figures as complete end-to-end results.

## Run the existing transmitter from the repository root

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx
runLokeshTx
cfg = getConfig();
[txWaveform,txMeta] = transmitFrame(1,'QPSK',cfg);
```

The current transmitter uses built-in MATLAB functions and was checked in MATLAB R2026b. [The code README](code/README.md) describes its frame, units and interface. Lokesh's [handwritten-section draft](lokesh/LOKESH_A_WRITEUP_DRAFT.md), [value justifications and PDF audit](lokesh/LOKESH_VALUE_JUSTIFICATION_AND_PDF_AUDIT.md), and transmitter figures are kept in `lokesh/`.

## Required original inputs and final outputs

- Original Wi-Fi RSSI readings and screenshots must come from real permitted measurements. `data/field_rssi_TEMPLATE.csv` is an empty template, not evidence.
- Save scenario definitions, MATLAB functions, final six-case results, plots and a reproducible run command with the final project ZIP.
- The 25 October 2026 handwritten assignment is a separate one-PDF submission. The 1 November 2026 project submission is one PDF plus one ZIP. The team lead uploads both.
