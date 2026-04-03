function tf = ql_contains(str, pattern)
% ql_contains() - Cross-compatible contains() for MATLAB and Octave.
%   Works in all MATLAB versions and Octave versions (even without contains).
if iscell(str)
    tf = cellfun(@(s) ~isempty(strfind(s, pattern)), str);
else
    tf = ~isempty(strfind(str, pattern));
end
