% ==========================================
% Algo-Mech Designer (AMD) Suite - Visuals v13.0
% ==========================================
function AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, length, radius)
    % 1. 全モーター比較グラフの復元
    cla(ax_bar);
    bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.3 0.3 0.3]); hold(ax_bar, 'on');
    bar(ax_bar, b_idx, catalog.Torque_Nm(b_idx), 'FaceColor', [1.0 0.6 0.2]); % 勝者をオレンジに
    set(ax_bar, 'XTickLabel', catalog.PartName, 'XColor', 'w', 'YColor', 'w');
    ylabel(ax_bar, 'Torque [Nm]', 'Color', 'w');
    
    % 2. オレンジの錘付き3Dアームの復元
    cla(ax_3d);
    [X, Y, Z] = cylinder([radius radius], 20); Z = Z * length;
    surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); hold(ax_3d, 'on');
    [Xm, Ym, Zm] = sphere(20); 
    weight_size = 20 + radius; % 錘のサイズ調整
    Xm=Xm*weight_size + length; Ym=Ym*weight_size; Zm=Zm*weight_size;
    surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none'); % オレンジの錘！
    view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal');
    camlight(ax_3d); material(ax_3d, 'shiny');
end
