function [EEG,com] = quick_highpass(EEG, freq)
% quick_highpass() - High-pass filter without a dialog (EEGLAB's pop_eegfiltnew).
%
% Usage:
%   >> EEG = quick_highpass(EEG, 1);   % keep activity above 1 Hz
%
% Author: Ugo Bruzadin Nunes

if nargin < 2 || isempty(freq)
    error('quick_highpass: give a cutoff frequency in Hz.');
end
[EEG,com] = pop_eegfiltnew(EEG, 'locutoff', freq);
EEG = eegh(com, EEG);
end
