function g = eegplot_compare_snapshot(g, pre_data, pre_info)
% eegplot_compare_snapshot() - Take a lightweight snapshot for pre/post comparison.
%   Called after a processing operation to enable the Compare view.
%   Automatically selects the most memory-efficient storage strategy.
%
% Usage:
%   g = eegplot_compare_snapshot(g, pre_data, pre_info)
%
% Inputs:
%   g        - eegplot_adv userdata struct (must contain g.EEG with current data)
%   pre_data - data matrix BEFORE the operation (channels x timepoints)
%   pre_info - struct with fields: nbchan, pnts, trials, srate
%
% Outputs:
%   g - updated struct with g.compare populated
%
% Storage strategies (auto-selected):
%   'sparse'   - when <30% of data changed (stores sparse diff, tiny RAM)
%   'tempfile'  - when >30% changed (saves to temp HDF5 file, zero RAM)
%
% See also: eegplot_compare_dismiss, draw_data
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

% First dismiss any existing comparison to free resources
g = eegplot_compare_dismiss(g);

post = g.EEG;

% Check structural compatibility
if pre_info.nbchan ~= post.nbchan || pre_info.pnts ~= post.pnts || ...
   pre_info.trials ~= post.trials || pre_info.srate ~= post.srate
    g.compare.compat = 0;
    g.compare.storage = 'none';
    g.compare.msg = sprintf('Structure changed: ch %d->%d, pts %d->%d, ep %d->%d', ...
        pre_info.nbchan, post.nbchan, pre_info.pnts, post.pnts, ...
        pre_info.trials, post.trials);
    fprintf('Compare: %s\n', g.compare.msg);
    return;
end

% Reshape data to 2D for comparison (handles epoched data)
pre_2d = pre_data(:,:);
post_2d = post.data(:,:);

% Compute diff and measure how much changed
diff_data = post_2d - pre_2d;
n_changed = nnz(abs(diff_data) > 1e-10);
n_total = numel(diff_data);
pct_changed = 100 * n_changed / n_total;

if pct_changed < 0.001
    % Nothing actually changed
    g.compare.compat = 0;
    g.compare.storage = 'none';
    g.compare.msg = 'No data changes detected.';
    fprintf('Compare: %s\n', g.compare.msg);
    return;
end

SPARSE_THRESHOLD = 30; % percent

if pct_changed < SPARSE_THRESHOLD
    % Strategy 1: Sparse storage — tiny memory footprint
    g.compare.diff_sparse = sparse(double(diff_data));
    g.compare.storage = 'sparse';
    mem_bytes = whos('diff_data'); % approximate
    fprintf('Compare: sparse storage (%.1f%% changed)\n', pct_changed);
else
    % Strategy 2: Temp file — zero RAM cost
    pre_save = pre_2d; %#ok<NASGU> used by save()
    g.compare.tempfile = fullfile(tempdir, ...
        sprintf('quicklab_pre_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
    try
        save(g.compare.tempfile, 'pre_save', '-v7.3');
        g.compare.storage = 'tempfile';
        fprintf('Compare: temp file storage at %s (%.1f%% changed)\n', ...
            g.compare.tempfile, pct_changed);
    catch ME
        warning('QuickLab:compare', 'Could not save temp file: %s', ME.message);
        g.compare.storage = 'none';
        g.compare.compat = 0;
        g.compare.msg = 'Failed to save comparison data.';
        return;
    end
end

g.compare.compat = 1;
g.compare.mode = 'overlay'; % auto-enable comparison
g.compare.pre_nbchan = pre_info.nbchan;
g.compare.pre_pnts = pre_info.pnts;
g.compare.pre_trials = pre_info.trials;
g.compare.timestamp = now;
g.compare.msg = sprintf('Comparison ready (%.1f%% changed, %s storage)', ...
    pct_changed, g.compare.storage);
