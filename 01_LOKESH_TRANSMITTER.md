# Lokesh — Question 20A: transmitter and team lead

Read `00_GROUP_PLAN.md` and `DESIGN_FREEZE_AND_HANDOFFS.md` first. You own the **entire A sub-question**, the shared numerical configuration and final integration. The assignment explicitly requires a complete transmitter with framed traffic, OFDM and adaptive QPSK/16-QAM/64-QAM (or justified equivalent), configurable power/gain/bandwidth, a field-measurement input, Tx plots and throughput/EIRP calculations.

## Deliverables

1. `config.m` or `getConfig.m`: all system settings with units and RNG seed(s).
2. `makeFrame.m` and `transmitFrame.m` (names may vary): payload/framing/CRC and OFDM waveform generation.
3. A documented adaptive modulation selection function or call site.
4. Spectrum, resource-map and frame-format figures; transmitter parameter/EIRP/nominal-throughput table.
5. Your complete handwritten A pages. Arrange for **all four names and signatures on every handwritten page** before scanning.
6. Main run script, README, merged report and final submissions as team lead.

## Implementation steps

1. **Freeze interfaces with Prisha and Abhinav.** Decide the exact 64 FFT-bin indices, DC/guard bins, four pilot bins, pilot symbols, 16-sample CP, preamble length, symbol order and frame metadata structure. Write these in the config comments and a small frame diagram. Do this before separate coding.
2. **Make payloads reproducible.** Choose a fixed payload byte string or seeded pseudo-random bits. Keep each frame's original payload bits and frame ID. If registration-number-derived bits are chosen, document the exact character encoding, bit order and framing; otherwise a seeded payload is sufficient for this question.
3. **Add CRC and framing.** Select a CRC-16 polynomial, initialization, input/reflection convention and output order. Construct preamble + data-bearing OFDM symbols. Include any header needed by the receiver to know frame length and modulation; keep the header robust and document it. The receiver must be able to identify a failed frame through CRC.
4. **Implement modulation.** Map payload+CRC bits using QPSK, 16-QAM or 64-QAM with a stated normalization. Pad only to complete OFDM symbols; record pad count so Abhinav removes it before CRC/BER calculations.
5. **Implement OFDM.** Fill agreed data and pilot bins; leave guard/DC bins unused; IFFT each symbol; prepend CP; concatenate with preamble. Output a complex column vector and metadata. Make transmit power and antenna gain explicit RF/link-budget parameters; clearly explain any waveform normalization.
6. **Set adaptation policy.** Agree with Abhinav how a previous-frame SINR estimate selects the next frame's modulation, including initial mode and thresholds. Do not use the true channel or after-the-fact CRC to label a mode as adaptive. If thresholds are tuned, save the tuning method.
   The group has fixed QPSK first frame and provisional 12/23 dB cutoffs. Abhinav's final PER/SINR results must justify or replace those cutoffs. Run an actual multi-frame adaptive sequence before making an adaptive-performance claim.
7. **Use field data meaningfully.** Obtain Soukaryo's original RSSI data and document how its trend calibrates or validates a link parameter. The transmitter section may reference this shared dataset, but Soukaryo owns its collection and detailed comparison.
8. **Calculate and plot.** Plot occupied subcarriers/pilots and a spectrum with axes/units. Calculate EIRP = transmit power (dBm) + transmit antenna gain (dBi) minus any stated feeder loss (dB). Calculate nominal bit rate from data carriers × bits/carrier ÷ OFDM-symbol time, then account separately for header/preamble/CRC overhead if reporting nominal payload rate. Do not label this as measured goodput.

## Handoff contract

For each frame send Prisha `txWaveform`, `cfg` and `txMeta`. `txMeta` should contain payload bits, modulation, frame ID, CRC details, padding, preamble, pilot/data bin indices and timing. Keep ground-truth payload bits outside the receiver's normal decoding inputs; they are for BER validation after decoding. Make a simple high-SNR loopback with Abhinav before the full scenario run.

## What to write by hand for A

State the objective; draw Tx blocks and frame format; list exact OFDM/modulation/configuration parameters; explain framing, CRC, modulation, pilots, IFFT and CP; show spectrum and resource mapping; calculate EIRP and nominal throughput with units; state how the field dataset informs the link model; explain the adaptive rule. Insert printed figures/screenshots at appropriate places in the scanned assignment. Label assumptions and plots. Write your name and signature on **every** page you handwrite.

## Team-lead checks

- Confirm all four sections use the same config, locations, load names, units and final run results.
- Add required front matter: subject code/name, date, section, group number, all names/registration numbers and contribution table.
- Check every handwritten page for **all four members' names and signatures**; collect original figure/measurement screenshots.
- Create the **single handwritten PDF by 25 Oct 2026, 5:00 PM**. For the later **1 Nov 2026, 5:00 PM** submission, prepare one project PDF and one ZIP with all experiment files. Use `GroupNumber_QuestionNumber` naming, for example `G01_Q20.pdf`.
- Open the final PDF(s) and ZIP after export to verify pages, image legibility and that code/data needed to reproduce results are present.

## Done when

The transmitter deterministically regenerates the same waveform for the same seed and configuration; clean loopback recovers payload/CRC; plots and calculations match the settings; all four members' work runs from the README; the two submissions meet their distinct format and deadline requirements.
