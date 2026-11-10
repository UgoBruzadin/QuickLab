function [EEG,com] = quick_lowpass(EEG, freq)
% quick_lowpass() - Low-pass filter without a dialog (EEGLAB's pop_eegfiltnew).
%
% Usage:
%   >> EEG = quick_lowpass(EEG, 40);   % keep activity below 40 Hz
%
% Author: Ugo Bruzadin Nunes

if nargin < 2 || isempty(freq)
    error('quick_lowpass: give a cutoff frequency in Hz.');
end
[EEG,com] = pop_eegfiltnew(EEG, 'hicutoff', freq);
EEG = eegh(com, EEG);
end
