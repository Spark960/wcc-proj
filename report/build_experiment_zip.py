"""Package the Question 20 experiment after the final typed PDF is ready.

Run from the repository root:
    python report/build_experiment_zip.py --report path/to/final_project_report.pdf
"""

from __future__ import annotations

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "submission" / "Question20_experiment_files.zip"
ALLOWED_SUFFIXES = {".m", ".py", ".md", ".csv", ".mat", ".png", ".jpg", ".jpeg", ".txt"}
EXCLUDED_PARTS = {
    "archive_before_timing_fix", "__pycache__", ".git", "outputs", "submission"
}
EXCLUDED_FILES = {
    "field_rssi_SYNTHETIC.csv", "field_rssi_OBSERVED_PARTIAL.csv",
    "field_rssi_TEMPLATE.csv"
}


def collect() -> list[Path]:
    roots = ["code", "lokesh/figures", "data", "figures/field", "results/receiver/adaptive_500",
             "results/receiver/power_study"]
    roots += [str(p.relative_to(ROOT)) for p in (ROOT / "results/receiver").glob("power_*_500") if p.is_dir()]
    files = [ROOT / "README.md", ROOT / "CURRENT_STATUS.md",
             ROOT / "results/received_power_comparison.png", ROOT / "results/sinr_by_scenario.png",
             ROOT / "results/tx_channel_waveform.png", ROOT / "results/channel_validation_results.csv",
             ROOT / "report/HANDWRITTEN_COPY_DRAFT.md", ROOT / "report/FINAL_ASSEMBLY_GUIDE.md",
             ROOT / "report/FLOWCHARTS_TO_DRAW.md"]
    for name in roots:
        folder = ROOT / name
        if not folder.is_dir():
            raise FileNotFoundError(folder)
        files.extend(p for p in folder.rglob("*") if p.is_file())
    selected = sorted({p for p in files if p.exists() and p.suffix.lower() in ALLOWED_SUFFIXES
                       and p.name not in EXCLUDED_FILES
                       and not any(part in EXCLUDED_PARTS for part in p.relative_to(ROOT).parts)})
    required = [ROOT / "code/runPowerStudy.m", ROOT / "code/plotPowerStudy.m",
                ROOT / "data/field_rssi.csv", ROOT / "data/raw/wifi_ap_exports_2026-10-24_near_middle_edge.txt",
                ROOT / "results/receiver/power_study/power_study_500.csv",
                ROOT / "results/receiver/power_study/field_trend_comparison.csv"]
    missing = [str(p) for p in required if p not in selected]
    if missing:
        raise FileNotFoundError("Required experiment files missing: " + ", ".join(missing))
    return selected


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path, required=True, help="Final typed project PDF")
    args = parser.parse_args()
    report = args.report.resolve()
    if not report.is_file() or report.suffix.lower() != ".pdf":
        parser.error("--report must point to the completed project PDF")
    files = collect()
    OUTPUT.parent.mkdir(exist_ok=True)
    with ZipFile(OUTPUT, "w", ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, path.relative_to(ROOT).as_posix())
        archive.write(report, f"report/{report.name}")
    with ZipFile(OUTPUT) as archive:
        bad = archive.testzip()
        if bad:
            raise RuntimeError(f"ZIP integrity check failed: {bad}")
        names = set(archive.namelist())
        if any("SYNTHETIC" in name or "OBSERVED_PARTIAL" in name for name in names):
            raise RuntimeError("Excluded field dataset entered ZIP")
    print(f"Created {OUTPUT} with {len(files) + 1} files ({OUTPUT.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
