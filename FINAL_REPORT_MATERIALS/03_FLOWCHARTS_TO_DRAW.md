# Question 20 flowcharts to draw by hand

Draw the first diagram near the start of Part A or on a shared architecture page. Use the same names and arrows. The dotted feedback arrow carries the **previous frame's receiver-estimated SINR**; it is not perfect channel knowledge.

```mermaid
flowchart LR
    CFG[Configuration and Tx power] --> SEL[Select QPSK / 16-QAM / 64-QAM]
    DATA[Seeded payload bits] --> CRC[Add CRC-16]
    SEL --> MAP[QAM mapping]
    CRC --> MAP
    MAP --> OFDM[48 data + 4 pilots; IFFT + cyclic prefix]
    OFDM --> FRAME[Preamble + header + payload; power scaling]
    FRAME --> CH[Path loss + shadowing + 4-tap fading + noise + co-channel interference]
    CH --> SYNC[Preamble synchronization; remove CP + FFT]
    SYNC --> EST[Estimate channel from training; correct with pilots]
    EST --> DEC[Equalize; decode header + payload; check CRC]
    DEC --> MET[BER, PER, goodput, latency proxy]
    EST -. previous-frame estimated SINR .-> SEL
```

For a neat handwritten version, put **Transmitter** above the boxes from Select through Frame, **Channel** above the impairment box, and **Receiver** above Synchronization through CRC. Put **Offline evaluation** above the metrics box. Do not draw an arrow from the true simulated channel taps to the receiver or adaptive selector.

Draw the second diagram at the start of Part D. It shows the evidence and decision process; it does not imply the phone measured the simulated waveform.

```mermaid
flowchart TB
    F[One 2.4 GHz BSSID across near, middle, far exports] --> R[Mean exported RSSI: -68.71; -72.45; -94 dBm]
    R --> DROP[Near-relative field drops: 0, 3.74, 25.29 dB]
    SIM[Simulated six-case channel power] --> SDROP[Compute near-relative simulated drops: 0, 28.34, 38.77 dB]
    DROP --> CMP[Compare trends; repeated RSSI may be cached]
    SDROP --> CMP
    SWEEP[500-frame MATLAB sweep: 10/15/20 dBm x four rules] --> TARGET{PER <= 5% and goodput >= 5 Mbps at all 3 low-load locations?}
    TARGET -->|No tested option| BEST[20 dBm fixed QPSK: best tested fallback; 2/3 locations pass]
    CMP --> CONC[Engineering conclusion and limitations]
    BEST --> CONC
```

In the handwritten diagram, use rectangles for processes, a diamond for the target check, solid arrows for the signal/evidence path and a dotted arrow for feedback. Add the caption **"Figure 1. End-to-end model and prior-frame adaptation"** under the first and **"Figure 2. Field trend and configuration decision"** under the second.
