# Changelog

## 1.0 (November 2026)

A review-and-test release. Every fix below has a test in `tests/test_quicklab.m`
or was checked against the EEGLAB function it replaces.

### Fixed: results were wrong
- **Quick BSS returned a flat recording.** `par_autobss` cleaned each window in
  parallel but never stitched the windows back together, so "Quick BSS" and
  "Quick BSS full file" replaced the data with zeros. It now matches AAR's
  `autobss` exactly.
- **Parallel DIPFIT failed silently on standard installs.** `pop_par_multifit2`
  called `dipfit_nonlinear2`, a modified copy that only existed on the author's
  machine; the error was caught, so every component got `rv = NaN`. It now uses
  DIPFIT's `dipfit_nonlinear` and matches `pop_multifit`. Selecting components
  other than `1:n` (e.g. `[3 5]`) also errored and is fixed.
- **Partial component removal left ICA fields inconsistent.** Activations from
  `pop_subcomp` (fewer components) were copied into a dataset that still had all
  ICA weights; they are now recomputed.
- **Trial-by-trial marks could crash or duplicate.** `merge_trials` crashed when
  three or more marks covered the same epoch and could emit duplicate rows.
- **Event legend in the Data Scroll Pro** split string event types into single
  characters, so rows and checkboxes did not line up; Apply also failed with a
  single event type.
- `quick_unepoch` stored the time axis in samples.
- The ICA max-min dialog ran TBT's channel version instead of the component one.

### Fixed: menu items that errored
- High-pass filter items called the low-pass function; separate
  `quick_highpass` / `quick_lowpass`.
- "Un-Epoch", "Quick Run CorrMap", "Quick IClabel, DIPFIT & Viewprops+",
  "N-1 PCA" and the BSS items failed when clicked.
- Items for functions that never existed were removed (`pop_viewprops_erp`,
  `plotDifference`, `print_ICA`, `print_FFT`, parallel BSS stub).

### Changed
- ICA uses `cudaica` when installed and falls back to `runica`
  (it was hard-wired to `cudaica`, which needs an NVIDIA GPU).
- `binica` works with stock EEGLAB as well as the modified copy QuickLab used.
- `pop_par_iclabel` honours the requested network version.
- The CorrMap templates folder is stored as a MATLAB preference.
- Viewprops+ draws topoplots in a normal loop: plots drawn on parallel workers
  never reached the screen.
- The Data Scroll Pro opens when EEGLAB was started with `eeglab nogui`.
- Removed `pop_viewprops_adv_ax.m` (an unused copy of `pop_viewprops_adv.m`).

### Added
- MATLAB test suite (`tests/`) and GitHub Actions CI with real MATLAB and EEGLAB.
- `benchmarks/benchmark_quicklab.m`: times QuickLab against EEGLAB on the same
  data and checks the outputs match.

## 0.91 (2024)
Code reorganised into `gui/`, `processing/`, `visualization/`, `utils/` (April 2026).
Earlier history: see the git log.
