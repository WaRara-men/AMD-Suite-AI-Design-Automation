% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v3.6
% Bug Fix: Dot Indexing & Empty Solutions
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Load Data & Optimize ---
    case_width = 150; 
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    
    % Initialize all_solutions as an empty struct array to avoid indexing errors
    all_solutions = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        valid_idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(valid_idx)
            sol.Material = string(materials{i});
            sol.T = mat_data.Thickness(valid_idx);
            sol.PartNo = string(mat_data.PartNumber{valid_idx});
            sol.Price = mat_data.Price_JPY(valid_idx);
            sol.Weight = (case_width * 2) * sol.T * mat_data.Density(valid_idx);
            all_solutions(end+1) = sol; % Standard struct array append
        end
    end

    % --- 2. Decision Making (Safe version) ---
    if isempty(all_solutions)
        msgbox('No material found for this load! / 条件に合う素材が見つかりません', 'AMD Error');
        return;
    end

    feasible_sols = all_solutions([all_solutions.Price] <= budget_limit);
    
    if isempty(feasible_sols)
        % No solution within budget, pick the cheapest overall
        [~, b_idx] = min([all_solutions.Price]);
        final_sol = all_solutions(b_idx);
        fprintf('⚠️ [AI] Over budget! Picked cheapest: %s\n', final_sol.Material);
    else
        % Lightest among within budget
        [~, b_idx] = min([feasible_sols.Weight]);
        final_sol = feasible_sols(b_idx);
    end

    % --- 3. History Logging ---
    history_file = fullfile(output_dir, 'design_history.csv');
    new_entry = table(datetime('now'), target_load, budget_limit, safety_factor, ...
        final_sol.Material, final_sol.Weight, final_sol.Price, ...
        'VariableNames', {'Timestamp', 'Load', 'Budget', 'SF', 'Material', 'Weight', 'Price'});
    
    if exist(history_file, 'file')
        history_table = readtable(history_file);
        history_table = [history_table; new_entry];
    else
        history_table = new_entry;
    end
    writetable(history_table, history_file);

    % --- 4. Sensitivity Analysis Plot ---
    load_range = linspace(target_load*0.5, target_load*1.5, 10);
    fig = figure('Visible', 'off'); hold on;
    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        w_trend = [];
        for l = load_range
            t_req = (l / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
            v_idx = find(mat_data.Thickness >= t_req, 1, 'first');
            if ~isempty(v_idx), w_trend(end+1) = (case_width*2) * mat_data.Thickness(v_idx) * mat_data.Density(v_idx);
            else w_trend(end+1) = NaN; end
        end
        plot(load_range, w_trend, '-o', 'DisplayName', char(materials{i}), 'LineWidth', 1.5);
    end
    xline(target_load, '--k', 'Current', 'LabelVerticalAlignment', 'bottom');
    grid on; xlabel('Load [kg]'); ylabel('Weight [kg]'); title('Sensitivity Analysis');
    legend('Location', 'best');
    graph_path = fullfile(output_dir, 'sensitivity_plot.png');
    saveas(fig, graph_path); close(fig);

    % --- 5. Save Results (Nerve) ---
    T_bridge = cell2table({final_sol.T, char(final_sol.Material), final_sol.Price}, ...
        'VariableNames', {'Thickness', 'Material', 'Price'});
    writetable(T_bridge, fullfile(output_dir, 'Bridge_Nerve.csv'));
    
    % --- 6. Report Generation ---
    report_name = 'AMD_Decision_Report.docx';
    report_path = fullfile(output_dir, report_name);
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.Font.Size = 20; selection.Font.Bold = 1;
        selection.TypeText('AMD Design Insights Report'); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0;
        selection.TypeText(sprintf('Best Choice: %s (Weight: %.3f kg)', final_sol.Material, final_sol.Weight));
        selection.TypeParagraph;
        selection.InlineShapes.AddPicture(graph_path);
        doc.SaveAs2(report_path); doc.Close; word.Quit;
        fprintf('✅ [REPORT] Generated: %s\n', report_path);
    catch
        if exist('word', 'var'), word.Quit; end
    end

    box_path = fullfile(getenv('USERPROFILE'), 'Box', 'AMD_Reports');
    if exist(box_path, 'dir'), copyfile(report_path, fullfile(box_path, report_name)); end
    
    msgbox(['Analysis Complete!', newline, 'Winner: ', char(final_sol.Material)], 'AMD Suite Status');
end
