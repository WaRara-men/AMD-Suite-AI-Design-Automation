% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v22.0
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
    bar(ax_bar, b_idx, vals(b_idx), 'FaceColor', [1.0 0.5 0.0]); % Winner
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w', 'XTickLabelRotation', 30);
    ylabel(ax_bar, sprintf('%s [%s]', m_name, m_unit), 'Color', 'w');

    % --- 💎 3D: Hyper-Realistic Robotics Preview ---
    cla(ax_3d, 'reset'); hold(ax_3d, 'on');
    switch mode
        case 'Arm'
            len = inputs(2); rad = inputs(3);
            [X, Y, Z] = cylinder([rad rad], 20); Z = Z * len;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); w_s = 20 + rad;
            surf(ax_3d, Xm*w_s+len, Ym*w_s, Zm*w_s, 'FaceColor', [1.0 0.4 0.0], 'EdgeColor', 'none'); % Payload
            text(ax_3d, len, 0, w_s+30, 'ROBOT ARM', 'Color', 'w', 'FontWeight', 'bold');
        case 'Lift'
            p_rad = inputs(2); load_m = inputs(1);
            % Pulley (Blue Wheel)
            [X, Y, Z] = cylinder([p_rad p_rad], 20); Z = Z * 15;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.2 0.5 1.0], 'EdgeColor', 'none');
            % Rope (White Line)
            plot3(ax_3d, [p_rad p_rad], [0 0], [0 -150], 'w', 'LineWidth', 2);
            % Lifting Box (Orange)
            b_s = 15 + load_m; % Size based on load
            [Xb, Yb, Zb] = meshgrid([p_rad-b_s p_rad+b_s], [-b_s b_s], [-150-b_s -150+b_s]);
            Kb = convhull(Xb(:), Yb(:), Zb(:));
            trisurf(Kb, Xb(:), Yb(:), Zb(:), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none', 'Parent', ax_3d);
            text(ax_3d, p_rad, 0, -50, 'LIFTING STAGE', 'Color', 'w', 'FontWeight', 'bold');
        case 'Mobile'
            inc = inputs(3); w_rad = inputs(2);
            L = 300; H = L * tan(inc*pi/180);
            % Sliding Slope (Dark Gray)
            fill3(ax_3d, [0 L L 0], [80 80 -80 -80], [0 H H 0], [0.3 0.3 0.3]);
            % Red Tire
            [X, Y, Z] = cylinder([w_rad w_rad], 20);
            surf(ax_3d, X+L/2, Z*30-15, Y+H/2+w_rad, 'FaceColor', [0.8 0.1 0.1], 'EdgeColor', 'none');
            text(ax_3d, L/2, 0, H/2+w_rad+50, 'MOBILE BASE', 'Color', 'w', 'FontWeight', 'bold');
        case 'Power'
            v = [0 0 0; 120 0 0; 120 70 0; 0 70 0; 0 0 50; 120 0 50; 120 70 50; 0 70 50];
            f = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.1 0.7 0.2], 'EdgeColor', 'k');
            text(ax_3d, 60, 35, 60, 'POWER SYSTEM', 'Color', 'w', 'HorizontalAlignment', 'center');
        case 'Bolt'
            [X, Y, Z] = cylinder([10 10], 20); Z = Z * -70;
            surf(ax_3d, X, Y, Z, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
            t = linspace(0, 2*pi, 7);
            fill3(ax_3d, 20*cos(t), 20*sin(t), zeros(size(t)), [0.6 0.6 0.6]);
            text(ax_3d, 0, 0, 30, 'BOLT & JOINT', 'Color', 'w', 'HorizontalAlignment', 'center');
    end
    view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal');
    camlight(ax_3d, 'headlight'); material(ax_3d, 'shiny');
end
