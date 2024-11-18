function EEG = eegmaxmin_ica(EEG,compRange,timeRange,minmaxThresh,winSize,stepSize,maW)
% EEGMAXMIN_ICA - Apply a min-max threshold to ICA components over specified time windows
%
% Inputs:
%   EEG            - EEG structure containing the ICA data in EEG.icaact
%   compRange      - Range of ICA components to examine (default: all components)
%   timeRange      - Time range in ms to examine (default: entire EEG.times range)
%   minmaxThresh   - Threshold for min-max range (values beyond this threshold flag the trial)
%   winSize        - Size of the sliding window in ms (default: duration of timeRange)
%   stepSize       - Step size of sliding window in ms (default: winSize/10)
%   maW            - Moving average window in ms (optional, applied along time)

% Set defaults if inputs are empty
if isempty(compRange), compRange   = 1:size(EEG.icaact,1);             end
if isempty(timeRange), timeRange   = [EEG.xmin EEG.xmax]*1000;         end % in ms
if isempty(winSize),   winSize     = diff(timeRange);                  end % in ms
if isempty(stepSize),  stepSize    = ceil(winSize/10);                 end % in ms
if isempty(maW),       maW         = 0;                                end % in ms

% Prepare data
t_ind       = EEG.times >= timeRange(1) & EEG.times <= timeRange(2);  % Time indices in range
cut_data    = EEG.icaact(compRange, t_ind, :);                         % Extract specified components and time range

% Apply moving average if specified
maW = round(maW/(1000/EEG.srate));  % Convert maW to samples
if maW > 0
    try
        cut_data = movmean(cut_data, maW, 2);  % Moving average over time
    catch
        warning('Moving average supported only on Matlab 2016b+\nWill not compute moving average');
    end
end

% Convert window size and step size to samples
winSize     = round(winSize/(1000/EEG.srate));
stepSize    = round(stepSize/(1000/EEG.srate));
w1          = [1:stepSize:(size(cut_data,2)-winSize) (size(cut_data,2)-winSize+1)]; % Start of each window
we          = w1 + winSize - 1;  % End of each window

% Initialize rejection matrix
rej = false(size(EEG.icaact));   % Initialize with dimensions matching EEG.icaact
rej = permute(rej, [1, 3, 2]);   % Permute for easier access during loop
rej = rej(:, :, 1:length(w1));

% Sliding window analysis
for tw = 1:length(w1)
    temp_x         = cut_data(:, w1(tw):we(tw), :); % Select window data for all components
    xmax           = max(temp_x, [], 2);            % Max within window for each component
    xmin           = min(temp_x, [], 2);            % Min within window for each component
    xdiff          = xmax - xmin;                   % Range within window
    rej(compRange, :, tw) = squeeze(xdiff > minmaxThresh); % Threshold check
end
rej = permute(rej, [1, 3, 2]);
rej = squeeze(any(rej, 2));  % Summarize rejections across windows

% Update EEG structure with rejection flags
EEG.reject.rejmaxminICA  = double(rej);               % Trial-wise rejections by component
EEG.reject.rejmaxmin     = double(any(rej, 1));       % Overall trial rejection

fprintf('%d component(s) selected\n', length(compRange));
fprintf('%d/%d trials contain components that exceed threshold\n', sum(EEG.reject.rejmaxmin), EEG.trials);

end
