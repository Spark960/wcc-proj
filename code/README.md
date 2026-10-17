# Lokesh's transmitter implementation

Open the cloned repository as MATLAB's Current Folder, then run in MATLAB R2026b or a compatible recent release:

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx
runLokeshTx
```

The commands use the repository's current folder, so they work after cloning to a different computer. If MATLAB's Current Folder is elsewhere, first navigate to the cloned repository root in MATLAB.

`checkLokeshTx` checks the CRC-16 known vector (`123456789` → `29B1`), deterministic waveform generation, configured average transmit power and a zero-impairment OFDM loopback for all three modulation modes. `runLokeshTx` prints the rate/EIRP table and exports `../figures/tx_resource_mapping.png` and `../figures/tx_spectrum.png`.

## API for the group

```matlab
cfg = getConfig();
mode = selectTxMode(previousFrameSinrDb,cfg); % NaN for first frame
[txWaveform, txMeta] = transmitFrame(frameId,mode,cfg);
```

`txWaveform` is a complex column vector with mean squared magnitude equal to configured transmit power in watts, using a nominal 1-ohm complex-baseband convention. The antenna gain and feeder loss are **link-budget values**, not extra scaling of these samples. `txMeta` contains payload truth for offline BER comparison, header/CRC/padding data, carrier mapping and timing. Do not feed original payload bits or perfect channel information to the operational receiver.

The frame has two identical known preamble OFDM symbols, one QPSK header OFDM symbol and variable-length payload OFDM symbols. All OFDM symbols use 64 FFT bins and 16 CP samples. The 52 occupied bins are `-26:-1` and `1:26`, with pilots at `[-21 -7 7 21]` and 48 remaining data bins. The header contains marker `A7`, 16-bit frame ID, 2-bit mode, 16-bit payload length, CRC-8/ATM and zero padding. The payload uses CRC-16/CCITT-FALSE. Bit fields are MSB first. QAM is Gray coded and normalized to unit average constellation power. The complete frame is normalized once, then scaled to the configured transmit power.

`getConfig.m` currently sets 20 MHz sample rate/channel bandwidth, 15 dBm transmit power, 2 dBi Tx antenna gain and 0 dB feeder loss. Change `bandwidthHz` there; the sample rate follows it. Thus EIRP is 17 dBm. The uncoded continuous-symbol rates are 24, 48 and 72 Mbps for QPSK, 16-QAM and 64-QAM. For the 96-byte frames including preamble/header/CRC but assuming zero errors, the corresponding payload airtime rates are 16, 24 and 32 Mbps. None of these is measured goodput; failed frames and retransmissions are not included.

The SINR thresholds `[12 23]` dB are **provisional design assumptions**. Abhinav and Soukaryo should tune and justify them from PER results before calling the final configuration validated. `selectTxMode` uses only a **previous-frame** SINR report and defaults to QPSK on the first frame. The actual measured Wi-Fi RSSI dataset is still needed from Soukaryo; no field measurement is fabricated in this transmitter.

`getConfig.m` also contains the agreed *baseline assumptions* for Prisha's channel, the six scenarios, trial count and evaluation targets. They are specified in `DESIGN_FREEZE_AND_HANDOFFS.md`. Adding these fields does **not** mean the channel/receiver/analysis have been implemented.

## Integration notes

- Prisha should accept `txWaveform` and `cfg`, apply the channel and return a received waveform. She may retain `txMeta` for truth/metrics, but should not provide its payload bits to Abhinav's decoder.
- Abhinav can synchronize with the repeated preamble, use the known preamble and pilots to estimate/equalize the channel, decode the robust QPSK header, then use its mode/length fields to decode payload and CRC. `txIdealLoopback.m` is only a transmitter functional check: it knows the frame boundary and uses one flat pilot gain, so it is **not** the project receiver.
- The exact use of 20 MHz, Tx power and RF channel in the real Wi-Fi measurement must be documented. The simulated transmitter is a generic OFDM link, not a claim that the phone or access point implements this exact waveform.
