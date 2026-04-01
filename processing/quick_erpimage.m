function axhndls = quick_erpimage(EEG,chanorcomp)

erp_opt = {};
typecomp = 2;

%if ~typecomp
    if ~isempty(EEG.icaact)
        if ndims(EEG.icaact) ~= ndims(EEG.data)
           EEG.icaact = reshape(EEG.icaact,size(EEG.icaact,1),EEG.pnts,[]);
        end
        icaacttmp = EEG.icaact(chanorcomp, :, :);
    else
        icaacttmp  = eeg_getdatact(EEG, 'component', chanorcomp);
    end
%end

%try
%herp = axes('Parent', fh, 'position',[0.0643 0.1102 0.2421 0.3850],'units','normalized','Color',DEFAULT_AXIS_COLOR,'YColor',DEFAULT_AXIS_COLOR,'XColor',DEFAULT_AXIS_COLOR);
eeglab_options;
if EEG.trials > 1 % epoched data

    %axis(ax1, 'off')

    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
%     if EEG.trials < 6
%         ei_smooth = 1;
%     else
         ei_smooth = 1;
%     end

    if typecomp == 1 % plot channel
         offset = nan_mean(EEG.data(chanorcomp,:));
         erp=nan_mean(squeeze(EEG.data(chanorcomp,:,:))')-offset;
         erp_limits=get_era_limits(erp);
         [t1,t2,t3,t4,axhndls] = erpimage_ql( EEG.data(chanorcomp,:)-offset, ones(1,EEG.trials)*10000, EEG.times*1000, ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar', 'off','erp','erp_vltg_ticks',erp_limits, erp_opt{:});   
    else % plot component
         offset     = nan_mean(icaacttmp(:));
         era        = nan_mean(squeeze(icaacttmp)')-offset;
         era_limits = get_era_limits(era);
         [t1,t2,t3,t4,axhndls] = erpimage_ql( icaacttmp-offset, ones(1,EEG.trials)*10000, EEG.times*1000, ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar', 'off','erp','erp_vltg_ticks',era_limits, erp_opt{:});   
    end
    %axhndls{1}.XColor = DEFAULT_AXIS_COLOR;axhndls{2}.XColor = DEFAULT_AXIS_COLOR;axhndls{3}.XColor = DEFAULT_AXIS_COLOR;
    %axhndls{1}.YColor = DEFAULT_AXIS_COLOR;axhndls{2}.YColor = DEFAULT_AXIS_COLOR;axhndls{3}.YColor = DEFAULT_AXIS_COLOR;
    %title(['Epoched IC' int2str(chanorcomp) ' Activity'], 'fontsize', 14, 'FontWeight', 'Normal','Color',DEFAULT_FONT_COLOR);
    %lab = text(1.27, .95,'RMS uV per scalp channel','Color',DEFAULT_FONT_COLOR);
    
else % continuoous data
    ERPIMAGELINES = 200; % show 200-line erpimage
    while size(EEG.data,2) < ERPIMAGELINES*EEG.srate
        ERPIMAGELINES = 0.9 * ERPIMAGELINES;
    end
    ERPIMAGELINES = round(ERPIMAGELINES);
    if ERPIMAGELINES > 2   % give up if data too small
        if ERPIMAGELINES < 6
            ei_smooth = 1;
        else
            ei_smooth = 3;
        end
            
        erpimageframes = floor(size(EEG.data,2)/ERPIMAGELINES);
        erpimageframestot = erpimageframes*ERPIMAGELINES;
        eegtimes = linspace(0, erpimageframes-1, length(erpimageframes));
        if typecomp == 1 % plot channel
            offset = nan_mean(EEG.data(chanorcomp,:));
            % Note: we don't need to worry about ERP limits, since ERPs
            % aren't visualized for continuous data
            [t1,t2,t3,t4,axhndls] = erpimage_ql( reshape(EEG.data(chanorcomp,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                '', ei_smooth, 1, 'caxis', 2/3, 'cbar', 'off', erp_opt{:});
        else % plot component
            offset = nan_mean(icaacttmp(:));
            [t1,t2,t3,t4,axhndls] = erpimage_ql(reshape(icaacttmp(:,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset,ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                '', ei_smooth, 1, 'caxis', 2/3, 'cbar', 'off', erp_opt{:});
        end
        
%         try 
%             ylabel(axhndls{1}, 'Data','Color',DEFAULT_FONT_COLOR);
%         catch
%             ylabel(axhndls(1), 'Data','Color',DEFAULT_FONT_COLOR);
%         end
        axhndls{1}.XColor = DEFAULT_AXIS_COLOR;axhndls{2}.XColor = DEFAULT_AXIS_COLOR;axhndls{3}.XColor = DEFAULT_AXIS_COLOR;
        axhndls{1}.yColor = DEFAULT_AXIS_COLOR;axhndls{2}.YColor = DEFAULT_AXIS_COLOR;axhndls{3}.YColor = DEFAULT_AXIS_COLOR;
        %title('Continuous Data', 'fontsize', 14, 'FontWeight', 'Normal','Color',DEFAULT_FONT_COLOR);
        %lab = text(1.27, .85,'RMS uV per scalp channel','Color',DEFAULT_FONT_COLOR);
    else
        axis off;
        text(0.1, 0.3, [ 'No erpimage plotted' 10 'for small continuous data'],'Color',DEFAULT_FONT_COLOR);
    end
end
%catch
%end



function era_limits=get_era_limits(era)
%function era_limits=get_era_limits(era)
%
% Returns the minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)
%
% Inputs:
% era - [vector] Event related activation or potential
%
% Output:
% era_limits - [min max] minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)

mn=min(era);
mx=max(era);
mn=orderofmag(mn)*round(mn/orderofmag(mn));
mx=orderofmag(mx)*round(mx/orderofmag(mx));
era_limits=[mn mx];


function ord=orderofmag(val)
%function ord=orderofmag(val)
%
% Returns the order of magnitude of the value of 'val' in multiples of 10
% (e.g., 10^-1, 10^0, 10^1, 10^2, etc ...)
% used for computing erpimage trial axis tick labels as an alternative for
% plotting sorting variable

val=abs(val);
if val>=1
    ord=1;
    val=floor(val/10);
    while val>=1,
        ord=ord*10;
        val=floor(val/10);
    end
    return;
else
    ord=1/10;
    val=val*10;
    while val<1,
        ord=ord/10;
        val=val*10;
    end
    return;
end

% inputdlg3() - A comprehensive gui automatic builder. This function takes
%               text, type of GUI and default value and builds
%               automatically a simple graphic interface.
%
% Usage:
%   >> [outparam outstruct] = inputdlg3( 'key1', 'val1', 'key2', 'val2', ... );
% 
% Inputs:
%   'prompt'     - cell array of text
%   'style'      - cell array of style for each GUI. Default is edit.
%   'default'    - cell array of default values. Default is empty.
%   'tags'       - cell array of tag text. Default is no tags.
%   'tooltip'    - cell array of tooltip texts. Default is no tooltip.
%
% Output:
%   outparam   - list of outputs. The function scans all lines and
%                add up an output for each interactive uicontrol, i.e
%                edit box, radio button, checkbox and listbox.
%   userdat    - 'userdata' value of the figure.
%   strhalt    - the function returns when the 'userdata' field of the
%                button with the tag 'ok' is modified. This returns the
%                new value of this field.
%   outstruct  - returns outputs as a structure (only tagged ui controls
%                are considered). The field name of the structure is
%                the tag of the ui and contain the ui value or string.
%
% Note: the function also adds three buttons at the bottom of each 
%       interactive windows: 'CANCEL', 'HELP' (if callback command
%       is provided) and 'OK'.
%
% Example:
%   res = inputdlg3('prompt', { 'What is your name' 'What is your age' } );
%   res = inputdlg3('prompt', { 'Chose a value below' 'Value1|value2|value3' ...
%                   'uncheck the box' }, ...
%                   'style',  { 'text' 'popupmenu' 'checkbox' }, ...
%                   'default',{ 0 2 1 });
%
% Author: Arnaud Delorme, Tim Mullen, Christian Kothe, SCCN, INC, UCSD
%
% See also: supergui(), eeglab()

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, 2010, arno@ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [result, userdat, strhalt, resstruct] = inputdlg3( varargin);

if nargin < 2
   help inputdlg3;
   return;
end;	

% check input values
% ------------------
[opt addopts] = finputcheck(varargin, { 'prompt'  'cell'  []   {};
                                        'style'   'cell'  []   {};
                                        'default' 'cell'  []   {};
                                        'tag'     'cell'  []   {};
                                        'tooltip','cell'  []   {}}, 'inputdlg3', 'ignore');
if isempty(opt.prompt),  error('The ''prompt'' parameter must be non empty'); end;
if isempty(opt.style),   opt.style = cell(1,length(opt.prompt)); opt.style(:) = {'edit'}; end;
if isempty(opt.default), opt.default = cell(1,length(opt.prompt)); opt.default(:) = {0}; end;
if isempty(opt.tag),     opt.tag = cell(1,length(opt.prompt)); opt.tag(:) = {''}; end;

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
    end;
    if strcmpi(opt.style{index}, 'text')
        outputind(index) = 0;
    end;
end;

[tmpresult, userdat, strhalt, resstruct] = inputgui('uilist', uilist,'geometry', uigeometry, addopts{:});
try
    result = cell(1,length(opt.prompt));
    result(find(outputind)) = tmpresult;
catch
    result = [];
end