% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v23.4
% UNSINKABLE 3D ENGINE: Forced View & Lighting
% ==========================================
function AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit)
    % --- 📊 Graph: Ranking Refresh ---
    cla(ax_bar, 'reset');
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, vals = catalog.Torque_Nm;
        case 'Power', vals = catalog.Capacity_mAh;
        case 'Bolt', vals = catalog.MaxShear_N;
    end
    bar(ax_bar, vals, 'FaceColor', [0.2 0.2 0.2]); hold(ax_bar, 'on');
    bar(ax_bar, b_idx, vals(b_idx), 'FaceColor', [1.0 0.5 0.0]);
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w', 'XTickLabelRotation', 30);
    ylabel(ax_bar, sprintf('%s [%s]', m_name, m_unit), 'Color', 'w');

    % --- 💎 3D: Forced Perspective Rendering ---
    cla(ax_3d, 'reset'); % Clear everything including axes settings
    hold(ax_3d, 'on');
    
    switch mode
        case 'Arm'
            len = inputs(2); rad = inputs(3);
            [X, Y, Z] = cylinder([rad rad], 20); Z = Z * len;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); w_s = 20 + rad;
            surf(ax_3d, Xm*w_s+len, Ym*w_s, Zm*w_s, 'FaceColor', [1.0 0.4 0.0], 'EdgeColor', 'none');
        case 'Lift'
            p_rad = inputs(2); 
            [X, Y, Z] = cylinder([p_rad p_rad], 20); Z = Z * 15;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.2 0.5 1.0], 'EdgeColor', 'none');
            plot3(ax_3d, [p_rad p_rad], [0 0], [0 -150], 'w', 'LineWidth', 2);
            [Xb, Yb, Zb] = meshgrid([-25 25], [-25 25], [-180 -130]);
            Kb = convhull(Xb(:), Yb(:), Zb(:));
            trisurf(Kb, Xb(:), Yb(:), Zb(:), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none', 'Parent', ax_3d);
        case 'Mobile'
            inc = inputs(3); w_rad = inputs(2); L = 300; H = L * tan(inc*pi/180);
            fill3(ax_3d, [0 L L 0], [80 80 -80 -80], [0 H H 0], [0.3 0.3 0.3]); 
            [X, Y, Z] = cylinder([w_rad w_rad], 20);
            surf(ax_3d, X+L/2, Z*40-20, Y+H/2+w_rad, 'FaceColor', [0.8 0.1 0.1], 'EdgeColor', 'none');
        case 'Power'
            v = [-60 -35 0; 60 -35 0; 60 35 0; -60 35 0; -60 -35 50; 60 -35 50; 60 35 50; -60 35 50];
            f = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.1 0.7 0.2], 'EdgeColor', 'k');
        case 'Bolt'
            [X, Y, Z] = cylinder([12 12], 20); Z = Z * 60;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
            t = linspace(0, 2*pi, 7);
            fill3(ax_3d, 25*cos(t), 25*sin(t), ones(size(t))*60, [0.6 0.6 0.6]); 
    end
    
    % 🌟 FORCED 3D VIEW SETTINGS
    grid(ax_3d, 'on');
    view(ax_3d, 45, 30); % Fixed 3D angle
    axis(ax_3d, 'tight');
    axis(ax_3d, 'equal');
    camlight(ax_3d, 'headlight');
    material(ax_3d, 'shiny');
    set(ax_3d, 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
end
