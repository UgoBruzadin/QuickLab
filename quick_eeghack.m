function quick_eeghack()

changename = ['h = findobj(gcf, ''tag'', ''win1''); set(h, ''string'', strcat(''FILENAME:'',EEG.filename));'];

changeICA = ['h = findobj(gcf, ''tag'', ''val11''); if ~isempty(EEG.icaact), set(h, ''string'', num2str(size(EEG.icaact,1))), end;'];

%%changeICA = ['h = findobj(gcf, ''tag'', ''val11''); if ~isempty(EEG.icaact), set(h, ''string'', ''TEST''), end;'];

loaddircommand = [changename, changeICA, 'try, if isempty(EEG.setname);EEG = pop_loadset();end; findex = [1];cd(EEG.filepath);filecount = [1];files = dir(''.set'');' ...
    'findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''LoadFileList2''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename))); catch; end; quick_eeghack()'];

savecommand = ['[EEG] = pop_saveset(EEG, ''filename'', [strcat( EEG.filename(1:end-4),get(findobj(''Tag'',''SAVETEXT2''),''String''),''.set'')],''filepath'',EEG.filepath);'...
     '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);' loaddircommand 'eeglab redraw; quick_eeghack()']; %save set ADDED BY UGO
%%% move up
%loadprecommand = ['findex = find(strcmp({files.name}, EEG.filename));if findex > 1, findex = findex - 1, EEG = pop_loadset( files(findex).name, pwd); eeglab redraw, end;'];
%%% move down
%loadpostcommand = ['findex = find(strcmp({files.name}, EEG.filename));if findex < length(files), findex = findex + 1, EEG = pop_loadset( files(findex).name, pwd); eeglab redraw, end; '];
%%% loadfile
loadfilecommand = ['EEG = pop_loadset( files(get(findobj(''Tag'',''LoadFileList2''),''Value'')).name, pwd);eeglab redraw; quick_eeghack()'];

%%% Create Buttons and Menu addons
savetitle = uicontrol(gcf,'Style', 'text', 'Units','Normalized','Tag', 'SAVETITLE2', 'String', 'Save as: ',...
    'Position', [0.05 0.05 0.08 0.05]);

savetext = uicontrol(gcf, 'Style', 'edit', 'Units','Normalized','Tag', 'SAVETEXT2', 'String', 'New',...
    'Position', [0.13 0.05 0.07 0.05]);

savebutton = uicontrol(gcf, 'Style', 'pushbutton','Units','Normalized','Tag', 'SAVEASBUTTON2', 'String', 'Save(+)', 'callback', savecommand ,...
    'Position', [0.23 0.05 0.07 0.05]);

loaddir = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'LoadDir2', 'String', 'Load Folder', 'callback', loaddircommand ,...
    'Position', [0.31 0.05 0.08 0.05]);

%loadup = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'LoadUp', 'String', 'Up', 'callback', loadprecommand ,...
%    'Position', [0.40 0.05 0.03 0.05]);

%loaddown = uicontrol(gcf, 'Style', 'pushbutton','Units','Normalized','Tag', 'LoadDown', 'String', 'Down', 'callback', loadpostcommand ,...
%    'Position', [0.43 0.05 0.045 0.05]);

loadfile = uicontrol(gcf, 'Style', 'popupmenu','Units','Normalized','Tag', 'LoadFileList2', 'String', '', 'callback', loadfilecommand,...
    'Position', [0.48 0.05 0.45 0.05]);

%%% Change buttons and text color backgrounds



h = findobj(gcf, 'style', 'pushbutton');
set(h, 'backgroundcolor', [0.9 0.9 0.9]);

h = findobj(gcf, 'tag', 'SAVETITLE2');
set(h, 'backgroundcolor', [.66 .76 1]);

fprintf('QUICKLAB: EEGLAB main menu was successfully modified! \r')

function tmprank2 = getrank(tmpdata)
        
tmprank = rank(tmpdata);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here: alternate computation of the rank by Sven Hoffman
%tmprank = rank(tmpdata(:,1:min(3000, size(tmpdata,2)))); old code
covarianceMatrix = cov(tmpdata', 1);
[~, D] = eig (covarianceMatrix);
rankTolerance = 1e-7;
tmprank2=sum (diag (D) > rankTolerance);
if tmprank ~= tmprank2
    %fprintf('Warning: fixing rank computation inconsistency (%d vs %d) most likely because running under Linux 64-bit Matlab\n', tmprank, tmprank2);
    tmprank2 = min(tmprank, tmprank2);
end

function CountDownDotLoc(axis)

if nargin < 1
    axisPanel = findobj('Tag','PieChart');
    axis = findobj('Tag','pie_chart');
end

%axis = axes(axis, 'Tag','pie_chart','Position', [0 0 1 1]);

A = dir('*EP63.set');
B = dir('*EP60.set');
C = cat(1,A,B);
total = length(C);

D = dir('*.set');
F = [D.name];
totalstarted = 0;

for i = 1:total
    
    G = strfind(F,C(i).name(1:end-4));
    H = length(G);
    
    if H > 1
        totalstarted = totalstarted + 1;
    end

end

totalleft = total-totalstarted;
% total
% totalstarted
% totalstarted/total*100
try
pie(axis,[totalleft,totalstarted],{num2str(totalleft), '(',num2str(totalstarted/total) ,'%)',num2str(totalstarted)})
catch
end
% pie([total-totalstarted,totalstarted])