# QuickLab

[![tests](https://github.com/UgoBruzadin/QuickLab/actions/workflows/tests.yml/badge.svg)](https://github.com/UgoBruzadin/QuickLab/actions/workflows/tests.yml)
![MATLAB](https://img.shields.io/badge/MATLAB-R2024b-orange)
![EEGLAB](https://img.shields.io/badge/EEGLAB-2025.1-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-lightgrey)

**An EEGLAB plugin for cleaning EEG by hand, quickly.** QuickLab replaces EEGLAB's
data scroll with the **Data Scroll Pro**: one window where you mark epochs to reject,
mark channels or ICA components to interpolate in just the epochs where they are bad,
run ICA, ICLabel, DIPFIT and trial-by-trial detection, and save, without leaving the
scroll or answering dialog boxes. Listed in the official EEGLAB plugin repository.

![Data Scroll Pro: two epochs (green) with channels interpolated only in those epochs, one epoch (red) rejected for a blink](https://github.com/UgoBruzadin/QuickLab/assets/25592470/3580f188-1f37-42ba-952c-fe187d63b558)

*Green epochs: channels interpolated only inside that epoch. Red epoch: rejected (blink).*

## Why

EEGLAB can do almost everything, but manual cleaning means many small dialogs,
one dataset and one step at a time. For small studies with few channels and few
trials, where every epoch has to be inspected, that is most of the work. QuickLab
was built in the INL lab (Carbondale, IL) to make that pass fast, and to teach
students what clean and dirty data look like.

## What it does

| | |
|---|---|
| **Data Scroll Pro** | Scroll channels or components; left-click an epoch to reject (red) or interpolate (green); right-click a channel to interpolate it everywhere or only in the green epochs. Works on ICA components too: remove a component only where it spikes, which keeps the data rank. A matrix view shows every mark. |
| **Trial-by-trial detection** | Threshold, trend, joint probability, kurtosis, spectrum, max-min and flat-line detectors mark bad channel-epochs; channels bad in more than X% of epochs are interpolated everywhere, epochs with more than N bad channels are rejected. |
| **No-prompt processing** | ICA/PCA (`runica`, `binica` or `cudaica`), ICLabel, filtering, re-referencing, epoching, BSS-CCA muscle removal, all from menus with defaults set once in `QuickLabDefs.m`. |
| **Parallel DIPFIT and BSS** | `pop_par_multifit2` fits components in parallel; `par_autobss` cleans BSS windows in parallel. Both give the same output as the EEGLAB/AAR originals (tested). |
| **Viewprops+ and Spectopo_ql** | Every component on one page with ICLabel, click a map to flag it; spectra with a scalp map at any clicked frequency. |
| **Quick CorrMap** | Save components you flagged as templates, then flag matching components in new files. |

Full walkthrough of every button and key: [docs/feature-guide.md](docs/feature-guide.md).

## Install

1. Install [EEGLAB](https://sccn.ucsd.edu/eeglab/) (tested with 2025.1 on MATLAB R2024b).
2. Download this repository into `eeglab/plugins/QuickLab` (or use EEGLAB's plugin manager).
3. Start EEGLAB. A **QuickLab** menu appears, and **Plot > Data Scroll Pro**.

Optional: Parallel Computing Toolbox (parallel DIPFIT/BSS), the AAR plugin (BSS),
CUDAICA and an NVIDIA GPU (fast ICA). Signal Processing Toolbox is needed by ICLabel.

## Quick start

```matlab
eeglab
EEG = pop_loadset('eeglab_data_epochs_ica.set', fullfile(fileparts(which('eeglab')), 'sample_data'));
[EEG, com] = pop_eegplot_adv(EEG, 1, 2, 1, 1);   % Data Scroll Pro on channels (2 = components)
```

Scripted, without the GUI:

```matlab
EEG = quick_highpass(EEG, 1);           % filter without a dialog
EEG = quick_PCA(EEG);                   % ICA + ICLabel with QuickLabDefs settings
EEG = pop_par_icflag(EEG, [NaN NaN; 0.8 1; 0.8 1; NaN NaN; NaN NaN; NaN NaN; NaN NaN]);
EEG = quick_dipfit(EEG);                % parallel DIPFIT
```

## Tests

`tests/test_quicklab.m` runs on EEGLAB's sample data with real MATLAB in
[GitHub Actions](.github/workflows/tests.yml) on every push. Where QuickLab replaces
an EEGLAB function, the test checks it returns the same result:

- parallel DIPFIT vs `pop_multifit`, parallel BSS vs AAR `autobss`, ICLabel vs `iclabel`
- partial channel/component interpolation and epoch rejection vs `pop_interp`, `pop_subcomp`
- every menu item points at a function that exists

```matlab
results = runtests('tests'); table(results)
```

## Benchmarks

`benchmarks/benchmark_quicklab.m` times each parallel function against the EEGLAB
function it replaces on the same data (warm-up run, alternating order, median) and
checks the outputs match. Results: [benchmarks/results.md](benchmarks/results.md).

## Repository layout

```
eegplugin_QuickLab.m   menus
QuickLabDefs.m         defaults (edit from the QuickLab menu)
gui/                   pop_* dialogs and parallel wrappers
processing/            quick_* one-step functions, parallel BSS and ICLabel
visualization/         Data Scroll Pro (eegplot_adv), rejection/interpolation, plots
utils/                 helpers
tests/  benchmarks/  docs/
```

## History

Written by Ugo Bruzadin Nunes (2020-2024) during dissertation work in the INL lab, Carbondale, IL.
Version 1.0 (2026) is a review-and-test release: several long-standing bugs were found
and fixed, including parallel BSS returning a flat signal and parallel DIPFIT failing
silently outside the original lab machine. See [CHANGELOG.md](CHANGELOG.md).

## License

GPL-3.0. QuickLab builds on and modifies EEGLAB functions (eegplot, pop_viewprops,
spectopo, erpimage, pop_multifit, ICLabel's feature extractor) and the AAR plugin,
which keep their original authors' copyright notices.
