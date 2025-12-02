clearvars; close all; clc;

%% 1. CARICAMENTO DATI
filename = 'dati_convergenza_2025-11-26_15-50-10.csv'; 

if ~isfile(filename)
    if isfile(['Relazione/E1/', filename])
        filename = ['Relazione/E1/', filename];
    else
        error('File %s non trovato. Verifica il percorso.', filename);
    end
end

opts = detectImportOptions(filename);
T = readtable(filename, opts);

% --- TUA CONFIGURAZIONE SCELTA ---
my_WS = 600;
my_AR = 9;
my_M = 0.76;
my_tc = 0.10;
my_sweep = 20;
my_lambda = 0.23;

idx_me = find(T.W_S == my_WS & T.AR == my_AR & abs(T.M - my_M) < 0.01 & ...
              T.t_c == my_tc & T.sweep25 == my_sweep & abs(T.lambda - my_lambda) < 0.01, 1);

if isempty(idx_me)
    error('Configurazione SCELTA non trovata!');
end
row_me = T(idx_me, :);

%% 2. SETTAGGIO GRAFICI
figure('Name', 'Analisi Trade-Off con Valori', 'Color', 'w', 'Position', [100 100 1300 500]);

%% CONFRONTO A: Carico Alare (W/S 600 vs 650)
idx_ws650 = find(T.W_S == 650 & T.AR == my_AR & abs(T.M - my_M) < 0.01 & ...
                 T.t_c == my_tc & T.sweep25 == my_sweep & abs(T.lambda - my_lambda) < 0.01, 1);

if ~isempty(idx_ws650)
    row_A = T(idx_ws650, :);
    subplot(1, 3, 1);
    data_A = [row_A.WTO, row_A.W_block_fuel; row_me.WTO, row_me.W_block_fuel];
    bA = bar(data_A, 'grouped');
    
    set(gca, 'XTickLabel', {'W/S 650', 'W/S 600'}, 'FontWeight', 'bold', 'FontSize', 12);
    title('Carico Alare');
    legend({'MTOW', 'Fuel'}, 'Location', 'north');
    grid on; ylim([0 9e4*1.05]); % Più spazio in alto per le label
    
    % Aggiunta Etichette Numeriche
    for k = 1:length(bA)
        xtips = bA(k).XEndPoints;
        ytips = bA(k).YEndPoints;
        labels = string(round(bA(k).YData));
        text(xtips, ytips, labels, 'HorizontalAlignment','center', ...
            'VerticalAlignment','bottom', 'FontSize', 12, 'FontWeight', 'bold');
    end
end

%% CONFRONTO B: Freccia (20 vs 25) a parità di Mach 0.76
idx_sw25 = find(T.W_S == my_WS & T.AR == my_AR & abs(T.M - my_M) < 0.01 & ...
                T.t_c == my_tc & T.sweep25 == 25 & abs(T.lambda - my_lambda) < 0.01, 1);

if ~isempty(idx_sw25)
    row_B = T(idx_sw25, :);
    subplot(1, 3, 2);
    
    % Stacked: OEW (Sotto) + Fuel (Sopra)
    data_B = [row_B.OEW, row_B.W_block_fuel; row_me.OEW, row_me.W_block_fuel];
    bB = bar(data_B, 'stacked');
    
    set(gca, 'XTickLabel', {'\Lambda=25^\circ', '\Lambda=20^\circ'}, 'FontWeight', 'bold', 'FontSize', 12);
    title('Freccia (M=0.76)');
    legend({'Struttura', 'Fuel'}, 'Location', 'north');
    grid on; ylim([0 (row_B.OEW + row_B.W_block_fuel)*1.15]);
    
    % Etichette per Stacked Bar
    % 1. Valore Struttura (in mezzo alla barra blu)
    xtips = bB(1).XEndPoints;
    ytips_struct = bB(1).YEndPoints / 2;
    labels_struct = string(round(bB(1).YData));
    text(xtips, ytips_struct, labels_struct, 'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 2. Valore Fuel (in mezzo alla barra arancione)
    ytips_fuel = bB(1).YEndPoints + (bB(2).YData / 2);
    labels_fuel = string(round(bB(2).YData));
    text(xtips, ytips_fuel, labels_fuel, 'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 3. Totale MTOW (Sopra la barra)
    ytips_tot = bB(2).YEndPoints;
    labels_tot = string(round(ytips_tot));
    text(xtips, ytips_tot, labels_tot, 'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', 'FontSize', 12, 'FontWeight', 'bold');
end

%% CONFRONTO C: "BEST" HIGH SPEED (M > 0.78)
idx_fast_candidates = find(T.M > 0.78); 

if ~isempty(idx_fast_candidates)
    candidates = T(idx_fast_candidates, :);
    [~, best_idx_local] = min(candidates.W_block_fuel); 
    row_C = candidates(best_idx_local, :);
    
    subplot(1, 3, 3);
    data_C = [row_C.WTO, row_C.W_block_fuel; row_me.WTO, row_me.W_block_fuel];
    bC = bar(data_C, 'grouped');
    
    lbl_fast = sprintf('M=%.2f, \\Lambda=%.0f^\\circ', row_C.M, row_C.sweep25);
    set(gca, 'XTickLabel', {lbl_fast, 'M=0.76'}, 'FontWeight', 'bold', 'FontSize', 12);
    title('Confronto Alta Velocità');
    legend({'MTOW', 'Fuel'}, 'Location', 'north');
    grid on; ylim([0 9e4*1.05]);
    
    % Aggiunta Etichette Numeriche
    for k = 1:length(bC)
        xtips = bC(k).XEndPoints;
        ytips = bC(k).YEndPoints;
        labels = string(round(bC(k).YData));
        text(xtips, ytips, labels, 'HorizontalAlignment','center', ...
            'VerticalAlignment','bottom', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    % Evidenzia la differenza di Fuel in rosso
    delta_fuel = row_C.W_block_fuel - row_me.W_block_fuel;
    text(1.15, row_C.W_block_fuel*0.9, sprintf('+%.0f kg', delta_fuel), ...
        'Color','b', 'FontWeight','bold', 'FontSize', 11, 'HorizontalAlignment','center');
end

% sgtitle('Analisi comparativa: Valori esatti [kg]');