function [EEG,com] = quick_bss(EEG)
% quick_bss() - Quick BSS using 2-epoch window length
%   Thin wrapper around quick_bss2 with a 2-epoch window.
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

window = (EEG.pnts / EEG.srate) * 2;
[EEG, com] = quick_bss2(EEG, window);
