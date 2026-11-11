function tests = test_quicklab
% Tests for QuickLab on EEGLAB's sample data. Where QuickLab replaces an EEGLAB
% function (parallel ICLabel, parallel DIPFIT, rejection/interpolation), the test
% checks that QuickLab gives the same answer as EEGLAB.
%
% Run from the repository root, with EEGLAB on the path or in ../eeglab:
%   >> results = runtests('tests'); table(results)
tests = functiontests(localfunctions);
end

function setupOnce(tc)
root = fileparts(fileparts(mfilename('fullpath')));
if isempty(which('eeglab'))
    eeglabDir = getenv('EEGLAB_DIR');
    if isempty(eeglabDir), eeglabDir = fullfile(fileparts(root), 'eeglab'); end
    addpath(eeglabDir);
end
evalc('eeglab nogui');
% use this checkout of QuickLab, not an installed copy
p = strsplit(path, pathsep);
old = p(contains(p, [filesep 'plugins' filesep 'QuickLab']));
if ~isempty(old), rmpath(old{:}); end
addpath(root, fullfile(root,'gui'), fullfile(root,'processing'), fullfile(root,'visualization'), fullfile(root,'utils'));

sample = fullfile(fileparts(which('eeglab')), 'sample_data');
[~, tc.TestData.epochs]     = evalc('pop_loadset(''eeglab_data_epochs_ica.set'', sample)');
[~, tc.TestData.continuous] = evalc('pop_loadset(''eeglab_data.set'', sample)');
tc.TestData.epochs.filename = ''; % never write backups during tests
if license('test', 'Distrib_Computing_Toolbox')
    ps = parallel.Settings; ps.Pool.AutoCreate = false; % parfor runs serially, still checked
end
end

%% Plugin wiring
function testEveryMenuCallbackFunctionExists(tc)
root = fileparts(fileparts(mfilename('fullpath')));
src = fileread(fullfile(root, 'eegplugin_QuickLab.m'));
src = regexprep(src, '(?m)^\s*%.*$', ''); % drop commented-out menu items
calls = regexp(src, '(quick_\w+|pop_\w+|save_corrmap\w*)\s*\(', 'tokens');
calls = unique(cellfun(@(c) c{1}, calls, 'UniformOutput', false));
for i = 1:numel(calls)
    tc.verifyTrue(exist(calls{i}, 'file') > 0, sprintf('menu calls missing function %s', calls{i}));
end
end

function testPluginRegistersMenu(tc)
fig = figure('Visible', 'off'); cleanup = onCleanup(@() close(fig));
uimenu(fig, 'Label', 'Plot');
try_strings.no_check = ''; catch_strings.store_and_hist = '';
v = eegplugin_QuickLab(fig, try_strings, catch_strings);
tc.verifyGreaterThan(v, 0);
tc.verifyNotEmpty(findobj(fig, 'Label', 'QuickLab'));
end

%% Epoching
function testEpochUnepochRoundTrip(tc)
C = tc.TestData.continuous;
[~, E] = evalc('quick_epoch(C, 1)');
[~, U] = evalc('quick_unepoch(E)');
tc.verifyEqual(U.trials, 1);
tc.verifyEqual(U.data, C.data(:, 1:size(U.data,2)));
tc.verifyEqual(U.xmax, (U.pnts-1)/U.srate, 'AbsTol', 1e-9);
end

function testUnepochReturnsHistoryCommand(tc)
[~, U, com] = evalc('quick_unepoch(tc.TestData.epochs)');
tc.verifyNotEmpty(com);
tc.verifyEqual(size(U.data,2), tc.TestData.epochs.pnts * tc.TestData.epochs.trials);
end

%% ICLabel
function testParallelICLabelMatchesICLabel(tc)
E = tc.TestData.epochs;
[~, A] = evalc('iclabel(E)');
[~, B] = evalc('iclabel_par(E)');
tc.verifyEqual(B.etc.ic_classification.ICLabel.classifications, ...
               A.etc.ic_classification.ICLabel.classifications, 'AbsTol', 1e-6);
end

function testPopParICLabelUsesRequestedVersion(tc)
[~, B, com] = evalc('pop_par_iclabel(tc.TestData.epochs, ''lite'')');
tc.verifyEqual(B.etc.ic_classification.ICLabel.version, 'lite');
tc.verifySubstring(com, 'pop_par_iclabel(');
end

function testICFlagInclusiveBounds(tc)
E = tc.TestData.epochs;
n = size(E.icaweights,1);
E.etc.ic_classification.ICLabel.classifications = [eye(7); repmat(1/7, n-7, 7)];
thresh = [NaN NaN; 0.8 1; 0.8 1; NaN NaN; NaN NaN; NaN NaN; NaN NaN];
[~, F, com] = evalc('pop_par_icflag(E, thresh)');
tc.verifyEqual(find(F.reject.gcompreject), [2 3]);
tc.verifyNotEmpty(com);
end

%% Rejection and interpolation (what the Data Scroll Pro "apply" runs)
function testPartialChannelInterpolationAndEpochRejection(tc)
E = tc.TestData.epochs; P = E.pnts;
row = @(ep, rgb, chans) [(ep-1)*P+1, ep*P, rgb, double(ismember(1:E.nbchan, chans))];
regions = [row(3, [0.7 1 0.8], 5); row(7, [1 0.8 0.9], [])]; % green: interp ch 5 in epoch 3; red: reject epoch 7
[~, R] = evalc('eeg_eegrej_adv(E, regions, 1, [])');
[~, I] = evalc('pop_interp(E, 5, ''spherical'')');
keep = setdiff(1:E.trials, 7);
expected = E.data(:,:,keep);
expected(5,:,3) = I.data(5,:,3);
tc.verifyEqual(R.trials, E.trials - 1);
tc.verifyEqual(R.data, expected, 'AbsTol', 1e-4);
end

function testFullChannelInterpolation(tc)
E = tc.TestData.epochs;
[~, R] = evalc('eeg_eegrej_adv(E, [], 1, 9)');
[~, I] = evalc('pop_interp(E, 9, ''spherical'')');
tc.verifyEqual(R.data, I.data, 'AbsTol', 1e-4);
end

function testPartialComponentRemoval(tc)
E = tc.TestData.epochs; P = E.pnts; n = size(E.icaweights,1);
regions = [(4-1)*P+1, 4*P, 0.7 1 0.8, double(ismember(1:n, 2))]; % remove comp 2 in epoch 4 only
[~, R] = evalc('eeg_eegrej_adv(E, regions, 2, [])');
[~, S] = evalc('pop_subcomp(E, 2)');
tc.verifyEqual(R.data(:,:,4), S.data(:,:,4), 'AbsTol', 1e-3);
tc.verifyEqual(R.data(:,:,5), E.data(:,:,5));
tc.verifyEqual(size(R.icaact,1), size(R.icaweights,1));
end

function testMergeTrialsCombinesCopiesOfOneWindow(tc)
W = [1 10 0.7 1 0.8 1 0; 1 10 1 0.8 0.9 0 1; 1 10 0.7 1 0.8 0 0];
tc.verifyEqual(eegplot_adv_methods('merge_trials', W), [1 10 1 0.8 0.9 1 1]);
end

function testMaxMinOnComponents(tc)
[~, R] = evalc('pop_eegmaxmin_ica(tc.TestData.epochs, [], [], 50, [], [], 0)');
tc.verifySize(R.reject.rejmaxmin, [1 tc.TestData.epochs.trials]);
tc.verifyGreaterThan(sum(R.reject.rejmaxmin), 0);
end

function testFlatlineMarksOnlyFlatChannel(tc)
C = tc.TestData.continuous; C.data(5,:) = 0;
[~, R] = evalc('quick_TBT(C, 1, 7, '''', 1, 50)');
tc.verifyEqual(find(R.badchans)', 5);
end

%% BSS (AAR plugin)
function testParallelBssMatchesAutobss(tc)
tc.assumeTrue(exist('autobss', 'file') > 0, 'AAR plugin not installed');
C = tc.TestData.continuous;
X = double(C.data(:, 1:round(C.srate*21.3)));
opt = struct; opt.bss_opt = struct('eigratio', 1e6); opt.crit_opt = struct('range', [2 3]);
opt.crit_opt.eogref = []; opt.crit_opt.fs = C.srate; opt.bss_alg = 'bsscca'; opt.crit_alg = 'eog_fd'; opt.verbose = 0;
for w = [2 2; 2 1; 3 2]'
    opt.wl = w(1)*C.srate; opt.ws = w(2)*C.srate;
    [~, Y] = evalc('par_autobss(X, opt)');
    [~, Z] = evalc('autobss(X, opt)');
    tc.verifyEqual(Y, Z, 'AbsTol', 1e-9, sprintf('window %gs, shift %gs', w(1), w(2)));
end
end

function testQuickBssKeepsTheData(tc)
tc.assumeTrue(exist('autobss', 'file') > 0, 'AAR plugin not installed');
C = tc.TestData.continuous;
[~, B] = evalc('quick_bss2(C, 2)');
tc.verifySize(B.data, size(C.data));
tc.verifyLessThan(mean(B.data(:) == 0), 0.01, 'Quick BSS returned mostly zeros');
end

%% DIPFIT
function testParallelDipfitMatchesPopMultifit(tc)
E = tc.TestData.epochs;
E = setup_dipfit(E);
comps = [3 5]; % not 1:n on purpose
[~, A] = evalc('pop_multifit(E, comps, ''threshold'', 100, ''dipplot'', ''off'')');
[~, B] = evalc('pop_par_multifit2(E, comps, ''threshold'', 100, ''dipplot'', ''off'')');
for c = comps
    tc.verifyEqual(B.dipfit.model(c).posxyz, A.dipfit.model(c).posxyz, 'AbsTol', 1e-6);
    tc.verifyEqual(B.dipfit.model(c).rv, A.dipfit.model(c).rv, 'AbsTol', 1e-9);
end
end

%% Data Scroll Pro (headless smoke test)
function testDataScrollProOpensAndDrawsLegend(tc)
E = tc.TestData.epochs;
set(0, 'DefaultFigureVisible', 'off');
cleanup = onCleanup(@() set(0, 'DefaultFigureVisible', 'on'));
[~, ~] = evalc('pop_eegplot_adv(E, 1, 2, 1, 1)');
fig = findobj('Tag', 'eegplot_adv');
tc.assertNotEmpty(fig, 'Data Scroll Pro window did not open');
evalc('eegplot_adv(''drawlegend'', fig(1))');
tc.verifyNotEmpty(findobj('Tag', 'legend'));
close all force;
end

function E = setup_dipfit(E)
% BESA spherical template, which EEGLAB's sample data are aligned to.
% DIPFIT 5.x selects templates with 'model'; older versions need the file paths.
try
    [~, E] = evalc('pop_dipfit_settings(E, ''model'', ''standardBESA'', ''coord_transform'', [0 0 0 0 0 0 1 1 1], ''chansel'', 1:E.nbchan)');
catch
    dp = fileparts(which('pop_dipfit_settings'));
    [~, E] = evalc(['pop_dipfit_settings(E, ''hdmfile'', fullfile(dp,''standard_BESA'',''standard_BESA.mat''), ' ...
        '''coordformat'', ''Spherical'', ''mrifile'', fullfile(dp,''standard_BESA'',''avg152t1.mat''), ' ...
        '''chanfile'', fullfile(dp,''standard_BESA'',''standard-10-5-cap385.elp''), ' ...
        '''coord_transform'', [0 0 0 0 0 0 1 1 1], ''chansel'', 1:E.nbchan)']);
end
% DIPFIT stores template files by bare name (found on the path); newer FieldTrip
% releases check the file directly, so give them full paths
for f = {'hdmfile', 'mrifile', 'chanfile'}
    if ~isempty(E.dipfit.(f{1})) && ~isfile(E.dipfit.(f{1})) && ~isempty(which(E.dipfit.(f{1})))
        E.dipfit.(f{1}) = which(E.dipfit.(f{1}));
    end
end
end
