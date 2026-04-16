#!/usr/bin/env python3
"""
get_carculator_data.py

Pull per-vehicle LCA results from carculator for specified powertrains, sizes, and years,
and export tidy CSVs you can scale to fleet stocks.

Usage examples:
  python get_carculator_data.py --years 2020 2025 2030 --sizes Small Medium SUV \
    --powertrains ICEV-p HEV-p PHEV-p BEV --region NO --cycle WLTC --outfile carculator_NO.csv

If you have ecoinvent set up with carculator's inventory pipeline, add:
  --use-background
"""

import argparse
import sys
import pandas as pd



def parse_args():
    p = argparse.ArgumentParser(description="Export per-vehicle LCA results from carculator")
    p.add_argument("--years", nargs="+", type=int, required=True,
                   help="Vehicle model years, e.g., 2020 2025 2030")
    p.add_argument("--sizes", nargs="+", default=["Small", "Medium", "Large"],
                   help="Size classes, e.g., Small Medium Large SUV")
    p.add_argument("--powertrains", nargs="+", default=["ICEV-p", "HEV-p", "PHEV-p", "BEV"],
                   help="Powertrains, e.g., ICEV-p HEV-p PHEV-p BEV")
    p.add_argument("--cycle", default="WLTC", help="Driving cycle, e.g., WLTC, NEDC, ARTEMIS")
    p.add_argument("--region", default="NO", help="Country/region code (e.g., NO for Norway)")
    p.add_argument("--outfile", default="carculator_results.csv", help="Output CSV filename")
    p.add_argument("--use-background", action="store_true",
                   help="If set, compute full background-linked LCA (requires ecoinvent setup).")
    p.add_argument("--iam", default=None, help="IAM scenario label if applicable (e.g., REMIND)")
    p.add_argument("--scenario-year", type=int, default=None,
                   help="IAM scenario year for background data if applicable (e.g., 2030)")
    return p.parse_args()


def friendly_exit(msg, code=1):
    print(f"[ERROR] {msg}", file=sys.stderr)
    sys.exit(code)


def main():
    args = parse_args()

    try:
        # Core objects (names differ slightly across versions; we handle common cases)
        from carculator import CarModel
        try:
            from carculator import load_default_inputs  # modern API
            loader = "modern"
        except Exception:
            # Some versions expose data loading via CarModel/data submodules
            loader = "fallback"
        # InventoryCalculation is used for background LCA in many versions
        try:
            from carculator import InventoryCalculation
            has_inventory = True
        except Exception:
            has_inventory = False

    except ImportError:
        friendly_exit("carculator is not installed. Try: pip install carculator")

    # Build scope
    scope = {
        "powertrain": args.powertrains,
        "size": args.sizes,
        "year": args.years,
    }

    # Load input arrays / parameters
    try:
        if loader == "modern":
            # Typical modern pattern
            array = load_default_inputs(args.cycle, scope)
        else:
            # Fallback: try a helper on CarModel itself
            try:
                array = CarModel.load_default_inputs(args.cycle, scope)  # type: ignore
            except Exception as e:
                friendly_exit(
                    "Could not load default inputs. Your carculator version may differ.\n"
                    f"Details: {e}\n"
                    "Try upgrading: pip install --upgrade carculator"
                )
    except Exception as e:
        friendly_exit(f"Failed to prepare input arrays: {e}")

    # Inject/adjust region if supported (electricity mix, fuel specs, etc.)
    # Not all versions expose a simple setter; we try common attributes.
    try:
        # Many versions store a 'country' or 'region' array. We apply Norway where possible.
        for key in ("country", "region"):
            if key in array:
                array[key] = args.region
    except Exception:
        pass

    # Instantiate model and compute per-vehicle impact indicators
    try:
        cm = CarModel(array)
    except Exception as e:
        friendly_exit(f"Failed to build CarModel: {e}")

    # Try computing "foreground" results (per-vehicle life-cycle breakdown without background linking).
    # Different versions expose different methods; we try a few.
    results = None
    tried = []

    # Candidate call patterns to gather a breakdown including production, use-phase, EOL, etc.
    call_patterns = [
        ("calculate_impacts", dict()),               # cm.calculate_impacts()
        ("calculate", dict()),                       # cm.calculate()
        ("lca", dict()),                             # cm.lca() some versions
    ]

    for meth, kwargs in call_patterns:
        if hasattr(cm, meth):
            tried.append(meth)
            try:
                results = getattr(cm, meth)(**kwargs)
                if results is not None:
                    break
            except Exception:
                results = None

    if results is None:
        friendly_exit(
            "Could not compute per-vehicle results via known methods.\n"
            f"Tried: {', '.join(tried)}.\n"
            "Please check the carculator documentation for your version and update the call pattern."
        )

    # Normalize results to a tidy DataFrame
    # Many carculator versions return an xarray Dataset or nested dict-of-dicts.
    # We attempt to coerce to a flat table with MultiIndex (powertrain,size,year) and columns = impact categories.
    def coerce_to_df(obj):
        try:
            import xarray as xr  # often useful; optional dependency
            if isinstance(obj, xr.Dataset) or isinstance(obj, xr.DataArray):
                df = obj.to_dataframe()
                # Large multi-index; reset and pivot to a tidy table
                df = df.reset_index()
                return df
        except Exception:
            pass

        if isinstance(obj, dict):
            # Expect nested dict like results[impact_name][(powertrain,size,year)] = value, or similar
            rows = []
            def flatten(d, prefix=()):
                if isinstance(d, dict):
                    for k, v in d.items():
                        flatten(v, prefix + (k,))
                else:
                    rows.append((*prefix, d))
            # This is intentionally permissive; we will reshape below
            try:
                flatten(obj)
                df = pd.DataFrame(rows)
                return df
            except Exception:
                pass

        # Last resort: try pandas directly
        try:
            return pd.DataFrame(obj)
        except Exception:
            return None

    df_raw = coerce_to_df(results)
    if df_raw is None or df_raw.empty:
        friendly_exit(
            "Got results but could not coerce them to a DataFrame. "
            "Inspect the 'results' object shape in an interactive session."
        )

    # Heuristic tidy-up:
    # We try to detect common columns/dimensions for powertrain, size, year and impact names.
    # You may fine-tune the renaming below for your version.
    cols = [c.lower() for c in df_raw.columns.astype(str)]
    df_raw.columns = cols

    # Guess typical keys
    guess_keys = {
        "powertrain": [c for c in cols if "powertrain" in c or "pt" == c],
        "size": [c for c in cols if c in ("size", "segment", "class")],
        "year": [c for c in cols if c in ("year", "model_year")],
        "impact": [c for c in cols if c in ("impact", "indicator", "impact_category")],
        "value": [c for c in cols if c in ("value", "score", "gwp", "total", "result")],
        "phase": [c for c in cols if c in ("phase", "stage", "life_cycle_stage")],
        "unit": [c for c in cols if c == "unit"],
    }

    # Basic sanity: we need at least vehicle identifiers and a numeric column
    id_cols = []
    for k in ("powertrain", "size", "year"):
        if guess_keys[k]:
            id_cols.append(guess_keys[k][0])

    value_col = guess_keys["value"][0] if guess_keys["value"] else None
    if not id_cols or value_col is None:
        # Fall back: keep everything and let the user map columns
        out = df_raw
    else:
        keep = set(id_cols)
        if guess_keys["impact"]:
            keep.add(guess_keys["impact"][0])
        if guess_keys["phase"]:
            keep.add(guess_keys["phase"][0])
        if guess_keys["unit"]:
            keep.add(guess_keys["unit"][0])
        keep.add(value_col)
        keep = [c for c in df_raw.columns if c in keep]
        out = df_raw[keep].copy()

    # If requested (and supported), compute full background LCA via InventoryCalculation
    if args.use_background:
        if not has_inventory:
            print("[WARN] InventoryCalculation not available in this carculator version. "
                  "Skipping background LCA.", file=sys.stderr)
        else:
            try:
                ic = InventoryCalculation(cm)

                # If your version supports IAM linking (e.g., REMIND) for future years, set here
                if args.iam:
                    try:
                        ic.set_scenario(iam_model=args.iam, year=args.scenario_year or max(args.years))
                    except Exception:
                        print("[WARN] Could not set IAM scenario on InventoryCalculation. "
                              "Proceeding with defaults.", file=sys.stderr)

                lca_results = ic.calculate_impacts()  # often returns dict/xarray; coerce next
                df_bg = coerce_to_df(lca_results)
                if df_bg is not None and not df_bg.empty:
                    # Best-effort harmonization
                    df_bg.columns = [c.lower() for c in df_bg.columns.astype(str)]
                    # Tag as background_LCA to distinguish
                    if "source" not in df_bg.columns:
                        df_bg["source"] = "background_LCA"
                    if "source" not in out.columns:
                        out["source"] = "foreground"
                    # Union (align columns)
                    out = pd.concat([out, df_bg.reindex(columns=out.columns, fill_value=None)], ignore_index=True)
                else:
                    print("[WARN] Background LCA results present but could not be tabulated. "
                          "Keeping foreground-only table.", file=sys.stderr)
            except Exception as e:
                print(f"[WARN] Background LCA failed: {e}\nContinuing with foreground-only results.",
                      file=sys.stderr)

    # Add metadata columns for traceability
    out["cycle"] = args.cycle
    out["region_requested"] = args.region

    # Write CSV
    out.to_csv(args.outfile, index=False)
    print(f"[OK] Wrote {len(out):,} rows to {args.outfile}")

    # Also write a pivoted summary by (powertrain, size, year) if possible
    try:
        p_cols = [c for c in out.columns if c in ("powertrain", "size", "year")]
        val = value_col if value_col and value_col in out.columns else None
        if p_cols and val:
            piv = out.pivot_table(index=p_cols,
                                  columns=[c for c in out.columns if c in ("impact", "phase")],
                                  values=val,
                                  aggfunc="mean")
            piv = piv.reset_index()
            sumfile = args.outfile.replace(".csv", "_summary.csv")
            piv.to_csv(sumfile, index=False)
            print(f"[OK] Wrote summary to {sumfile}")
    except Exception:
        pass

def run_carculator(years, sizes, powertrains, region, cycle, outfile):
    from carculator import load_default_inputs, CarModel
    import pandas as pd

    scope = {
        "powertrain": powertrains,
        "size": sizes,
        "year": years,
    }

    array = load_default_inputs(cycle, scope)

    if "country" in array:
        array["country"] = region

    cm = CarModel(array)
    results = cm.calculate_impacts()

    df = results.to_dataframe().reset_index()
    df.to_csv(outfile, index=False)
    print(f"[OK] Saved {len(df)} rows to {outfile}")

if __name__ == "__main__":
    main()
