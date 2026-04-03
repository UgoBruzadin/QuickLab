function tf = ql_hastabs()
% ql_hastabs() - Check if uitabgroup/uitab are available.
%   Returns true in MATLAB R2014b+ and Octave 7.1+.
%   Returns false in older Octave where tabs are not supported.
persistent has_tabs;
if isempty(has_tabs)
    try
        % Try creating an invisible test tab group
        tmpfig = figure('Visible', 'off');
        tg = uitabgroup('Parent', tmpfig);
        t = uitab('Parent', tg, 'Title', 'test');
        delete(tmpfig);
        has_tabs = true;
    catch
        try delete(tmpfig); catch; end
        has_tabs = false;
    end
end
tf = has_tabs;
