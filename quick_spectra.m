% [com] = quick_spectra(EEG, high, low, reference) - Quickly plots channel
%                                                    frequency spectra
%
% Author: Ugo Bruzadin Nunes
%
% Copyright (C) 2021 Ugo Bruzadin Nunes
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


function [EEG,com,fig] = quick_spectra(EEG,high,low,references,topo,visible)

com = '';

if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    [EEG,com] = eeg_store(EEG);
end

% collects defaults defined at QuickLabDefs

QuickLabDefs; % using SPECTRADEFS 1 for High Frequency filter, 2 for low frequency filter and 3 for maximum points for FFT display
              % also using SPECTRATOPO for defaulty defined frequencies to display
%% collecting defaults or given variables

if nargin < 6 || isempty(visible)
    visible = 'on';
end

if nargin < 5
   topo = SPECTRATOPO; % SPECTRATOPO DEFINED INSIDE QuickLabDefs 
end

if nargin > 3
    [EEG,com] = quick_reref(EEG,references);
end

if nargin < 3 
    %low = 2;
    low = FREQDISPLAYDEFS(2); % SPECTRADEFS DEFINED INSIDE QuickLabDefs 
end

if nargin < 2
    %high = 55;
    high = FREQDISPLAYDEFS(1); % SPECTRADEFS DEFINED INSIDE QuickLabDefs 
end
maxWindow = 2^floor(log2(EEG.pnts));
if maxWindow > FREQDISPLAYDEFS(3)
    %maxWindow = 2048;
    maxWindow = FREQDISPLAYDEFS(3);
end
 
% numberOfHeadmaps = 10;
% 
% calc = (high - low) / numberOfHeadmaps;
% topo = zeros(1,numberOfHeadmaps);
% 
% for i=1:numberOfHeadmaps
%     topo(i) = floor(low + i*calc);
% end

%topo = [4 5 6 7 8 9 10 11 12 15 20 25 30 36];

%% runs pop_spectopo with the given defaults or variables

%tic
fig = figure('Visible',visible); pop_spectopo_ql(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [topo], 'freqrange',[low high],'winsize',maxWindow,'electrodes','off');
%toc
savecommand = ['saveas(gcf,[EEG.filename(1:end-4),''FFT.jpg'']);'];

save = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'save', 'Position', [.91 .08 .09 .05],'String','Save Figure','Callback',savecommand);




% set(gcf, 'windowbuttondownfcn',   {@mouse_down,figh});
% set(gcf, 'windowbuttonupfcn',     {@mouse_up,figh});
% set(gcf, 'windowbuttonmotionfcn', {@mouse_motion,gcf});

EEG = eegh(com, EEG);


end
% 
% % 
% function mouse_motion(gcf)
% fig = gcf
% g = get(fig,'UserData');
% % 
% % tmppos = get(ax0, 'currentpoint');
% % 
% % figh = gcf;
% % 
%  fprintf('MOVEMENT CAPTURED')
% % 
% % set(findobj('Tag','title'),'String','HELLO THERE')
% 
% end