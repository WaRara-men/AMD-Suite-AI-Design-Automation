% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.0
% Enterprise Edition: PDF Export & Dark UI
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
            all_solutions(end+1) = sol; 
        end
    end

    % --- 2. Decision Making ---
    if isempty(all_solutions)
        msgbox('No material found! / 条件に合う素材がありません', 'AMD Error', 'error');
        return;
    end

    feasible_sols = all_solutions([all_solutions.Price] <= budget_limit);
    if isempty(feasible_sols)
        [~, b_idx] = min([all_solutions.Price]);
        final_sol = all_solutions(b_idx);
        fprintf('⚠️ [AI] Over budget! Picked cheapest.\n');
    else
        [~, b_idx] = min([feasible_sols.Weight]);
        final_sol = feasible_sols(b_idx);
    end

    % --- 3. Sensitivity Plot (Dark Theme) ---
    load_range = linspace(target_load*0.5, target_load*1.5, 10);
    fig = figure('Visible', 'off', 'Color', [0.15 0.15 0.15]); 
    ax = axes(fig, 'Color', [0.2 0.2 0.2], 'XColor', 'w', 'YColor', 'w'); hold(ax, 'on');
    
    colors = lines(length(materials));
    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        w_trend = [];
        for l = load_range
            t_req = (l / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
            v_idx = find(mat_data.Thickness >= t_req, 1, 'first');
            if ~isempty(v_idx), w_trend(end+1) = (case_width*2) * mat_data.Thickness(v_idx) * mat_data.Density(v_idx);
            else w_trend(end+1) = NaN; end
        end
        plot(ax, load_range, w_trend, '-o', 'DisplayName', char(materials{i}), 'LineWidth', 2, 'Color', colors(i,:));
    end
    xline(ax, target_load, '--w', 'Current', 'LabelVerticalAlignment', 'bottom');
    grid(ax, 'on'); xlabel(ax, 'Load [kg]'); ylabel(ax, 'Weight [kg]'); 
    title(ax, 'Sensitivity Analysis', 'Color', 'w');
    legend(ax, 'Location', 'best', 'TextColor', 'w');
    graph_path = fullfile(output_dir, 'sensitivity_plot.png');
    saveas(fig, graph_path); close(fig);

    % --- 4. Reporting (Word -> PDF Export) ---
    T_bridge = cell2table({final_sol.T, char(final_sol.Material), final_sol.Price}, 'VariableNames', {'Thickness', 'Material', 'Price'});
    writetable(T_bridge, fullfile(output_dir, 'Bridge_Nerve.csv'));
    
    report_name = 'AMD_Decision_Report.docx';
    pdf_name = 'AMD_Decision_Report.pdf';
    report_path = fullfile(output_dir, report_name);
    pdf_path = fullfile(output_dir, pdf_name);
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.Font.Size = 24; selection.Font.Bold = 1;
        selection.TypeText('AMD Design Insights Report'); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0;
        selection.TypeText(sprintf('Best Choice: %s (Weight: %.3f kg, Price: %d JPY)', final_sol.Material, final_sol.Weight, final_sol.Price));
        selection.TypeParagraph;
        selection.InlineShapes.AddPicture(graph_path);
        
        if exist(report_path, 'file'), delete(report_path); end
        doc.SaveAs2(report_path); 
        
        % 🌟 EXPORT TO PDF (Format 17)
        if exist(pdf_path, 'file'), delete(pdf_path); end
        doc.SaveAs2(pdf_path, 17);
        
        doc.Close; word.Quit;
        fprintf('✅ [REPORT] DOCX and PDF Generated!\n');
    catch ME
        if exist('word', 'var'), word.Quit; end
        fprintf('❌ [REPORT] Error: %s\n', ME.message);
    end

    msgbox(['Analysis Complete!', newline, 'Exported as PDF.', newline, 'Winner: ', char(final_sol.Material)], 'AMD Suite v4.0');
end
