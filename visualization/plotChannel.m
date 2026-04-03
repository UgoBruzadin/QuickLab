% Created this function to facilitate drawing and plotting channels, Ugo 2021

function [tmp_y] = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim)

tmp_x=1:length(lowlim:highlim);
tmp_y=nan(length(chans_list_bad),length(lowlim:highlim));
warning('off');
for ii = 1:length(chans_list_bad)
    i=chans_list_bad(ii);
    tmp_y(ii,tmp_x)=data(g.chans-i+1,lowlim:highlim) ...
        - meandata(g.chans-i+1) ...;
        + i*g.spacing ...;
        + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
        + g.elecoffset*(oldspacing-g.spacing);

end
