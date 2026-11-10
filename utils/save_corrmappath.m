function corrmappath = save_corrmappath(ask)
% save_corrmappath() - Get or set the folder that holds QuickLab's CorrMap templates.
%
% Usage:
%   >> corrmappath = save_corrmappath();       % ask for a folder and remember it
%   >> corrmappath = save_corrmappath(false);  % reuse the saved folder; ask only if none
%
% The folder is stored as a MATLAB preference (getpref('QuickLab','corrmapPath')), so it
% survives restarts and does not depend on the current folder. A corrmappath.txt left
% in the plugin folder by older QuickLab versions is picked up once and migrated.
%
% Author: Ugo Bruzadin Nunes, June 2021

if nargin < 1
    ask = true;
end

corrmappath = '';
if ispref('QuickLab', 'corrmapPath')
    corrmappath = getpref('QuickLab', 'corrmapPath');
else
    legacy = fullfile(fileparts(which('eegplugin_QuickLab')), 'corrmappath.txt');
    if isfile(legacy)
        corrmappath = strtrim(fileread(legacy));
        corrmappath = strrep(corrmappath, ',', ''); % writematrix stored chars comma-separated
    end
end

if ask || isempty(corrmappath) || ~isfolder(corrmappath)
    picked = uigetdir(corrmappath, 'Folder for QuickLab CorrMap templates');
    if isequal(picked, 0) % cancelled: keep whatever was saved before
        if ~isfolder(corrmappath), corrmappath = ''; end
        return;
    end
    corrmappath = picked;
end

setpref('QuickLab', 'corrmapPath', corrmappath);
fprintf('QuickLab: CorrMap templates folder is %s\n', corrmappath);
end
