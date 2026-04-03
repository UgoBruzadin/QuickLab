function EEG = quick_lowpass(EEG, freq)
% quick_lowpass() - Quick filter wrapper using EEGLAB's pop_eegfiltnew.
%   Called from QuickLab filter menu for both high-pass and low-pass.
%   The menu label determines the filter type based on frequency:
%     freq <= 22: high-pass filter at freq Hz
%     freq >= 14: low-pass filter at freq Hz
%
% Usage:
%   EEG = quick_lowpass(EEG, freq)
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

QuickLabDefs;

if nargin < 2
    error('quick_lowpass requires a frequency argument.');
end

if freq <= 22
    % High-pass filter
    EEG = pop_eegfiltnew(EEG, 'locutoff', freq);
    fprintf('Applied high-pass filter at %g Hz\n', freq);
else
    % Low-pass filter
    EEG = pop_eegfiltnew(EEG, 'hicutoff', freq);
    fprintf('Applied low-pass filter at %g Hz\n', freq);
end
