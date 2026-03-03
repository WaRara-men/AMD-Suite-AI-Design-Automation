% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.1
% Reliable Engine with Auto-Cleanup
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor)
    % --- 0. Precise Path Management ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    all_solutions = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i});
            sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx});
            sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx);
            all_solutions(end+1) = sol; 
        end
    end

    % --- 2. Decision Making ---
    feasible = all_solutions([all_solutions.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_solutions.Price]); final_sol = all_solutions(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 3. Output & Image Stamping ---
    graph_path = fullfile(output_dir, 'sensitivity_plot.png');
    fig = figure('Visible', 'off'); bar([all_solutions.Weight]); saveas(fig, graph_path); close(fig);
    
    T_bridge = cell2table({final_sol.T, char(final_sol.Material), final_sol.Price}, 'VariableNames', {'Thickness', 'Material', 'Price'});
    writetable(T_bridge, fullfile(output_dir, 'Bridge_Nerve.csv'));

    % --- 4. Reporting (PDF Export) ---
    report_path = fullfile(output_dir, 'AMD_Decision_Report.docx');
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.Font.Size = 18; selection.Font.Bold = 1;
        selection.TypeText('AMD Design Report (Auto-Generated)'); selection.TypeParagraph;
        selection.Font.Size = 11; selection.Font.Bold = 0;
        selection.TypeText(sprintf('Best: %s (Weight: %.3f kg)', final_sol.Material, final_sol.Weight));
        selection.TypeParagraph; selection.InlineShapes.AddPicture(graph_path);
        if exist(report_path, 'file'), delete(report_path); end
        doc.SaveAs2(report_path); 
        doc.SaveAs2(pdf_path, 17); % PDF Export
        doc.Close; word.Quit;
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 5. 🧹 Auto-Cleanup (Spring Cleaning) ---
    % Remove temporary files from root and src / ゴミファイルを一掃
    temp_patterns = {'*.asv', '*.m~', 'temp_*.*'};
    for p = 1:length(temp_patterns)
        delete(fullfile(project_root, temp_patterns{p}));
        delete(fullfile(src_dir, temp_patterns{p}));
    end
    
    msgbox(['Report Generated in /out!', newline, 'Winner: ', char(final_sol.Material)], 'AMD Suite');
end
