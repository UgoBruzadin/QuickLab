function EEG = quick_eegsave(EEG, suffix)
% quick_eegsave() - Save the dataset next to the original, adding a suffix to its name.
%
% Usage:
%   >> EEG = quick_eegsave(EEG);          % overwrite EEG.filename
%   >> EEG = quick_eegsave(EEG, 'ICA');   % sub01.set -> sub01ICA.set
%
% Author: Ugo Bruzadin Nunes

if nargin < 2
    suffix = '';
end
if isempty(EEG.filename)
    error('quick_eegsave: dataset has no file name yet; save it once with pop_saveset.');
end
[~, fname] = fileparts(EEG.filename);
newname = [fname suffix '.set'];
EEG = pop_saveset(EEG, 'filename', newname, 'filepath', EEG.filepath);
fprintf('quick_eegsave: saved %s\n', fullfile(EEG.filepath, newname));
end
