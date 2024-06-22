function EEG = quick_corrmap(EEG,threshold,numOfRejectionsPerTemplate,corrpath)
% --- defining defaults
currentFolder = pwd;
if nargin < 4
    if isfile('corrmappath.txt')
        corrmappath = readtext('corrmappath.txt');
        if iscell(corrmappath)
            corrmappath = corrmappath{:};
        end
    else
        corrmappath = uigetdir();
        writematrix(corrmappath,'corrmappath.txt')
    end
end

if nargin < 3
    numOfRejectionsPerTemplate = 2;
end
if nargin < 2
    threshold = 0.90;
end
% load all files, separate them into templates & non-templates.
%since we can't load " non-templates" if statement from line 23 does it

%allsets = dir('*.set'); %contains all sets from the folder
% --- moves to corrmap folder and gets all corrmap file directory
corrpath = strcat(corrpath,'/',num2str(EEG.nbchan));
if isfolder(corrpath)
    cd(corrpath);
else
    fprintf('No CORRMAP folder, make a folder and add maps in! \r')
    return
end

corrTemplates = dir('*.set'); % contains all templates from the folder
% --- stores this EEG and ALLEEG
currentEEG = EEG;
% if isvarname('ALLEEG')
%     currentALLEEG = ALLEEG;
% end
% -- clears for loading... not sure if necessary
clear EEG ALLEEG
[ALLEEG, EEG] = pop_loadset('filename',{corrTemplates.name}); %loads all templates
tALLEEG = ALLEEG; %copies the templates to another variable
clear ALLEEG EEG; %eliminates the templates from ALLEEG

cd(currentFolder);
%files = struct.empty(0,5);

%eeglab;  %loads eeglab

%for i=1:size(allsets,1) %condition A: given all .set files from the folder
EEG = currentEEG; %loads non-template number i
%ALLEEG = currentALLEEG;

%  creates empty arrays to store correlations
%  -- stores all correlations in big array
EEG.mycorrelations = zeros(length(tALLEEG),size(EEG.icawinv,2));
% -- stores all bad components by number and position
EEG.mybadcomps = zeros(length(tALLEEG),size(EEG.icawinv,2));%store components above threshold
% -- stores all bad components' correlations by number and position
EEG.mybadcompscorr = zeros(length(tALLEEG),size(EEG.icawinv,2)); % store how much the component above passes correlation
% -- stores all highest components number, specified by number numOfRejectionsPerTemplate and position
EEG.compstoberejected = [];
% -- stores all unique components to be rejected, above threshold and number per template
EEG.uniquecompstobereject = [];

for k=1:length(tALLEEG) % loops for all k templates
    %IC = str2double(tALLEEG(k).filename(11:12)); % stores the template's component number
    IC = 1;
    for j=1:size(EEG.icaweights,1) %loops all EEG components
        EEG.mycorrelations(k,j) = abs(corr(tALLEEG(k).icawinv(:,IC),EEG.icawinv(:,j))); %runs the correlation
        % for example: corr(EEG(6).icawinv(:,1),tALLEEG(24).icawinv(:,1)) %this works
        
        if EEG.mycorrelations(k,j) >= threshold
            EEG.mybadcomps(k,j) = j;
            EEG.mybadcompscorr(k,j) = EEG.mycorrelations(k,j);
        end
    end
    
    %gets how many components were rejected
    numberOfRejected = nnz(EEG.mybadcomps(k,:));
    
    if numberOfRejected >= 1 % if there 1 or more comps to be rejected
        % -- sorting the components according to the highest correlations
        % -- creating variables of the components and correlations
        SortCorr = EEG.mybadcompscorr(k,:);
        SortComp = EEG.mybadcomps(k,:);
        % -- removes the zeros from the arrays
        SortCorr = transpose(nonzeros(SortCorr));
        SortComp = transpose(nonzeros(SortComp));
        
        % -- sorts the correlations in descending order
        [SortCorrs, CorOrder] = sort(SortCorr, 'descend');
        
        % -- resorts the components according to the new sorting of the correlations
        % --  makes a new variable called newSortedComps containing
        % -- the components in a sorted fashion
        newSortedComps = [];
        for n=1:length(SortComp)
            newSortedComps(n) = SortComp(CorOrder(n));
        end
        
        % if there are more than X rejected components, rejects
        % only X
        if numberOfRejected >= numOfRejectionsPerTemplate
            for m = 1:numOfRejectionsPerTemplate
                EEG.compstoberejected(end+1) = newSortedComps(m);
            end
            % if there are only 1 component to be rejected, rejects
            % that one
        elseif numberOfRejected ~= 0 && numberOfRejected < numOfRejectionsPerTemplate
            for m = 1:numberOfRejected
                EEG.compstoberejected(end+1) = newSortedComps(m);
            end
            EEG.compstoberejected(end+1) = newSortedComps(1);
        end
    end
end
% Now, we looped all templated, how many unique components were
% rejected?
% reject all unique components selected
if nnz(EEG.compstoberejected) > 0
    EEG.uniquecomptoberejected = unique(EEG.compstoberejected);
    EEG = pop_subcomp(EEG, EEG.uniquecomptoberejected, 0);
end

%stores the # of ICs left in the data

totalICS = num2str(size(EEG.icaweights,1));
%EEG = pop_saveset(EEG, 'filename', [allsets(i).name(1:end-4), strcat('Pc',totalICS,'CORR.set')], 'filepath',  PATHOUT ); %save set - all artifacts corrected
%EEG = pop_delset(EEG,1);
%end
cd(currentFolder);
end
