function save_corrmaps(EEG)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if isempty(EEG.icaweights)
    fprintf('save_corrmaps: no ICA decomposition, run ICA first.\n');
    return
end

currentfolder = pwd;
restoreFolder = onCleanup(@() cd(currentfolder)); % return to the user's folder even on error

myComps = [];
if isfield(EEG.reject, 'gcompreject'), myComps = find(EEG.reject.gcompreject); end

if isempty(myComps)
    fprintf('save_corrmaps: no component selected. Mark components first, then save them as templates.\n');
    quick_IClabel(EEG);
    return
end

corrmappath = save_corrmappath(false); % saved templates folder, asks only the first time
if isempty(corrmappath), return; end
cd(corrmappath);


chanfolder = num2str(EEG.nbchan);

mkdir(chanfolder);

cd(strcat('./',chanfolder));

corrmapFiles = dir('*.set');

EEGbase = EEG;

EEGbase = pop_iclabel(EEGbase);

myComps = find(EEGbase.reject.gcompreject);   %stores the Id of the components to be rejected
if myComps
    for i = 1:length(myComps)
        % --- Get all component numbers
        allComps = [1:size(EEGbase.icawinv,2)];
        % --- remove the one component number
        allComps(myComps(i)) = [];
        % --- make another copy of the EEG data
        EEGcomp = EEGbase;
        % --- removes the other components from the data-set to minimize file
        % ---- size
        EEGcomp = pop_subcomp(EEGcomp, allComps, 0);       % actually removes the flagged components
        % --- get number and value of the component classification
        [value,col] = max(EEGbase.etc.ic_classification.ICLabel.classifications(myComps(i),:));
        % --- start the name of the component with it's classification
        corrName = EEGbase.etc.ic_classification.ICLabel.classes(col);
        corrName = corrName{:}; % --- removes it from a cell into a str/char
        % --- get number of components in the list; start fresh if list of components is empty
        compNumber = numel(corrmapFiles) + i; % was 1 for every component when the folder started empty
        % --- finalize component name with %, number and ID
        corrName = strcat(corrName,'-',num2str(compNumber),'-',num2str(value));
        % --- save component
        pop_saveset(EEGcomp, 'filename', [strcat(corrName, '.set')],'filepath',pwd);
    end
end

cd(currentfolder);
end