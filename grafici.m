close all;clc;clearvars;
data = loadMostRecentCSV();
W_S_vect = unique(data.W_S);
AR_vect = unique(data.AR);
sweep25_vect = unique(data.sweep25);
t_c_vect = unique(data.t_c);
M_vect = unique(data.M);

% spinta installata = f(block fuel)
figure;
hold on;

cmap = lines(length(W_S_vect)); % colori

for i = 1:length(W_S_vect)
    idx = data.W_S == W_S_vect(i);
    
    % Scatter plot
    scatter(data.W_block_fuel(idx), data.T(idx), 50, cmap(i, :), 'filled', ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
    
    % Verifica che ci siano abbastanza dati per la regressione
    if sum(idx) > 1 % Assicurati di avere più di un dato per fare la regressione
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.W_block_fuel(idx), data.T(idx), 1); % Regressione lineare
        block_fuel_fit = linspace(min(data.W_block_fuel(idx)), max(data.W_block_fuel(idx)), 100);
        T_fit = polyval(coeffs, block_fuel_fit);
        
        % Disegna la linea di tendenza (tratteggiata)
        plot(block_fuel_fit, T_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend W_S = %d', W_S_vect(i)));
    end
end

xlabel('Block Fuel [kg]');
ylabel('Spinta Installata [kg]');
title('Spinta Installata vs Block Fuel suddivisa per W/S');
legend('Location', 'best');
grid on;
hold off;

%% block fuel = f(MTOW)
figure;
hold on;

for i = 1:length(W_S_vect)
    idx = (data.W_S == W_S_vect(i)); % Trova i dati per W_S specifico
    if any(idx) % Controlla se ci sono dati validi per questo W_S
        % Scatter plot
        scatter(data.WTO(idx), data.W_block_fuel(idx), 50, cmap(i, :), 'filled', ...
            'DisplayName', sprintf('W/S = %d', W_S_vect(i)));
        
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.WTO(idx), data.W_block_fuel(idx), 1); % Regressione lineare
        WTO_fit = linspace(min(data.WTO(idx)), max(data.WTO(idx)), 100);
        block_fuel_fit = polyval(coeffs, WTO_fit);
        
        % Disegna la linea di tendenza
        plot(WTO_fit, block_fuel_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend W/S = %d', W_S_vect(i)));
    end
end

% Aggiungere etichette e legenda
xlabel('WTO [kg]');
ylabel('Block Fuel [kg]');
title('Block Fuel vs WTO suddivisa per W/S');
legend('Location', 'best');
grid on;
hold off;

%% block fuel = f(AR)

figure;
hold on;

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie e deviazione standard
    mean_block_fuel = zeros(size(AR_vect));
    std_block_fuel = zeros(size(AR_vect));
    
    for j = 1:length(AR_vect)
        % Filtra i dati per il valore specifico di AR
        idx_AR = data.AR == AR_vect(j);
        idx = idx_W_S & idx_AR;
        
        % Calcola media e deviazione standard
        mean_block_fuel(j) = mean(data.W_block_fuel(idx));
        std_block_fuel(j) = std(data.W_block_fuel(idx));
    end
    
    % Grafico della media con barra d'errore (std)
    errorbar(AR_vect, mean_block_fuel, std_block_fuel, '-o', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 7, ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
end
% Aggiungi etichette e legenda
xlabel('Aspect Ratio', 'FontSize', 12);
ylabel('Mean Block Fuel (kg)', 'FontSize', 12);
title('Mean Block Fuel vs Aspect Ratio per diversi valori di W_S', 'FontSize', 14);
legend('show', 'Location', 'best');
grid on;
hold off;

%% block fuel, MTOW = f(sweep25)

figure;
hold on;

yyaxis left; % Primo asse Y (per il Block Fuel)
ylabel('Mean Block Fuel (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie e deviazione standard (Block Fuel)
    mean_block_fuel = zeros(size(sweep25_vect));
    std_block_fuel = zeros(size(sweep25_vect));
    
    for j = 1:length(sweep25_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_sweep25 = data.sweep25 == sweep25_vect(j);
        idx = idx_W_S & idx_sweep25;
        
        % Calcola media e deviazione standard
        mean_block_fuel(j) = mean(data.W_block_fuel(idx));
        std_block_fuel(j) = std(data.W_block_fuel(idx));
    end
    
    % Grafico della media con barra d'errore (Block Fuel)
    errorbar(sweep25_vect, mean_block_fuel, std_block_fuel, '-o', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 7, ...
        'DisplayName', sprintf('Block Fuel W_S = %d', W_S_vect(i)));
end

% Secondo asse Y (per il WTO)
yyaxis right;
ylabel('Mean WTO (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie WTO
    mean_WTO = zeros(size(sweep25_vect));
    
    for j = 1:length(sweep25_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_sweep25 = data.sweep25 == sweep25_vect(j);
        idx = idx_W_S & idx_sweep25;
        
        % Calcola la media di WTO
        mean_WTO(j) = mean(data.WTO(idx));
    end
    
    % Grafico della media WTO
    plot(sweep25_vect, mean_WTO, '--s', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 6, ...
        'DisplayName', sprintf('WTO W_S = %d', W_S_vect(i)));
end

% Aggiungi etichette e titolo
xlabel('Angolo di Freccia (°)', 'FontSize', 12);
title('Mean Block Fuel e WTO vs Angolo di Freccia per diversi valori di W_S', 'FontSize', 14);

% Aggiungi legenda unica
legend('show', 'Location', 'best');
grid on;
hold off;

%% block fuel, MTOW = f(t_c)

figure;
hold on;

yyaxis left; % Primo asse Y (per il Block Fuel)
ylabel('Mean Block Fuel (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie e deviazione standard (Block Fuel)
    mean_block_fuel = zeros(size(t_c_vect));
    std_block_fuel = zeros(size(t_c_vect));
    
    for j = 1:length(t_c_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_t_c = data.t_c == t_c_vect(j);
        idx = idx_W_S & idx_t_c;
        
        % Calcola media e deviazione standard
        mean_block_fuel(j) = mean(data.W_block_fuel(idx));
        std_block_fuel(j) = std(data.W_block_fuel(idx));
    end
    
    % Grafico della media con barra d'errore (Block Fuel)
    errorbar(t_c_vect, mean_block_fuel, std_block_fuel, '-o', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 7, ...
        'DisplayName', sprintf('Block Fuel W_S = %d', W_S_vect(i)));
end

% Secondo asse Y (per il WTO)
yyaxis right;
ylabel('Mean WTO (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie WTO
    mean_WTO = zeros(size(t_c_vect));
    
    for j = 1:length(t_c_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_t_c = data.t_c == t_c_vect(j);
        idx = idx_W_S & idx_t_c;
        
        % Calcola la media di WTO
        mean_WTO(j) = mean(data.WTO(idx));
    end
    
    % Grafico della media WTO
    plot(t_c_vect, mean_WTO, '--s', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 6, ...
        'DisplayName', sprintf('WTO W_S = %d', W_S_vect(i)));
end

% Aggiungi etichette e titolo
xlabel('Spessore ala', 'FontSize', 12);
title('Mean Block Fuel e WTO vs spessore alare per diversi valori di W_S', 'FontSize', 14);

% Aggiungi legenda unica
legend('show', 'Location', 'best');
grid on;
hold off;

%% block fuel, MTOW = f(M)

figure;
hold on;

yyaxis left; % Primo asse Y (per il Block Fuel)
ylabel('Mean Block Fuel (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie e deviazione standard (Block Fuel)
    mean_block_fuel = zeros(size(M_vect));
    std_block_fuel = zeros(size(M_vect));
    
    for j = 1:length(M_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_M = data.M == M_vect(j);
        idx = idx_W_S & idx_M;
        
        % Calcola media e deviazione standard
        mean_block_fuel(j) = mean(data.W_block_fuel(idx));
        std_block_fuel(j) = std(data.W_block_fuel(idx));
    end
    
    % Grafico della media con barra d'errore (Block Fuel)
    errorbar(M_vect, mean_block_fuel, std_block_fuel, '-o', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 7, ...
        'DisplayName', sprintf('Block Fuel W_S = %d', W_S_vect(i)));
end

% Secondo asse Y (per il WTO)
yyaxis right;
ylabel('Mean WTO (kg)', 'FontSize', 12);

for i = 1:length(W_S_vect)
    % Filtra i dati per il valore specifico di W_S
    idx_W_S = data.W_S == W_S_vect(i);
    
    % Inizializza vettori per medie WTO
    mean_WTO = zeros(size(M_vect));
    
    for j = 1:length(M_vect)
        % Filtra i dati per il valore specifico di sweep25
        idx_M = data.M == M_vect(j);
        idx = idx_W_S & idx_M;
        
        % Calcola la media di WTO
        mean_WTO(j) = mean(data.WTO(idx));
    end
    
    % Grafico della media WTO
    plot(M_vect, mean_WTO, '--s', 'Color', cmap(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 6, ...
        'DisplayName', sprintf('WTO W_S = %d', W_S_vect(i)));
end

% Aggiungi etichette e titolo
xlabel('Mach di crociera', 'FontSize', 12);
title('Mean Block Fuel e WTO vs Mach di crociera per diversi valori di W_S', 'FontSize', 14);

% Aggiungi legenda unica
legend('show', 'Location', 'best');
grid on;
hold off;