function [EEG,com] = quick_bss(EEG)
% quick_bss() - EMG removal with BSS-CCA over two-epoch windows (see quick_bss2).
%
% Usage:
%   >> EEG = quick_bss(EEG);
%
% Epoched data: windows of two epochs. Continuous data: windows of two
% EPOCHLENGTH-second chunks (QuickLabDefs, 1 s by default).
%
% Author: Ugo Bruzadin Nunes

QuickLabDefs;
if EEG.trials > 1
    window = 2 * EEG.pnts / EEG.srate;
else
    window = 2 * EPOCHLENGTH;
end
[EEG,com] = quick_bss2(EEG, window);
end
