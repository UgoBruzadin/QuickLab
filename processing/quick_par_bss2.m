function [EEG,com] = quick_par_bss2(EEG)
% quick_par_bss2() - Parallel BSS full file processing.
%   Currently delegates to quick_bss2 (parallel support planned).
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

fprintf('Running BSS (parallel mode not yet implemented, using standard)...\n');
[EEG, com] = quick_bss2(EEG);
