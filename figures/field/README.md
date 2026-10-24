# Field time-graph screenshots (24 October 2026, IST)

| Location | File | Clock shown | Current connection shown in banner |
| --- | --- | --- | --- |
| near | `near_time_graph.png` | 7:34 pm | `d8:38:0d:1b:90:e9`, 5 GHz channel 153, -68 dBm |
| middle | `middle_time_graph.png` | 7:36 pm | `d8:38:0d:1b:5e:e9`, 5 GHz channel 153, -66 dBm |
| edge | `edge_time_graph.png` | 7:38 pm | `d8:38:0d:1b:41:91`, 2.4 GHz channel 9, -70 dBm |

The connected BSSID changes between locations. The graph is set to the 2.4 GHz band, and each colored curve is a separate AP, but its labels do not display a full BSSID. Several APs share `iBus@Block-10`. The screenshots therefore do **not** identify which curve belongs to any particular BSSID, nor provide ten auditable numeric samples for one AP. The plotted scan-count axis reaching 10 does not establish ten fresh values for one specific AP. The app also displays "Wi-Fi scan throttling is enabled," and some curves are flat or have gaps.

The earlier user-provided AP-list exports contained one auditable RSSI for BSSID `d8:38:0d:1b:40:c1` at each location: -52 dBm at 19:34:28, -74 dBm at 19:36:14, and -87 dBm at 19:38:13. Those are preserved in `../../data/field_rssi_OBSERVED_PARTIAL.csv`. A **later, separate** 20:15–20:20 AP-list export session is now the report's field dataset in `../../data/field_rssi.csv`, using BSSID `d8:38:0d:1b:40:51`. These screenshots do not show the later numeric readings. If included in a report, label them as an earlier app-interface illustration and crop or redact connection identifiers consistently.
