# ICT 3128 Question 20 group project

Start with the [group plan](handoffs/00_GROUP_PLAN.md) and [frozen technical decisions](handoffs/DESIGN_FREEZE_AND_HANDOFFS.md). The individual handoffs are [Lokesh](handoffs/01_LOKESH_TRANSMITTER.md), [Prisha](handoffs/02_PRISHA_CHANNEL.md), [Abhinav](handoffs/03_ABHINAV_RECEIVER.md) and [Soukaryo](handoffs/04_SOUKARYO_ANALYSIS.md). A [group-chat message](handoffs/SEND_TO_GROUP.md) is ready to share.

**Current implementation status:** The transmitter, channel and receiver pass local MATLAB R2026b checks and full six-case evaluations. The matched 10/15/20 dBm study is complete. No tested configuration meets all three low-load targets; 20 dBm fixed QPSK is the best tested fallback at 2/3 locations. The latest field input has 24 real AP1 export rows across near/middle/far (7/11/6), with repeated values that may be cached. Its broad near-to-far trend can be compared descriptively with the simulation. See the [dated status and test record](CURRENT_STATUS.md), [copy-ready A/B/C/D handwritten draft](report/HANDWRITTEN_COPY_DRAFT.md), [assembly guide](report/FINAL_ASSEMBLY_GUIDE.md), [receiver outputs](results/receiver/README.md) and [run instructions](code/README.md). Do not describe simulated results as field measurements or claim the configuration meets the full target.

For the phone survey and a clean handoff to a new chat, use the [field measurement instructions](handoffs/05_FIELD_MEASUREMENT_AND_NEXT_CHAT.md).

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

- The 24 original Wi-Fi AP1 export rows are in `data/field_rssi.csv`, with the full pasted text in `data/raw/` and an audit in `data/field_rssi_source_audit.md`. The older time-graph screenshots in `figures/field/` are from another session. `data/field_rssi_TEMPLATE.csv` is only a template, and `data/field_rssi_SYNTHETIC.csv` is an unused test fixture excluded from submissions.
- Save scenario definitions, MATLAB functions, final six-case results, plots and a reproducible run command with the final project ZIP.
- The 25 October 2026 handwritten assignment is a separate one-PDF submission. The 1 November 2026 project submission is one PDF plus one ZIP. The team lead uploads both.
