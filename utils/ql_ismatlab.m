function tf = ql_ismatlab()
% ql_ismatlab() - Returns true if running in MATLAB, false for Octave.
tf = ~ql_isoctave();
