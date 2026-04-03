function tf = ql_vercheck(product, version_str)
% ql_vercheck() - Cross-compatible version check (replaces verLessThan).
%   Returns true if the current MATLAB version is less than version_str.
%   Always returns false in Octave (Octave uses modern conventions).
%
% Usage:
%   tf = ql_vercheck('matlab', '9.0.0')  % true if MATLAB < R2016a

if ql_isoctave()
    tf = false;  % Octave doesn't need MATLAB version workarounds
    return;
end

try
    tf = verLessThan(product, version_str);
catch
    tf = false;
end
