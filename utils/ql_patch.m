function h = ql_patch(varargin)
% ql_patch() - Cross-compatible patch() that handles the parent-axes argument.
%   In MATLAB R2016a+, patch(ax, ...) works. In older MATLAB and Octave,
%   the axes must be set current first.
%
% Usage:
%   h = ql_patch(ax, xdata, ydata, color, ...)  % preferred
%   h = ql_patch(xdata, ydata, color, ...)       % fallback (uses gca)

if nargin >= 1 && ishandle(varargin{1}) && ~isnumeric(varargin{1})
    % First arg is an axes handle
    ax = varargin{1};
    args = varargin(2:end);
    try
        h = patch(ax, args{:});
    catch
        % Fallback: set axes current, then patch without axes arg
        axes(ax);
        h = patch(args{:});
    end
else
    h = patch(varargin{:});
end
