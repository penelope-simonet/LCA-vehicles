from get_carculator_data import run_carculator

run_carculator(
    years=[2020, 2025, 2030],
    sizes=["Small", "Medium", "SUV"],
    powertrains=["ICEV-p", "HEV-p", "PHEV-p", "BEV"],
    region="NO",
    cycle="WLTC",
    outfile="carculator_NO.csv"
)