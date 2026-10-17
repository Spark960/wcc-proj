# Soukaryo — Question 20D: measurements, analysis and decision

Read `00_GROUP_PLAN.md` first. You own the **entire D sub-question**: field-trend validation, identification of the dominant limitation, explicit targets and a justified final engineering configuration. You also own the real measurement dataset needed by the shared project.

## Deliverables

1. Original permitted mobile-app measurements as CSV/table and unedited screenshots.
2. Measurement method: app/device, date/time, connection/network, three location labels, approximate distances and conditions.
3. Comparison of measured RSSI trend with simulated received-power trend, with deviations explained.
4. Target-versus-result table, dominant-limitation analysis and final recommended configuration.
5. Your complete handwritten D pages, with **Soukaryo and your signature on every page**.

## Field measurement procedure

1. Choose one app from page 2 of the assignment that exposes Wi-Fi signal level, such as **WiFi Analyzer**, and use one phone and one permitted access point/network. Follow institutional/network policies; measure only permitted information and the group's own traffic. Do not capture other people's packets or private identifiers.
2. Coordinate `near`, `middle` and `edge` locations with Prisha. Record approximate distance and major obstructions (wall/corridor/floor). Keep the phone and access point consistent. If distance is uncertain, mark it as approximate.
3. At each location, collect several RSSI readings at a consistent time interval; save all readings, not just a favorable value. Take screenshots that show the app and relevant readings. Record date/time, phone model, app name, Wi-Fi band/channel if available, and whether the phone stayed on the same access point.
4. Use a table with columns such as `location, sample, approximate_distance_m, rssi_dBm, time, app, device, notes`. Keep raw readings in `data/field_rssi.csv`; calculate a mean/spread separately. Never replace original readings with simulated or fabricated values.
5. Give Prisha the dataset as soon as collected, ideally by 20 Oct, so path-loss trend calibration/checking is part of the model rather than a last-minute screenshot.

## Analysis procedure

1. Obtain Abhinav's final six-scenario table and Prisha's link-budget/received-power values. Check that units and location labels match the field table.
2. Plot or tabulate measured RSSI against simulated received power across the three positions. Comparing the *change* from near to edge is safest when actual access-point EIRP and device calibration are unknown. If claiming an absolute match, document how the model was calibrated.
3. Explain meaningful deviations: walls/multipath, access-point power/antenna uncertainty, phone RSSI reporting, time variation, interference and the difference between a simplified channel and the real environment. Do not claim the simulation is validated merely because both curves decrease.
4. Define explicit targets **before selecting the final configuration**: maximum acceptable PER, minimum delivered goodput and a coverage criterion at the edge point. Enter chosen threshold values and why they are appropriate; these are engineering assumptions, not assignment-given targets.
5. Compare each of the six cases against the targets. Identify the limiting factor supported by the results: coverage, interference, bandwidth or receiver performance (and mobility only if the model actually includes it). Explain why using quantitative differences, e.g. high-load versus low-load at the same location isolates interference better than comparing unrelated points.
6. Recommend specific transmit power, antenna gain, bandwidth and adaptive modulation policy. State whether it meets each target; if a target is missed, describe the required change and trade-off honestly. Do not claim an untested configuration works—run it or label it as a proposal.

## What to write by hand for D

Describe field measurement method and table; insert original app screenshots; compare measured and simulated trends; present results and target-versus-result table; identify dominant limitation with numerical evidence; state the final configuration and justify reliability, throughput and coverage trade-offs. Mention measurement/model limitations. Write your name and signature on **every** page you handwrite.

## Done when

There is authentic field evidence at three matching locations; the simulated trend is compared and deviations explained; the limiting factor and final design follow from measured/simulated numbers; every target is reported as met or unmet; your handwritten D section is ready for Lokesh to scan and merge.
