# Diagnostic export before timing correction

Original user-provided MATLAB Online export, preserved unchanged below this
folder. The run completed after the struct-collector fix; its diary also contains
the earlier failed attempt because the old diary appended to an existing file.

All eight CSV pairs were checked for agreement of frame counts, packet failures
and bit-error totals. However, this is not accepted final receiver performance.
For near_lowInterference, 107/500 final frames had valid headers and no recovered
bits: 93 selected sample 11 and 14 selected sample 14. All other near-low frames
recovered their payload. The receiver returned early on these late windows
because the full frame exceeded the receive-buffer length. The revised receiver
continues its timing search instead. Both calibrated thresholds were infinite,
so the archived final policy used QPSK for every frame. Recalibration is required.

Do not use these results to conclude that the physical channel alone causes the
21.4% near-low PER, or that adaptive modulation inherently fails.
