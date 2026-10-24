# Question 20 final assembly guide

## Decision about the field data

The assignment PDF asks for **at least one field-measurement input** and validation of **at least one simulated trend**. It does not specify ten readings per location. The latest authentic near/middle/far exports yield 7, 11 and 6 timestamped rows for one stable 2.4 GHz channel-7 BSSID, `d8:38:0d:1b:40:51`. Use `data/field_rssi.csv` and preserve the original paste in `data/raw/`. The earlier candidate BSSID `...40:c1` disappeared at far, so its older three-point dataset is not combined with this one. Repeated RSSI values may be scan-cache repeats; call the averages **means of exported rows**, not independent-sample estimates or calibrated measurements. Exclude `data/field_rssi_SYNTHETIC.csv` from both submissions and the experiment ZIP.

| Location | Export rows | Mean AP1 RSSI | Simulated desired power | Field change from near | Simulated change from near |
| --- | ---: | ---: | ---: | ---: | ---: |
| Near | 7 | -68.71 dBm | -34.40 dBm | 0 dB | 0 dB |
| Middle | 11 | -72.45 dBm | -62.74 dBm | -3.74 dB | -28.34 dB |
| Edge/far | 6 | -94.00 dBm | -73.16 dBm | -25.29 dB | -38.77 dB |

The field RSSI weakens toward far, but its middle drop is much smaller than the simulation predicts: differences are 24.60 dB at middle and 13.48 dB at far. These are descriptive differences, not calibrated model errors. The actual AP uses 2.442 GHz channel 7; the simulation uses 2.437 GHz channel 6. Actual physical distances, walls, AP power and phone model were not recorded. The exact calculated table is `results/receiver/power_study/field_trend_comparison.csv`; the source audit is `data/field_rssi_source_audit.md`. The 7:34/7:36/7:38 pm graph screenshots are from an earlier separate session, not from the new 20:15–20:20 exports.

## FISAC-2 handwritten PDF, due 25 October 2026 at 5:00 PM

1. Make the cover sheet with ICT 3128, subject name, assignment date 29-08-2026, section, group number, Question 20, all four full names and registration numbers. Add the four-member contribution table from `report/HANDWRITTEN_COPY_DRAFT.md`. Fill the actual identifiers by hand; they are not in the repository.
2. Each member handwrites their **entire** assigned part: Lokesh A, Prisha B, Abhinav C, Soukaryo D. Use `report/HANDWRITTEN_COPY_DRAFT.md` as the copy text. Draw the end-to-end architecture and decision flowcharts from `report/FLOWCHARTS_TO_DRAW.md` by hand. Keep the stated model assumptions separate from measured and simulated values.
3. Put **all four members' names and signatures on every handwritten page**, as the assignment PDF states. Number pages and leave room for captions/figures at the locations below.
4. Insert the actual figures and a legible excerpt of the new AP-list export table beside the relevant paragraphs. Print and paste them onto the handwritten pages before scanning, or insert them into the page scans with a PDF editor afterward. Keep the handwritten text readable. Caption every figure as shown below. The three earlier time-graph screenshots may illustrate the app interface but are not evidence for the new numeric rows.
5. Scan the pages in order into **one** readable PDF. Inspect every page at normal zoom for cut text, rotated pages, clipped charts, visible signatures and correct figure captions. Name the PDF `GroupNumber_Q20.pdf` (for example `G01_Q20.pdf`). Only the team lead uploads it.

### Recommended page order and figure locations

| Pages | Handwritten content | Figure to place beside the text |
| --- | --- | --- |
| 1 | Cover and contribution table | None |
| 2-3 | A: objective, end-to-end flowchart, frame/OFDM blocks, parameters, EIRP and rates | Figure 1 from `FLOWCHARTS_TO_DRAW.md`; A1 `lokesh/figures/tx_resource_mapping.png`; A2 `lokesh/figures/tx_spectrum.png` |
| 4-5 | B: path-loss/shadowing/fading/noise/interference equations and six-case table | B1 `results/received_power_comparison.png`; B2 `results/sinr_by_scenario.png`; optional B3 `results/tx_channel_waveform.png` |
| 6-7 | C: synchronization, estimation/equalization, CRC and six-case receiver table | C1 `results/receiver/adaptive_500/receiver_example.png`; C2 `receiver_performance.png`; C3 `receiver_sinr_validation.png` in the same folder |
| 8 | D: 24 AP1 export rows summarized by location, trend table, and limits | Excerpt of `data/field_rssi.csv` or original `data/raw/` text; D1 `results/receiver/power_study/field_trend_preliminary.png` |
| 9-10 | D: explicit targets, power study, Figure 2 decision flowchart and final conclusion | D2 `results/receiver/power_study/power_study_low_load_per.png`; Figure 2 from `FLOWCHARTS_TO_DRAW.md` |

Figures may move to the next page when handwriting needs more room. Put each close to the text that explains it. Caption D1 **"Mean AP1 RSSI from 7/11/6 exported rows, possibly cached; simulated trend aligned at near for visual comparison"** and D2 **"Simulated low-load PER, 500 frames per scenario"**. If including the earlier app screenshots, caption them **"Wi-Fi Analyzer time graphs from a separate 19:34–19:38 session; not the source of the 20:15–20:20 numeric table"**. Redact connection identifiers for a public copy if needed.

## FISAC-1 project PDF and ZIP, due 1 November 2026 at 5:00 PM

The project submission is **one PDF plus one experiment ZIP**, uploaded by the team lead. The project PDF can reuse the technical content and figures above, but should also present a clean methods/results structure: objective, system architecture, configuration/link budget, transmitter, six-case channel, receiver/evaluation, three-point field trend, 12-configuration power comparison, conclusion and limitations, and reproduction commands.

The ZIP should contain the runnable `code/` functions and `code/README.md`; `data/field_rssi.csv`, its original `data/raw/` export and audit; relevant `figures/field/` screenshots with their separate-session labeling; transmitter/channel/receiver/power-study plots and numeric result CSV/MAT files; and the final project PDF or an explicit pointer to it. Include `results/receiver/power_study/README.md` so another student can reproduce the sweep with `addpath(fullfile(pwd,'code')); runPowerStudy(500); plotPowerStudy` in MATLAB R2026b. Exclude the synthetic field CSV, the prior flawed `archive_before_timing_fix/` results, temporary `outputs/` files and local caches. Check the ZIP opens and its CSVs/figures are present before upload.

## Exact assembly workflow

1. Give each member the relevant A/B/C/D section of `HANDWRITTEN_COPY_DRAFT.md`. Each member copies all prose, equations and tables in their assigned part by hand. The bold **Attach** directions and this guide are production notes and are not part of the handwritten answer. Fill all personal details from college records; none were inferred from the Wi-Fi exports.
2. Draw Figure 1 on the first A page and Figure 2 in D using `FLOWCHARTS_TO_DRAW.md`. Handwrite the diagram boxes and captions. Put Figure 1 after the transmitter aim and Figure 2 before D's engineering decision.
3. Print the PNG plots from the exact paths in the page-order table. Print them large enough that axes and legends are readable; use a separate sheet if needed. On each page, leave a rectangle next to the paragraph that discusses the plot. Paste the printout there, write its A/B/C/D figure number and the caption, then number the page. For D's raw evidence, print the `data/field_rssi.csv` rows as a table with timestamp, location, channel, RSSI and the BSSID recorded in the notes column, or print a legible excerpt from the original export; include the complete raw file in the project ZIP. The earlier 19:34-19:38 time graphs must not replace the 20:15-20:20 AP1 evidence.
4. Have all four members write their full names and signatures on **each handwritten page**, including pages that hold pasted plots or a handwritten table. Scan the physical pages in page-number order using a phone document-scan app or a flatbed scanner. Use document mode, crop to the paper edge, keep pages upright, and export one multipage PDF. If plots are inserted digitally instead, first scan the signed handwritten pages, then place each PNG next to its cited paragraph in a PDF editor and export a fresh combined PDF. Inspect it at normal zoom and confirm every axis, caption and signature remains visible.
5. Name this handwritten PDF `GroupNumber_Q20.pdf`, using the actual group number. This is the **25 October FISAC-2** file. Do not combine it with the later experiment ZIP into one PDF.
6. For the **1 November FISAC-1** project report, use a word processor to make a separate typed PDF with: cover and contribution table; objective/targets; Figure 1 and configuration table; transmitter and Figure A1/A2; channel equations and Figure B1/B2; receiver and Figure C1-C3; authentic field method, 7/11/6-row table and Figure D1; 12-configuration low-load table and Figure D2; selected 20 dBm QPSK six-case table; engineering conclusion/limitations; reproduction commands; appendix listing source CSVs. Reuse the numerical wording in `HANDWRITTEN_COPY_DRAFT.md` but keep the typed report's headings and figure references consistent. Export the word-processor document as a PDF and inspect all pages.
7. Build the experiment ZIP after the typed PDF exists. Use `python report/build_experiment_zip.py --report path\to\final_project_report.pdf` from the repository root; this places a checked ZIP in `submission/`. The script excludes the synthetic field CSV and old flawed results. Confirm the PDF and ZIP filenames against the submission portal, and have the team lead upload the two due-date packages separately.

### Files still requiring a human action

- Actual section, group number, exact member names and registration numbers on the cover.
- Physical handwriting of each member's assigned complete section, handwritten diagrams, and all four signatures on each page.
- Scanning and visual inspection of the signed handwritten PDF.
- Exporting the separate typed project PDF, then running the ZIP builder with that PDF path.

## Engineering conclusion to copy

"The same 2.4 GHz AP was observed in 7 near, 11 middle and 6 far export rows. Their descriptive RSSI means were -68.71, -72.45 and -94.00 dBm. The 3.74 and 25.29 dB near-relative drops have the same broad direction as the simulated 28.34 and 38.77 dB drops, but the middle loss differs substantially. Repeated values may be cached and the physical geometry is unknown, so this does not calibrate the propagation model. MATLAB checks passed, and a matched-seed study of 10, 15 and 20 dBm with four modulation rules evaluated 500 frames per scenario. No tested rule met the 5% PER and 5 Mbps goodput targets at all three low-load locations. The best tested fallback is 20 dBm fixed QPSK: near, middle and edge PER were 0%, 3.4% and 33%, with goodput 16.000, 15.456 and 10.720 Mbps. It meets 2/3 locations, so the 3/3 coverage target is not achieved. High-load interference remains severe, and the edge location remains unreliable at low load. Forward-error-correction coding with interleaving is the next specific change to test; its benefit has not yet been demonstrated."
