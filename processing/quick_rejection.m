function EEG = quick_rejection(EEG)
% quick_rejection() - Automatic continuous data rejection.
%   Uses EEGLAB's pop_rejcont to automatically reject noisy segments.
%
% Usage:
%   EEG = quick_rejection(EEG)
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

QuickLabDefs;

fprintf('Running automatic rejection...\n');
EEG = pop_rejcont(EEG, 'elecrange', 1:EEG.nbchan, ...
    'freqlimit', [20 40], 'threshold', 10, 'epochlength', 0.5, ...
    'contiguous', 1, 'addlength', 0.25, 'taper', 'hamming');
fprintf('Automatic rejection complete.\n');
