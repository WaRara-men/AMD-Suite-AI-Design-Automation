% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v17.0
% ==========================================
function AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit)
    % --- 📊 Graph: Dynamic Catalog Ranking ---
    cla(ax_bar);
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, vals = catalog.Torque_Nm;
        case 'Power', vals = catalog.Capacity_mAh;
        case 'Bolt', vals = catalog.MaxShear_N;
    end
    bar(ax_bar, vals, 'FaceColor', [0.2 0.2 0.2]); hold(ax_bar, 'on');
    bar(ax_bar, b_idx, vals(b_idx), 'FaceColor', [1.0 0.5 0.0]); % Winner in Orange
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w', 'XTickLabelRotation', 30);
    ylabel(ax_bar, sprintf('%s [%s]', m_name, m_unit), 'Color', 'w');
    title(ax_bar, [mode, ' Catalog Ranking'], 'Color', 'w');

    % --- 💎 3D: High-Definition Mechanical Previews ---
    cla(ax_3d); hold(ax_3d, 'on');
    switch mode
        case 'Arm'
            len = inputs(2); rad = inputs(3);
            [X, Y, Z] = cylinder([rad rad], 20); Z = Z * len;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); w_s = 20 + rad; % Big orange weight
            surf(ax_3d, Xm*w_s+len, Ym*w_s, Zm*w_s, 'FaceColor', [1.0 0.4 0.0], 'EdgeColor', 'none');
        case 'Lift'
            p_rad = inputs(2); % Pulley
            [X, Y, Z] = cylinder([p_rad p_rad], 20); Z = Z * 10;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
            plot3(ax_3d, [p_rad p_rad], [0 0], [0 -100], 'w', 'LineWidth', 2); % Rope
            [Xb, Yb, Zb] = meshgrid([p_rad-15 p_rad+15], [-15 15], [-130 -100]); % Lifting Box
            Kb = convhull(Xb(:), Yb(:), Zb(:));
            trisurf(Kb, Xb(:), Yb(:), Zb(:), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none', 'Parent', ax_3d);
        case 'Mobile'
            w_rad = inputs(2); inc = inputs(3); L = 200; H = L * tan(inc*pi/180);
            fill3(ax_3d, [0 L L 0], [50 50 -50 -50], [0 H H 0], [0.3 0.3 0.3]); % Ground
            [X, Y, Z] = cylinder([w_rad w_rad], 20);
            surf(ax_3d, X+L/2, Z*20-10, Y+H/2+w_rad, 'FaceColor', [0.8 0.1 0.1], 'EdgeColor', 'none'); % Tire
        case 'Power'
            v = [0 0 0; 100 0 0; 100 60 0; 0 60 0; 0 0 40; 100 0 40; 100 60 40; 0 60 40];
            f = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.1 0.7 0.3], 'EdgeColor', 'k');
        case 'Bolt'
            [X, Y, Z] = cylinder([8 8], 20); Z = Z * -50;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
            t = linspace(0, 2*pi, 7);
            fill3(ax_3d, 15*cos(t), 15*sin(t), zeros(size(t)), [0.6 0.6 0.6]);
    end
    view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal');
    camlight(ax_3d, 'headlight'); material(ax_3d, 'shiny');
end
