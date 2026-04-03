function g=optim_scale(data,g)
    maxindex = min(10000, g.frames);
	stds = std(data(:,1:maxindex),[],2);
    g.datastd = stds;
	stds = sort(stds);
	if length(stds) > 2
		stds = mean(stds(2:end-1));
	else
		stds = mean(stds);
	end
    g.spacing = stds*3;
    if g.spacing > 10
      g.spacing = round(g.spacing);
    end
    if g.spacing  == 0 || isnan(g.spacing)
        g.spacing = 1; % default
    elseif g.spacing > 1.9 && g.spacing < 10000
        optim_scale=[2 3 5 7 10 15 20 30 50 75 100 150 200 250 300 500 750 1000 1500 2000 2500 3000 10000];
        i=find(optim_scale > g.spacing);
        g.spacing = optim_scale(i(1));
    end
