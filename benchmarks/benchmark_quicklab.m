function T = benchmark_quicklab(varargin)
% benchmark_quicklab() - Time QuickLab's parallel functions against the EEGLAB
% functions they replace, on the same data, and check the outputs match.
%
% Usage:
%   >> T = benchmark_quicklab();                      % EEGLAB sample data, all cores
%   >> T = benchmark_quicklab('workers', 8, 'reps', 5);
%   >> T = benchmark_quicklab('dataset', 'my.set');   % your own data (needs ICA)
%
% Each pair is run once to warm up, then 'reps' times in alternating order; the
% table reports median wall-clock seconds. Results are also written to
% benchmarks/results.md together with the machine and versions used.
%
% Steps timed (each runs only if its plugin is installed):
%   DIPFIT     pop_multifit        vs pop_par_multifit2   (parfor over components)
%   BSS (AAR)  autobss             vs par_autobss         (parfor over windows)
%   ICLabel    iclabel             vs iclabel_par         (prompt-free wrapper, not parallel)

opt = finputcheck(varargin, { ...
    'workers' 'integer' [] feature('numcores');
    'reps'    'integer' [] 3;
    'dataset' 'string'  [] '' });
if ischar(opt), error(opt); end

here = fileparts(mfilename('fullpath'));
if isempty(opt.dataset)
    sample = fullfile(fileparts(which('eeglab')), 'sample_data');
    [~, E] = evalc('pop_loadset(''eeglab_data_epochs_ica.set'', sample)');
    [~, C] = evalc('pop_loadset(''eeglab_data.set'', sample)');
    dataName = 'EEGLAB sample data (32 channels, 128 Hz)';
else
    [~, E] = evalc('pop_loadset(opt.dataset)');
    C = E;
    if C.trials > 1, C.data = reshape(C.data, C.nbchan, []); C.trials = 1; C.pnts = size(C.data,2); end
    dataName = opt.dataset;
end
E.filename = '';

pool = gcp('nocreate');
if isempty(pool) || pool.NumWorkers ~= opt.workers
    delete(pool);
    pool = parpool('local', opt.workers);
end

rows = {};

% ---------------- DIPFIT
if exist('pop_dipfit_settings', 'file')
    D = setup_dipfit(E);
    comps = 1:size(D.icaweights,1);
    std_fn = @() pop_multifit(D, comps, 'threshold', 100, 'dipplot', 'off');
    par_fn = @() pop_par_multifit2(D, comps, 'threshold', 100, 'dipplot', 'off');
    [ts, tp, A, B] = timepair(std_fn, par_fn, opt.reps);
    same = isequaln([A.dipfit.model(comps).rv], [B.dipfit.model(comps).rv]);
    rows(end+1,:) = {'DIPFIT, 1 dipole', sprintf('%d components', numel(comps)), 'pop_multifit', ts, tp, same};
end

% ---------------- BSS-CCA (AAR)
if exist('autobss', 'file')
    X = double(C.data);
    o = struct; o.bss_opt = struct('eigratio', 1e6); o.crit_opt = struct('range', [2 3]);
    o.crit_opt.eogref = []; o.crit_opt.fs = C.srate; o.bss_alg = 'bsscca'; o.crit_alg = 'eog_fd'; o.verbose = 0;
    o.wl = 2*C.srate; o.ws = 2*C.srate;
    [ts, tp, A, B] = timepair(@() autobss(X, o), @() par_autobss(X, o), opt.reps);
    rows(end+1,:) = {'BSS-CCA artifact removal', sprintf('%.0f s of data, 2 s windows', size(X,2)/C.srate), 'autobss (AAR)', ts, tp, isequal(A, B)};
end

% ---------------- ICLabel
if exist('iclabel', 'file')
    [ts, tp, A, B] = timepair(@() iclabel(E), @() iclabel_par(E), opt.reps);
    same = max(max(abs(A.etc.ic_classification.ICLabel.classifications - B.etc.ic_classification.ICLabel.classifications))) < 1e-6;
    rows(end+1,:) = {'ICLabel', sprintf('%d components', size(E.icaweights,1)), 'iclabel', ts, tp, same};
end

T = cell2table(rows, 'VariableNames', {'Step', 'Size', 'EEGLAB_function', 'EEGLAB_s', 'QuickLab_s', 'Same_output'});
T.Speedup = T.EEGLAB_s ./ T.QuickLab_s;
disp(T);
write_results(fullfile(here, 'results.md'), T, dataName, pool.NumWorkers, opt.reps);
end

function [tStd, tPar, outStd, outPar] = timepair(stdFn, parFn, reps)
% warm up both (loads files, compiles, starts workers), then alternate the order
evalc('outStd = stdFn();'); evalc('outPar = parFn();');
ts = zeros(1, reps); tp = zeros(1, reps);
for r = 1:reps
    if mod(r, 2)
        t = tic; evalc('stdFn();'); ts(r) = toc(t);
        t = tic; evalc('parFn();'); tp(r) = toc(t);
    else
        t = tic; evalc('parFn();'); tp(r) = toc(t);
        t = tic; evalc('stdFn();'); ts(r) = toc(t);
    end
end
tStd = median(ts); tPar = median(tp);
end

function write_results(file, T, dataName, workers, reps)
v = ver('MATLAB');
[~, cpu] = system('lscpu 2>/dev/null | grep "Model name" || sysctl -n machdep.cpu.brand_string 2>/dev/null');
fid = fopen(file, 'w'); c = onCleanup(@() fclose(fid));
fprintf(fid, '# QuickLab benchmark\n\n');
fprintf(fid, '- Date: %s\n- MATLAB %s, EEGLAB %s\n- CPU: %s\n- Parallel workers: %d\n- Data: %s\n- Median of %d runs after a warm-up run, alternating order\n\n', ...
    char(datetime('now', 'Format', 'yyyy-MM-dd')), v.Version, eeg_getversion, strtrim(regexprep(cpu, '.*:\s*', '')), workers, dataName, reps);
fprintf(fid, '| Step | Size | Compared with | EEGLAB (s) | QuickLab (s) | Speedup | Same output |\n|---|---|---|---:|---:|---:|---|\n');
for i = 1:height(T)
    fprintf(fid, '| %s | %s | `%s` | %.2f | %.2f | %.1fx | %s |\n', T.Step{i}, T.Size{i}, T.EEGLAB_function{i}, ...
        T.EEGLAB_s(i), T.QuickLab_s(i), T.Speedup(i), mat2str(T.Same_output(i)));
end
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
