% pop_eegplot_adv() - Visually inspect EEG data using a scrolling display.
%                 Perform rejection or marking for rejection of visually 
%                 (and/or previously) selected data portions (i.e., stretches 
%                 of continuous data or whole data epochs).
%    Almost identical to pop_eegplot(), but allow scroll with mouse wheel, 
%    to remove channels / components, looks better in wide-screen monitor.
%
% Usage:
%   >> pop_eegplot_w( EEG ) % Scroll EEG channel data. Allow marking for rejection via
%                         % button 'Update Marks' but perform no actual data rejection.
%                         % Do not show or use marks from previous visual inspections
%                         % or from semi-auotmatic rejection.
%   >> pop_eegplot_w( EEG, icacomp, superpose, reject );
%
% Graphic interface:
%   "Add to previously marked rejections" - [edit box] Either YES or NO. 
%                    Command line equivalent: 'superpose'.
%   "Reject marked trials" - [edit box] Either YES or NO. Command line
%                    equivalent 'reject'.
% Inputs:
%   EEG        - input EEG dataset
%   plotchannelss - 0 = independent components;
%              - 1 = data channels. {Default: 1 = data channels}
%   superpose  - 0 = Show new marks only: Do not color the background of data portions 
%                    previously marked for rejection by visual inspection. Mark new data 
%                    portions for rejection by first coloring them (by dragging the left 
%                    mouse button), finally pressing the 'Update Marks' or 'Reject' 
%                    buttons (see 'reject' below). Previous markings from visual inspection 
%                    will be lost.
%                1 = Show data portions previously marked by visual inspection plus 
%                    data portions selected in this window for rejection (by dragging 
%                    the left mouse button in this window). These are differentiated 
%                    using a lighter and darker hue, respectively). Pressing the 
%                    'Update Marks' or 'Reject' buttons (see 'reject' below)
%                    will then mark or reject all the colored data portions.
%                {Default: 0, show and act on new marks only}
%   reject     - 0 = Mark for rejection. Mark data portions by dragging the left mouse 
%                    button on the data windows (producing a background coloring indicating 
%                    the extent of the marked data portion).  Then press the screen button 
%                    'Update Marks' to store the data portions marked for rejection 
%                    (stretches of continuous data or whole data epochs). No 'Reject' button 
%                    is present, so data marked for rejection cannot be actually rejected 
%                    from this eegplot_w() window. 
%                1 = Reject marked trials. After inspecting/selecting data portions for
%                    rejection, press button 'Reject' to reject (remove) them from the EEG 
%                    dataset (i.e., those portions plottted on a colored background. 
%                    {default: 1, mark for rejection only}
% NEEDS FIXING
%   isEpoched  - 1 = epoched;????
%              - 2 = data channels. {Default: 1 = epoched if possible)
%  topcommand   -  Input deprecated.  Kept for compatibility with other function calls
% Outputs:
%   Modifications are applied to the current EEG dataset at the end of the
%   eegplot_w() call, when the user presses the 'Update Marks' or 'Reject' button.
%   NOTE: The modifications made are not saved into EEGLAB history. As of v4.2,
%   events contained in rejected data portions are remembered in the EEG.urevent
%   structure (see EEGLAB tutorial).
%
% Original author: Arnaud Delorme, CNL / Salk Institute, 2001-2002
% Modified by: Mindaugas Baranauskas, 2017
% Modified by: Ugo Bruzadin Nunes, 2021
% 
% See also: eeglab(), eegplot_w(), eegplot(), pop_eegplot(), pop_rejepoch()

% Copyright (C) 2001-2002 Arnaud Delorme, Salk Institute, arno@salk.edu
% Copyright (C) 2017 Mindaugas Baranauskas
% Copyright (C) 2021 Ugo Bruzadin Nunes
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

% 2002-01-25 reformated help & license -ad 
% 2002-03-07 added srate argument to eegplot_w call -ad
% 2002-03-27 added event latency recalculation for continuous data -ad
% 2017-01-24 allow select channels/components for rejection -mb
% 2021-11-14 altered for channel/component interpolation -ubn

function [EEG,com] = pop_eegplot_adv( EEG, plotchannels, superpose, reject, isEpoched, topcommand, varargin)

%% ---  setting defaults
%com = '';
if ~exist('topcommand','var')
    topcommand = [];
end
if nargin < 1
	help pop_eegplot_w;
	return;
end
if nargin < 2
	plotchannels = 1;
end
if nargin < 3
	superpose = 0;
end
if nargin < 4
	reject = 1;
end
if plotchannels ~= 1
	if isempty( EEG.icasphere )
		disp('Error: you must run ICA first'); return;
    end
end

%% --- get UI help, deprecated but left behind just in case
if nargin < 3 && EEG.trials > 1

	% which set to save
	% -----------------
    uilist       = { { 'style' 'text' 'string' 'Add to previously marked rejections? (checked=yes)'} , ...
         	         { 'style' 'checkbox' 'string' '' 'value' 1 } , ...
                     { 'style' 'text' 'string' 'Reject marked trials? (checked=yes)'} , ...
         	         { 'style' 'checkbox' 'string' '' 'value' 0 } };
    result = inputgui( { [ 2 0.2] [ 2 0.2]} , uilist, 'pophelp(''pop_eegplot_w'');', ...
                       fastif(plotchannels==0, 'Manual component rejection -- pop_eegplot_w()', ...
								'Reject epochs by visual inspection -- pop_eegplot_w()'));
	size_result  = size( result );
	if size_result(1) == 0 return; end
   
   if result{1}, superpose=1; end
   if ~result{2}, reject=0; end

end

%% --- get data, if components or data
%if isComponents == 1
     elecrange = [1:EEG.nbchan];
%else 
     %comprange = [1:size(EEG.icaweights,1)];
%end

if ~isempty( EEG.icasphere )
    comprange = [1:size(EEG.icaweights,1)];
end

%% --- setting save & final editing command
if reject
%     com1 = ...
%         [  'EEGTMP=EEG; '...
%         'if ~isempty(TMPREJCHN); '];
%     %if isComponents == 1
%         com1_ch = [ com1 ...
%             'EEG.chanrej = TMPREJ;[EEGTMP LASTCOM1] = eeg_eegrej_adv(EEGTMP,TMPREJ,1,TMPREJCHN); ' ]; %modified for eegrej2
%     %else
%         com1_pc = [ com1 ...
%             'EEG.comprej = TMPREJ; [EEGTMP LASTCOM1] = eeg_eegrej_adv(EEGTMP,TMPREJ,2,TMPREJCHN); ' ]; %modified for eegrej2
%     %end
%     com1_pc = [ com1_pc ...
%          '  if ~isempty(LASTCOM1),' ...
%          '     EEGTMP = eegh(strrep(LASTCOM1,''EEGTMP'',''EEG''), EEGTMP); ' ...
%          '  end;' ...
%         'else LASTCOM1=''''; ' ...
%         'end; ' ];
%     com1_ch = [ com1_ch ...
%          '  if ~isempty(LASTCOM1),' ...
%          '     EEGTMP = eegh(strrep(LASTCOM1,''EEGTMP'',''EEG''), EEGTMP); ' ...
%          '  end;' ...
%         'else LASTCOM1=''''; ' ...
%         'end; ' ];
    %if isComponents == 1
        com3 = 'EEGTMP=EEG;EEG.chanrej = TMPREJ;[EEGTMP LASTCOM1] = eeg_eegrej_adv(EEGTMP,TMPREJ,1,TMPREJCHN); ' ; %modified for eegrej2
    %else
        com3_pc = 'EEGTMP=EEG;EEG.comprej = TMPREJ;[EEGTMP LASTCOM1] = eeg_eegrej_adv(EEGTMP,TMPREJ,2,TMPREJCHN); ' ; %modified for eegrej2
    %end

    % Created for Save & Close Command
    %if isComponents == 1
        com5 = 'LASTCOM1='''';EEG.chanrej = TMPREJ;EEG.mybadchan = TMPREJCHN;EEGTMP=EEG;' ; %modified for eegrej2 #Ugo 
    %else
        com5_pc = 'LASTCOM1='''';EEG.comprej = TMPREJ;EEG.mybadcomp = TMPREJCHN;EEGTMP=EEG;' ; %modified for eegrej2#Ugo 
    %end
    
    com4 = [ ...
        'if ~isempty(LASTCOM1),' ...
        '     EEGTMP = eegh(strrep(LASTCOM1,''EEGTMP'',''EEG''), EEGTMP);' ...
        'end;' ...
        'if ~isempty(LASTCOM1)' ... 'if or(~isempty(LASTCOM1),~isempty(LASTCOM1))' ... 
        '  EEG = EEGTMP;'...%CHANGE TO CHANGE SAVED DATA%'  [ALLEEG EEG CURRENTSET tmpcom] = pop_newset(ALLEEG, EEGTMP' newset_param ');' ... 
        ''...%'  if ~isempty(tmpcom),' ...
        ''...%'     eegh(tmpcom); ' ...
        ''...%'     eeglab(''redraw''); ' ...
        ''...%'  end; ' ...
        'end; ' ...
        'clear EEGTMP TMPREJ TMPREJCHN LASTCOM1;eeglab redraw;' ];
end

    eeglab_options; % changed from eeglaboptions 3/30/02 -sm
    if reject == 0, command = '';
    else
         command = [com5 com3 com4 ];
         savecommand = [com5 com4];

         command_pc = [com5_pc com3_pc com4 ];
         savecommand_pc = [com5_pc com4];

        if nargin < 4
            res = questdlg2( strvcat('Mark stretches of continuous data for rejection', ...
                                     'by dragging the left mouse button. Click on marked', ...
                                     'stretches to unmark. When done,press "REJECT" to', ...
                                     'excise marked stretches (Note: Leaves rejection', ...
                                     'boundary markers in the event table).'), 'Warning', 'Cancel', 'Continue', 'Continue');
            if strcmpi(res, 'Cancel'), return; end
        end
    end
    eegplotoptions = { 'events', EEG.event };
% end;

%if ~isempty(EEG.chanlocs) && isComponents == 1

%% chanlocs for eeg datascroll
if ~isempty(EEG.chanlocs)
    eegplotoptions = { eegplotoptions{:}  'eloc_file_ch', EEG.chanlocs(elecrange) };
end

%% chanlocs for ica datascroll
if ~isempty(EEG.icasphere)
    try
        gcompreject=EEG.reject.gcompreject;
    catch
        gcompreject=zeros(1,size(EEG.icaweights,1));
    end
    tmpcompstruct=struct('badchan',num2cell(gcompreject));
    for index = 1:length(comprange)
        tmpcompstruct(index).labels = int2str(comprange(index));
    end
    eegplotoptions = { eegplotoptions{:}  'eloc_file_pc' tmpcompstruct };
end


%% new addition: both channel and component file locations are stores in the file
if plotchannels == 1
    eegplotoptions = { eegplotoptions{:}  'eloc_file', EEG.chanlocs(elecrange) };
else
    eegplotoptions = { eegplotoptions{:}  'eloc_file' tmpcompstruct };
end

if EEG.nbchan > 100
    disp('pop_eegplot_adv() note: Baseline subtraction disabled to speed up display');
    eegplotoptions = { eegplotoptions{:} 'submean' 'off' };
end

EEG.plotEp = isEpoched;
EEG.plotchannels = plotchannels;

%% --- Editing the title of the figure
if isEpoched == 3
    title = ['Frequencies in '];
else
    if ~plotchannels
        title = ['Channels in '];
    else
        title = ['Components in '];
    end
end

%% --- run eegplot_adv!!
[EEG,com] = eegplot_adv( EEG, 'srate', EEG.srate, 'title', [ 'Advanced EEG Data Editor by Ugo Bruzadin Nunes -- eegplot_adv(): ' EEG.filename], ...
             'limits', [EEG.xmin EEG.xmax]*1000 , 'command', command,'savecommand',savecommand, 'command2', command_pc,'savecommand2',savecommand_pc, eegplotoptions{:}, varargin{:});

%[EEG,com] = pop_eegplot_adv( EEG, plotchannels, superpose, reject, isEpoched, topcommand, varargin)
com = [ com sprintf('pop_eegplot_adv( EEG, %s);', vararg2str({plotchannels, superpose, reject, isEpoched}))];
%return;
