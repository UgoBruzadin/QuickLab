
function [NEW,com] = quick_icrejBSS(NEW)

[NEW,com] = quick_PCA(NEW,[],[],0);
[NEW] = pop_par_icflag(NEW, [NaN NaN;0.8 1;0.8 1;0.8 1;0.8 1;0.8 1;NaN NaN]);
[NEW] = quick_rejection(NEW);
[NEW,com] = quick_bss2(NEW); [NEW,com] = quick_PCA(NEW,[],[],0);

% 
%            newcom = ['[NEW,com] = quick_PCA(NEW,[],[],0);',...
%            '[NEW] = pop_par_icflag(NEW, [NaN NaN;0.8 1;0.8 1;0.8 1;0.8 1;0.8 1;NaN NaN]);',...
%            '[NEW] = quick_rejection(NEW)',...
%            '[NEW,com] = quick_bss2(EEG); [NEW,com] = quick_PCA(NEW,[],[],0);'];