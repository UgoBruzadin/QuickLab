function [tmppos_x]=mouse_near_boundary_correction(tmppos_x,g)
boundaries_lat=[0 g.frames] + 0.5;
if isfield(g,'eventtypes')
    if iscellstr(g.eventtypes)
        if ismember({'boundary'},g.eventtypes)
            boundaries_lat=unique([boundaries_lat ...
                g.eventlatencies(find(ismember({g.events.type},{'boundary'}))) ]);
        end
    end
end
[~,boundary_closest_id]=min(abs(boundaries_lat-tmppos_x));
boundary_closest_lat=boundaries_lat(boundary_closest_id);
if abs(boundary_closest_lat - tmppos_x) < (g.srate*g.winlength*0.02)
    tmppos_x=round(boundary_closest_lat);
elseif tmppos_x > boundaries_lat(end)
    tmppos_x = boundaries_lat(end);
end
