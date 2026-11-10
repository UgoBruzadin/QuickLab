function [EEG,com] = quick_unepoch(EEG)
% quick_unepoch() - Undo quick_epoch: join regular epochs back into continuous data.
%
% Usage:
%   >> [EEG,com] = quick_unepoch(EEG);
%
% Meant for data cut with quick_epoch / eeg_regepochs, so the epochs are back to back
% in time. Removes the 'X' marker events eeg_regepochs adds and does not insert
% boundary events. For epochs cut around events, use EEGLAB's eeg_epoch2continuous.
%
% Author: Ugo Bruzadin Nunes
%
% Copyright (C) 2021 Ugo Bruzadin Nunes
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.

com = '';
if EEG.trials <= 1
    fprintf('quick_unepoch: nothing done, data are already continuous.\n');
    return;
end

if ~isempty(EEG.event) && any(strcmp(cellfun(@num2str, {EEG.event.type}, 'UniformOutput', false), 'X'))
    EEG = pop_selectevent(EEG, 'omittype', {'X'}, 'deleteevents', 'on', 'deleteepochs', 'off', 'invertepochs', 'off');
end

nTrials = EEG.trials;
EEG.data = reshape(EEG.data, size(EEG.data,1), []);
if ~isempty(EEG.icaact)
    EEG.icaact = reshape(EEG.icaact, size(EEG.icaact,1), []);
end
% Epoched event latencies are already counted from the start of the concatenated data.
if ~isempty(EEG.event) && isfield(EEG.event, 'epoch')
    EEG.event = rmfield(EEG.event, 'epoch');
end
EEG.epoch  = [];
EEG.urevent = EEG.event;
EEG.pnts   = size(EEG.data,2);
EEG.trials = 1;
EEG.xmin   = 0;
EEG.xmax   = (EEG.pnts-1)/EEG.srate;
EEG.times  = [];
EEG = eeg_checkset(EEG);

com = 'EEG = quick_unepoch(EEG);';
EEG = eegh(com, EEG);
fprintf('quick_unepoch: joined %d epochs into %.1f s of continuous data.\n', nTrials, EEG.xmax);
end
