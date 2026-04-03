function tf = ql_isoctave()
% ql_isoctave() - Returns true if running in GNU Octave, false for MATLAB.
%   Uses persistent variable for speed (called hundreds of times).
persistent is_octave;
if isempty(is_octave)
    is_octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end
tf = is_octave;
