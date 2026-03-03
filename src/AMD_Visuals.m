% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v15.0
% ==========================================
function AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, metric_name, metric_unit)
    % --- Graph ---
    cla(ax_bar);
    switch mode
        case {'Arm', 'Lift', 'Mobile'}
            vals = catalog.Torque_Nm; 
        case 'Power'
            vals = catalog.Capacity_mAh; 
        case 'Bolt'
            vals = catalog.MaxShear_N; 
    end
    bar(ax_bar, vals, 'FaceColor', [0.3 0.3 0.3]); hold(ax_bar, 'on');
    bar(ax_bar, b_idx, vals(b_idx), 'FaceColor', [1.0 0.6 0.2]); 
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w');
    ylabel(ax_bar, sprintf('%s [%s]', metric_name, metric_unit), 'Color', 'w');
    
    % --- 3D ---
    cla(ax_3d); hold(ax_3d, 'on');
    switch mode
        case 'Arm'
            len = inputs(2); rad = inputs(3);
            [X, Y, Z] = cylinder([rad rad], 20); Z = Z * len;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); w_s = 20 + rad; Xm=Xm*w_s+len; Ym=Ym*w_s; Zm=Zm*w_s;
            surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none');
        case 'Lift'
            p_rad = inputs(2);
            [X, Y, Z] = cylinder([p_rad p_rad], 20); Z = Z * 10;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.4 0.6 0.8], 'EdgeColor', 'none'); 
            plot3(ax_3d, [p_rad p_rad], [0 0], [0 -100], 'w', 'LineWidth', 2);
            [Xb, Yb, Zb] = meshgrid([p_rad-15 p_rad+15], [-15 15], [-130 -100]);
            Kb = convhull(Xb(:), Yb(:), Zb(:));
            trisurf(Kb, Xb(:), Yb(:), Zb(:), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none', 'Parent', ax_3d);
        case 'Mobile'
            w_rad = inputs(2); inc = inputs(3);
            L = 200; H = L * tan(inc * pi / 180);
            fill3(ax_3d, [0 L L 0], [50 50 -50 -50], [0 H H 0], [0.3 0.3 0.3]);
            [X, Y, Z] = cylinder([w_rad w_rad], 20);
            X2 = X; Y2 = Z*20 - 10; Z2 = Y;
            surf(ax_3d, X2+L/2, Y2, Z2+H/2+w_rad, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'k');
        case 'Power'
            verts = [0 0 0; 100 0 0; 100 60 0; 0 60 0; 0 0 40; 100 0 40; 100 60 40; 0 60 40];
            faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', [0.2 0.8 0.4], 'EdgeColor', 'k');
            [X,Y,Z] = cylinder([5 5]); Z=Z*10;
            surf(ax_3d, X+20, Y+30, Z+40, 'FaceColor', 'r', 'EdgeColor', 'none');
            surf(ax_3d, X+80, Y+30, Z+40, 'FaceColor', 'k', 'EdgeColor', 'none');
        case 'Bolt'
            t = linspace(0, 2*pi, 7); Xh = 15*cos(t); Yh = 15*sin(t);
            fill3(ax_3d, Xh, Yh, zeros(size(Xh)), [0.6 0.6 0.6]); 
            fill3(ax_3d, Xh, Yh, ones(size(Xh))*10, [0.6 0.6 0.6]);
            for i=1:6, fill3(ax_3d, [Xh(i) Xh(i+1) Xh(i+1) Xh(i)], [Yh(i) Yh(i+1) Yh(i+1) Yh(i)], [0 0 10 10], [0.5 0.5 0.5]); end
            [X, Y, Z] = cylinder([8 8], 20); Z = Z * -50;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
    end
    view(ax_3d, 3); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
end
