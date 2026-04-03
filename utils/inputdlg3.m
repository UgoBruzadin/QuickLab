function [result, userdat, strhalt, resstruct] = inputdlg3( varargin)
% inputdlg3 - Custom input dialog for QuickLab/EEGLAB GUI functions.
%   Extracted from multiple files to avoid duplication.

if nargin < 2
   help inputdlg3;
   return;
end

% check input values
% ------------------
[opt addopts] = finputcheck(varargin, { 'prompt'  'cell'  []   {};
                                        'style'   'cell'  []   {};
                                        'default' 'cell'  []   {};
                                        'tag'     'cell'  []   {};
                                        'tooltip','cell'  []   {}}, 'inputdlg3', 'ignore');
if isempty(opt.prompt),  error('The ''prompt'' parameter must be non empty'); end
if isempty(opt.style),   opt.style = cell(1,length(opt.prompt)); opt.style(:) = {'edit'}; end
if isempty(opt.default), opt.default = cell(1,length(opt.prompt)); opt.default(:) = {0}; end
if isempty(opt.tag),     opt.tag = cell(1,length(opt.prompt)); opt.tag(:) = {''}; end

% creating GUI list input
% -----------------------
uilist = {};
uigeometry = {};
outputind  = ones(1,length(opt.prompt));
for index = 1:length(opt.prompt)
    if strcmpi(opt.style{index}, 'edit')
        uilist{end+1} = { 'style' 'text' 'string' opt.prompt{index} };
        uilist{end+1} = { 'style' 'edit' 'string' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [2 1];
    else
        uilist{end+1} = { 'style' opt.style{index} 'string' opt.prompt{index} 'value' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [1];
    end
    if strcmpi(opt.style{index}, 'text')
        outputind(index) = 0;
    end
end

w = warning('off', 'MATLAB:namelengthmaxexceeded');
[tmpresult, userdat, strhalt, resstruct] = inputgui('uilist', uilist,'geometry', uigeometry, addopts{:});
warning(w.state, 'MATLAB:namelengthmaxexceeded')
result = cell(1,length(opt.prompt));
result(find(outputind)) = tmpresult;
