# ICT 3128 Question 20 group project

Start with the [group plan](handoffs/00_GROUP_PLAN.md) and [frozen technical decisions](handoffs/DESIGN_FREEZE_AND_HANDOFFS.md). The individual handoffs are [Lokesh](handoffs/01_LOKESH_TRANSMITTER.md), [Prisha](handoffs/02_PRISHA_CHANNEL.md), [Abhinav](handoffs/03_ABHINAV_RECEIVER.md) and [Soukaryo](handoffs/04_SOUKARYO_ANALYSIS.md). A [group-chat message](handoffs/SEND_TO_GROUP.md) is ready to share.

**Current implementation status:** The transmitter, channel and receiver pass local MATLAB R2026b checks and full six-case evaluations. At the assumed 15 dBm baseline, only **1/3** low-load locations meets the group's PER/goodput targets. Soukaryo's real field RSSI evidence and the 10/15/20 dBm engineering comparison are still required. See the [dated status and test record](CURRENT_STATUS.md), [copy-ready A/B/C/D handwritten draft](report/HANDWRITTEN_COPY_DRAFT.md), [receiver outputs](results/receiver/README.md) and [run instructions](code/README.md). Do not describe simulated results as field measurements or claim the current configuration meets the full target.

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
