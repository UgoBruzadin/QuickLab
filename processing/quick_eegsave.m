function EEG = quick_eegsave(EEG, suffix)
% quick_eegsave() - Save EEG dataset with an optional suffix.
%
% Usage:
%   EEG = quick_eegsave(EEG)
%   EEG = quick_eegsave(EEG, 'ICA')
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

if nargin < 2
    suffix = '';
end

[~, fname, ~] = fileparts(EEG.filename);
if ~isempty(suffix)
    newname = [fname suffix '.set'];
else
    newname = EEG.filename;
end

EEG = pop_saveset(EEG, 'filename', newname, 'filepath', EEG.filepath);
fprintf('Saved: %s\n', newname);
