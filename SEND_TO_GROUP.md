# Message to send with the repository link

> I have fixed our Question 20 design and interfaces in the repo. Please pull the latest `main`, read `README.md` and `DESIGN_FREEZE_AND_HANDOFFS.md`, then read your named instruction file. Keep all numerical settings in `code/getConfig.m` so our sections match. The values for indoor loss, interference and power are labeled assumptions until checked against real measurements.
>
> **Prisha:** Start the path-loss/shadowing/4-tap fading/AWGN/co-channel-OFDM channel. Use the six scenarios and exact powers in the design file. Return `rxWaveform` and public scenario info to Abhinav; keep true taps/SINR separately for verification. First 20 frames per case, final 500. Send the first working channel and scenario table by 20 Oct.
>
> **Abhinav:** Start the receiver in parallel using the existing transmitter and an 8-sample leading delay. Build real preamble synchronization, channel estimation/equalization, header/payload decoding and CRC. Then integrate Prisha's channel and send six-case BER/PER/goodput/latency-proxy results. Do not feed original payload bits or true channel taps into your decoder. First working receiver by 20 Oct.
>
> **Soukaryo:** Start field measurements now at the agreed near/middle/edge positions. Use one permitted 2.4 GHz Wi-Fi AP and one listed app; collect 10 real RSSI readings and screenshots per position. Put raw rows in the template and send them to Prisha early. After Abhinav's results, do the trend comparison, target table, limiting-factor analysis and final decision using the rule in the design file. Do not invent readings or claim an untested setting meets targets.
>
> **I (Lokesh)** own the transmitter and final integration. We aim for working modules plus raw field data by 20 Oct, integrated results and handwritten drafts by 22 Oct, checked scans by 24 Oct, handwritten PDF submission by 25 Oct 5 PM, and final project PDF + ZIP by 1 Nov 5 PM. Each person writes their entire assigned sub-question by hand. For the safest reading of the instructions, all four of us should write names and signatures on every handwritten page before scanning.
