import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const outputDir = path.dirname(fileURLToPath(import.meta.url));
const headers = ['Time Stamp','SSID','BSSID','Strength','Primary Channel','Primary Frequency','Center Channel','Center Frequency','Width (Range)','Distance','802.11mc','Security','Standard','FastRoaming'];
const raw = `2026/10/24-19:25:18|JioPrivateNet|00:a0:0a:38:c1:30|-96dBm|161|5805MHz|159|5795MHz|40MHz (5775 - 5815)|~259.2m|false|[WPA2-EAP/SHA1-CCMP][RSN-EAP/SHA1-CCMP][ESS]|802.11ac|
2026/10/24-19:25:18|JioPrivateNet|00:a0:0a:55:93:b0|-94dBm|1|2412MHz|1|2412MHz|20MHz (2402 - 2422)|~495.6m|false|[WPA2-EAP/SHA1-CCMP][RSN-EAP/SHA1-CCMP][ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:3f:a1|-67dBm|11|2462MHz|11|2462MHz|20MHz (2452 - 2472)|~21.7m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:40:51|-86dBm|9|2452MHz|9|2452MHz|20MHz (2442 - 2462)|~194.1m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:1b:41:01|-71dBm|1|2412MHz|1|2412MHz|20MHz (2402 - 2422)|~35.1m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:41:91|-85dBm|9|2452MHz|9|2452MHz|20MHz (2442 - 2462)|~173.0m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:41:c1|-39dBm|5|2432MHz|5|2432MHz|20MHz (2422 - 2442)|~0.9m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:41:c9|-40dBm|36|5180MHz|38|5190MHz|40MHz (5170 - 5210)|~0.5m|false|[ESS]|802.11ac|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:42:61|-61dBm|2|2417MHz|2|2417MHz|20MHz (2407 - 2427)|~11.1m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:1b:42:a1|-73dBm|9|2452MHz|9|2452MHz|20MHz (2442 - 2462)|~43.4m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:1b:42:a9|-87dBm|153|5765MHz|155|5775MHz|40MHz (5755 - 5795)|~92.6m|false|[ESS]|802.11ac|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:5d:81|-94dBm|1|2412MHz|1|2412MHz|20MHz (2402 - 2422)|~495.6m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10-3132-3133|d8:38:0d:1b:5e:71|-81dBm|10|2457MHz|10|2457MHz|20MHz (2447 - 2467)|~108.9m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:1b:90:61|-71dBm|1|2412MHz|1|2412MHz|20MHz (2402 - 2422)|~35.1m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:91:11|-40dBm|2|2417MHz|2|2417MHz|20MHz (2407 - 2427)|~1.0m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10|d8:38:0d:1b:92:c1|-71dBm|6|2437MHz|6|2437MHz|20MHz (2427 - 2447)|~34.7m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:1b:92:f1|-77dBm|3|2422MHz|3|2422MHz|20MHz (2412 - 2432)|~69.7m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@Block-10-B11-B12|d8:38:0d:1b:93:61|-78dBm|6|2437MHz|6|2437MHz|20MHz (2427 - 2447)|~77.7m|false|[ESS]|802.11n|
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:43:c3:c1|-59dBm|3|2422MHz|3|2422MHz|20MHz (2412 - 2432)|~8.8m|false|[ESS]|802.11n|802.11k 802.11v
2026/10/24-19:25:18|iBus@MAHE|d8:38:0d:64:a6:79|-75dBm|1|2412MHz|1|2412MHz|20MHz (2402 - 2422)|~55.6m|false|[ESS]|802.11n|`;
const rows = raw.split('\n').map(x => x.split('|'));
if (rows.length !== 20 || rows.some(x => x.length !== headers.length)) throw new Error('Source row shape mismatch');
const workbook = Workbook.create();
const sheet = workbook.worksheets.add('AP Scan');
sheet.showGridLines = false;
sheet.getRange('A1').values = [['Wi-Fi access point scan']];
sheet.getRange('A2').values = [['Source: user-provided WiFi Analyzer export · 24 Oct 2026, 19:25:18']];
sheet.getRange('A3').values = [['20 APs in one scan. Each BSSID identifies an individual radio; app distance estimates are not measured distances.']];
sheet.getRange('A1:N1').format.fill = '#17365D';
sheet.getRange('A1:N1').format.font.color = '#FFFFFF';
sheet.getRange('A1:N1').format.font.bold = true;
sheet.getRange('A1:N1').format.rowHeight = 32;
sheet.getRange('A2:N3').format.fill = '#EAF1F8';
sheet.getRange('A2:N3').format.rowHeight = 22;
sheet.getRange('A5:N25').values = [headers, ...rows];
const table = sheet.tables.add('A5:N25', true, 'AccessPointScan');
table.style = 'TableStyleMedium2';
table.showFilterButton = true;
sheet.getRange('A:A').format.columnWidth = 22;
sheet.getRange('B:B').format.columnWidth = 28;
sheet.getRange('C:C').format.columnWidth = 21;
sheet.getRange('D:D').format.columnWidth = 12;
sheet.getRange('E:E').format.columnWidth = 17;
sheet.getRange('F:F').format.columnWidth = 20;
sheet.getRange('G:G').format.columnWidth = 17;
sheet.getRange('H:H').format.columnWidth = 20;
sheet.getRange('I:I').format.columnWidth = 27;
sheet.getRange('J:J').format.columnWidth = 12;
sheet.getRange('K:K').format.columnWidth = 12;
sheet.getRange('L:L').format.columnWidth = 52;
sheet.getRange('M:M').format.columnWidth = 14;
sheet.getRange('N:N').format.columnWidth = 22;
sheet.getRange('A5:N25').format.rowHeight = 22;
sheet.freezePanes.freezeRows(5);
const out = path.join(outputDir, 'wifi_ap_scan_2026-10-24.xlsx');
const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(out);
console.log(JSON.stringify({file:out,rows:rows.length,table:table.name}));
