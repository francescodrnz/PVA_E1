clearvars; close all; clc;

%% 1. CARICAMENTO DATI
% Cerca il file CSV più recente o usa quello specifico
filename = 'dati_convergenza_2025-11-26_15-50-10.csv'; 
if ~isfile(filename)
    % Fallback se il file non è nella cartella corrente
    files = dir('**/*dati_convergenza_*.csv');
    if ~isempty(files)
        [~, idx] = sort([files.datenum], 'descend');
        filename = fullfile(files(idx(1)).folder, files(idx(1)).name);
        fprintf('File trovato: %s\n', filename);
    else
        error('File CSV non trovato.');
    end
end

opts = detectImportOptions(filename);
T = readtable(filename, opts);

%% 2. IDENTIFICAZIONE DELLE CONFIGURAZIONI

% A. La tua configurazione scelta
my_WS = 600;
my_AR = 9;
my_M = 0.76;
my_tc = 0.10;
my_sweep = 20; % Attenzione: nel codice usavi 20, nel csv potrebbe essere 25. Adatto la ricerca.
my_lambda = 0.23;

% Filtro per trovare la tua configurazione (tolleranza per i float)
idx_me = find(abs(T.W_S - my_WS) < 1 & ...
              abs(T.AR - my_AR) < 0.1 & ...
              abs(T.M - my_M) < 0.01 & ...
              abs(T.t_c - my_tc) < 0.01 & ...
              abs(T.lambda - my_lambda) < 0.01, 1);

% Se non la trova con sweep 20, prova con 25 o cerca la più vicina
if isempty(idx_me)
    warning('Configurazione esatta non trovata. Cerco la più vicina...');
    % Cerca solo per W/S, AR, M e t/c
     idx_me = find(abs(T.W_S - my_WS) < 1 & abs(T.AR - my_AR) < 0.1 & abs(T.M - my_M) < 0.01, 1);
end

if isempty(idx_me)
    error('Impossibile trovare la configurazione di riferimento.');
end

row_me = T(idx_me, :);

% B. Ottimo Globale DOC (Minimo Costo Operativo)
[~, idx_min_doc] = min(T.DOC);
row_min_doc = T(idx_min_doc, :);

% C. Ottimo Globale MTOW (Minimo Peso al Decollo)
[~, idx_min_wto] = min(T.WTO);
row_min_wto = T(idx_min_wto, :);

% D. Ottimo Globale Fuel (Minimo Consumo)
[~, idx_min_fuel] = min(T.W_block_fuel);
row_min_fuel = T(idx_min_fuel, :);

% E. Migliore Alta Velocità (M >= 0.80 con minimo DOC)
idx_high_speed = find(T.M > 0.80);
[~, relative_idx] = min(T.DOC(idx_high_speed));
idx_best_fast = idx_high_speed(relative_idx);
row_fast = T(idx_best_fast, :);

%% 3. CREAZIONE GRAFICO COMPARATIVO NORMALIZZATO

% Metriche da confrontare
metrics = {'WTO', 'W_block_fuel', 'DOC', 'PREE'};
labels = {'MTOW', 'Block Fuel', 'DOC', 'Efficienza (PREE)'};

% Estrazione valori
vals_me   = [row_me.WTO, row_me.W_block_fuel, row_me.DOC, row_me.PREE];
vals_doc  = [row_min_doc.WTO, row_min_doc.W_block_fuel, row_min_doc.DOC, row_min_doc.PREE];
vals_wto  = [row_min_wto.WTO, row_min_wto.W_block_fuel, row_min_wto.DOC, row_min_wto.PREE];
vals_fuel = [row_min_fuel.WTO, row_min_fuel.W_block_fuel, row_min_fuel.DOC, row_min_fuel.PREE];
vals_fast = [row_fast.WTO, row_fast.W_block_fuel, row_fast.DOC, row_fast.PREE];

% Normalizzazione rispetto alla TUA configurazione (Tua = 1.0)
norm_me   = vals_me ./ vals_me;
norm_doc  = vals_doc ./ vals_me;
norm_wto  = vals_wto ./ vals_me;
norm_fuel = vals_fuel ./ vals_me;
norm_fast = vals_fast ./ vals_me;

% Raggruppamento dati per il grafico
plot_data = [norm_me; norm_doc; norm_wto; norm_fuel; norm_fast]';

% Plot
figure('Name', 'Confronto Ottimizzato', 'Color', 'w', 'Position', [100, 100, 1000, 600]);
b = bar(plot_data);

% Stile
set(gca, 'XTickLabel', labels, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Valore Normalizzato (Scelta = 1.0)');
title('Confronto Configurazione Scelta vs Ottimi Globali', 'FontSize', 14);
yline(1, '--k', 'HandleVisibility', 'off'); % Linea di riferimento
grid on;
ylim([0.9 1.1]); % Focus sulle differenze

% Legenda con dettagli
legend_str = {
    sprintf('Scelta (M=%.2f, W/S=%d)', row_me.M, row_me.W_S), ...
    sprintf('Min DOC (M=%.2f, W/S=%d)', row_min_doc.M, row_min_doc.W_S), ...
    sprintf('Min MTOW (M=%.2f, W/S=%d)', row_min_wto.M, row_min_wto.W_S), ...
    sprintf('Min Fuel (M=%.2f, W/S=%d)', row_min_fuel.M, row_min_fuel.W_S), ...
    sprintf('Best Fast (M=%.2f, W/S=%d)', row_fast.M, row_fast.W_S)
};
legend(legend_str, 'Location', 'northeast', 'FontSize', 10);

% Aggiunta valori percentuali sopra le barre (opzionale, per chiarezza)
for i = 1:length(b)
    xtips = b(i).XEndPoints;
    ytips = b(i).YEndPoints;
    for j = 1:length(xtips)
        val = plot_data(j,i);
        if abs(val - 1) > 0.001 % Mostra solo se diverso da 1
            pct = (val - 1) * 100;
            text(xtips(j), ytips(j), sprintf('%+.1f%%', pct), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', 'FontSize', 9);
        end
    end
end

% Salvataggio immagine
saveas(gcf, 'confronto_ottimizzato.png');
fprintf('Grafico salvato come confronto_ottimizzato.png\n');