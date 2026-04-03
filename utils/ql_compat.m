function ql_compat()
% ql_compat() - Set up Octave/MATLAB compatibility for QuickLab.
%   Call once at startup (from eegplugin_QuickLab or QuickLabDefs).
%   Defines global compatibility flags and shim functions.
%
% Detects environment and provides:
%   ql_isoctave()  - true if running in GNU Octave
%   ql_ismatlab()  - true if running in MATLAB
%   ql_contains()  - contains() shim for older Octave
%   ql_replace()   - replace/strrep shim
%   ql_vercheck()  - version check without verLessThan
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

% This function just needs to exist on the path so the individual
% utility functions below can be found. Call it to verify setup.
if ql_isoctave()
    fprintf('QuickLab: Running in GNU Octave %s\n', version());

    % Octave-specific setup
    if ~exist('OCTAVE_VERSION', 'builtin')
        warning('QuickLab:compat', 'Could not confirm Octave version');
    end

    % Ensure required Octave packages are loaded
    try pkg('load', 'signal'); catch; end
    try pkg('load', 'statistics'); catch; end
    try pkg('load', 'io'); catch; end
else
    fprintf('QuickLab: Running in MATLAB %s\n', version());
end
