% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v19.0
% ==========================================
function AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit)
    % --- 📊 Ranking Graph ---
    cla(ax_bar);
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, vals = catalog.Torque_Nm;
        case 'Power', vals = catalog.Capacity_mAh;
        case 'Bolt', vals = catalog.MaxShear_N;
    end
    bar(ax_bar, vals, 'FaceColor', [0.2 0.2 0.2]); hold(ax_bar, 'on');
    bar(ax_bar, b_idx, vals(b_idx), 'FaceColor', [1.0 0.5 0.0]); % Winner
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w', 'XTickLabelRotation', 30);
    ylabel(ax_bar, sprintf('%s [%s]', m_name, m_unit), 'Color', 'w');
    title(ax_bar, sprintf('%s Ranking', mode), 'Color', 'w');

    % --- 💎 3D: Deep Mechanical Detail ---
    cla(ax_3d); hold(ax_3d, 'on');
    switch mode
        case 'Arm'
            len = inputs(2); rad = inputs(3);
            [X, Y, Z] = cylinder([rad rad], 20); Z = Z * len;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); w_s = 20 + rad;
            surf(ax_3d, Xm*w_s+len, Ym*w_s, Zm*w_s, 'FaceColor', [1.0 0.4 0.0], 'EdgeColor', 'none'); % Orange Payload
            text(ax_3d, len, 0, w_s+20, 'Payload', 'Color', 'w', 'FontWeight', 'bold');
        case 'Lift'
            p_rad = inputs(2);
            [X, Y, Z] = cylinder([p_rad p_rad], 20); Z = Z * 10;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none'); % Pulley
            plot3(ax_3d, [p_rad p_rad], [0 0], [0 -150], 'w', 'LineWidth', 2); % Rope
            [Xb, Yb, Zb] = meshgrid([p_rad-20 p_rad+20], [-20 20], [-180 -150]);
            Kb = convhull(Xb(:), Yb(:), Zb(:));
            trisurf(Kb, Xb(:), Yb(:), Zb(:), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none'); % Box
            text(ax_3d, p_rad, 0, -100, 'Lifting Box', 'Color', 'w');
        case 'Power'
            v = [0 0 0; 100 0 0; 100 60 0; 0 60 0; 0 0 40; 100 0 40; 100 60 40; 0 60 40];
            f = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.1 0.7 0.2], 'EdgeColor', 'k'); % Battery
            text(ax_3d, 50, 30, 50, 'Li-Po Battery', 'Color', 'w', 'HorizontalAlignment', 'center');
        case 'Bolt'
            [X, Y, Z] = cylinder([10 10], 20); Z = Z * -60;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
            t = linspace(0, 2*pi, 7);
            fill3(ax_3d, 18*cos(t), 18*sin(t), zeros(size(t)), [0.6 0.6 0.6]); % Bolt Head
            text(ax_3d, 0, 0, 20, 'Steel Bolt', 'Color', 'w', 'HorizontalAlignment', 'center');
        case 'Mobile'
            inc = inputs(3); L = 250; H = L * tan(inc*pi/180);
            fill3(ax_3d, [0 L L 0], [60 60 -60 -60], [0 H H 0], [0.3 0.3 0.3]); % Ground
            [X, Y, Z] = cylinder([30 30], 20);
            surf(ax_3d, X+L/2, Z*25-12, Y+H/2+30, 'FaceColor', [0.8 0.1 0.1], 'EdgeColor', 'none'); % Tire
            text(ax_3d, L/2, 0, H/2+80, sprintf('Incline: %d deg', inc), 'Color', 'w');
    end
    view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal');
    camlight(ax_3d, 'headlight'); material(ax_3d, 'shiny');
end
