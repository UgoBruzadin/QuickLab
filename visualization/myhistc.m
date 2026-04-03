% function not supported under Mac
% --------------------------------
function [reshist, allbin] = myhistc(vals, intervals)
reshist = zeros(1, length(intervals));
allbin = zeros(1, length(vals));
for index=1:length(vals)
    minvals = vals(index)-intervals;
    bintmp  = find(minvals >= 0);
    [~, indextmp] = min(minvals(bintmp));
    bintmp = bintmp(indextmp);

    allbin(index) = bintmp;
    reshist(bintmp) = reshist(bintmp)+1;
end
