close all;clc;clearvars;
data = loadMostRecentCSV();
W_S_vect = unique(data.W_S);
AR_vect = unique(data.AR);
sweep25_vect = unique(data.sweep25);
t_c_vect = unique(data.t_c);
cmap = lines(length(t_c_vect)); % colori
M_vect = unique(data.M);

%% costi = f(block fuel)
% Normalizzazione delle variabili
DOC_norm = (data.DOC - min(data.DOC)) / (max(data.DOC) - min(data.DOC));
ADP_norm = (data.ADP - min(data.ADP)) / (max(data.ADP) - min(data.ADP));
PREE_norm = (data.PREE - min(data.PREE)) / (max(data.PREE) - min(data.PREE));
flight_cost_norm = (data.flight_cost - min(data.flight_cost)) / (max(data.flight_cost) - min(data.flight_cost));
maintenance_cost_norm = (data.maintenance_cost - min(data.maintenance_cost)) / (max(data.maintenance_cost) - min(data.maintenance_cost));

figure;
hold on;

% Scatter plot DOC normalizzato
scatter(data.W_block_fuel, DOC_norm, 25, 'r', 'filled', ...
    'DisplayName', 'DOC');

% Calcolo della linea di tendenza DOC normalizzato
coeffs_DOC = polyfit(data.W_block_fuel, DOC_norm, 1); % Regressione lineare
block_fuel_fit = linspace(min(data.W_block_fuel), max(data.W_block_fuel), 100);
DOC_fit = polyval(coeffs_DOC, block_fuel_fit);

% Disegna la linea di tendenza DOC normalizzato
plot(block_fuel_fit, DOC_fit, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend DOC');

% Scatter plot ADP normalizzato
scatter(data.W_block_fuel, ADP_norm, 25, 'g', 'filled', 'Marker', 'square', ...
    'DisplayName', 'ADP');

% Calcolo della linea di tendenza ADP normalizzato
coeffs_ADP = polyfit(data.W_block_fuel, ADP_norm, 1); % Regressione lineare
ADP_fit = polyval(coeffs_ADP, block_fuel_fit);

% Disegna la linea di tendenza ADP normalizzato
plot(block_fuel_fit, ADP_fit, 'g:', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend ADP');

% Scatter plot PREE normalizzato
scatter(data.W_block_fuel, PREE_norm, 25, 'b', 'filled', 'Marker', 'd', ...
    'DisplayName', 'PREE');

% Calcolo della linea di tendenza PREE normalizzato
coeffs_PREE = polyfit(data.W_block_fuel, PREE_norm, 1); % Regressione lineare
PREE_fit = polyval(coeffs_PREE, block_fuel_fit);

% Disegna la linea di tendenza PREE normalizzato
plot(block_fuel_fit, PREE_fit, 'b-.', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend PREE');

% Scatter plot flight cost normalizzato
scatter(data.W_block_fuel, flight_cost_norm, 25, 'm', 'filled', 'Marker', 'hexagram', ...
    'DisplayName', 'Flight Cost');

% Calcolo della linea di tendenza flight cost normalizzato
coeffs_flight_cost = polyfit(data.W_block_fuel, flight_cost_norm, 1); % Regressione lineare
flight_cost_fit = polyval(coeffs_flight_cost, block_fuel_fit);

% Disegna la linea di tendenza flight cost normalizzato
plot(block_fuel_fit, flight_cost_fit, 'm:', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend Flight Cost');

% Scatter plot maintenance cost normalizzato
scatter(data.W_block_fuel, maintenance_cost_norm, 25, 'k', 'filled', 'Marker', 'pentagram', ...
    'DisplayName', 'Maintenance Cost');

% Calcolo della linea di tendenza maintenance cost normalizzato
coeffs_maintenance_cost = polyfit(data.W_block_fuel, maintenance_cost_norm, 1); % Regressione lineare
maintenance_cost_fit = polyval(coeffs_maintenance_cost, block_fuel_fit);

% Disegna la linea di tendenza maintenance cost normalizzato
plot(block_fuel_fit, maintenance_cost_fit, 'k-.', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend Maintenance Cost');

% Aggiungere etichette e legenda
xlabel('Block Fuel [kg]', 'FontSize', 14); 
ylabel('DOC, ADP, PREE, Flight Cost, Maintenance Cost (Normalizzati)', 'FontSize', 14); 
ylim([0 1]);
title('Valori Normalizzati di DOC, ADP, PREE, Flight Cost, Maintenance Cost vs Block Fuel', 'FontSize', 16); 
legend('Location', 'best', 'FontSize', 12); 
grid on; 
set(gca, 'FontSize', 12);
hold off;

%% costi = f(MTOW)
% Normalizzazione delle variabili
DOC_norm = (data.DOC - min(data.DOC)) / (max(data.DOC) - min(data.DOC));
ADP_norm = (data.ADP - min(data.ADP)) / (max(data.ADP) - min(data.ADP));
PREE_norm = (data.PREE - min(data.PREE)) / (max(data.PREE) - min(data.PREE));
flight_cost_norm = (data.flight_cost - min(data.flight_cost)) / (max(data.flight_cost) - min(data.flight_cost));
maintenance_cost_norm = (data.maintenance_cost - min(data.maintenance_cost)) / (max(data.maintenance_cost) - min(data.maintenance_cost));


figure;
hold on;

% Scatter plot DOC normalizzato
scatter(data.WTO, DOC_norm, 25, 'r', 'filled', ...
    'DisplayName', 'DOC');

% Calcolo della linea di tendenza DOC normalizzato
coeffs_DOC = polyfit(data.WTO, DOC_norm, 1); % Regressione lineare
block_fuel_fit = linspace(min(data.WTO), max(data.WTO), 100);
DOC_fit = polyval(coeffs_DOC, block_fuel_fit);

% Disegna la linea di tendenza DOC normalizzato
plot(block_fuel_fit, DOC_fit, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend DOC');

% Scatter plot ADP normalizzato
scatter(data.WTO, ADP_norm, 25, 'g', 'filled', 'Marker', 'square', ...
    'DisplayName', 'ADP');

% Calcolo della linea di tendenza ADP normalizzato
coeffs_ADP = polyfit(data.WTO, ADP_norm, 1); % Regressione lineare
ADP_fit = polyval(coeffs_ADP, block_fuel_fit);

% Disegna la linea di tendenza ADP normalizzato
plot(block_fuel_fit, ADP_fit, 'g:', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend ADP');

% Scatter plot PREE normalizzato
scatter(data.WTO, PREE_norm, 25, 'b', 'filled', 'Marker', 'd', ...
    'DisplayName', 'PREE');

% Calcolo della linea di tendenza PREE normalizzato
coeffs_PREE = polyfit(data.WTO, PREE_norm, 1); % Regressione lineare
PREE_fit = polyval(coeffs_PREE, block_fuel_fit);

% Disegna la linea di tendenza PREE normalizzato
plot(block_fuel_fit, PREE_fit, 'b-.', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend PREE');

% Scatter plot flight cost normalizzato
scatter(data.WTO, flight_cost_norm, 25, 'm', 'filled', 'Marker', 'hexagram', ...
    'DisplayName', 'Flight Cost');

% Calcolo della linea di tendenza flight cost normalizzato
coeffs_flight_cost = polyfit(data.WTO, flight_cost_norm, 1); % Regressione lineare
flight_cost_fit = polyval(coeffs_flight_cost, block_fuel_fit);

% Disegna la linea di tendenza flight cost normalizzato
plot(block_fuel_fit, flight_cost_fit, 'm:', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend Flight Cost');

% Scatter plot maintenance cost normalizzato
scatter(data.WTO, maintenance_cost_norm, 25, 'k', 'filled', 'Marker', 'pentagram', ...
    'DisplayName', 'Maintenance Cost');

% Calcolo della linea di tendenza maintenance cost normalizzato
coeffs_maintenance_cost = polyfit(data.WTO, maintenance_cost_norm, 1); % Regressione lineare
maintenance_cost_fit = polyval(coeffs_maintenance_cost, block_fuel_fit);

% Disegna la linea di tendenza maintenance cost normalizzato
plot(block_fuel_fit, maintenance_cost_fit, 'k-.', 'LineWidth', 1.5, ...
    'DisplayName', 'Trend Maintenance Cost');

% Aggiungere etichette e legenda
xlabel('Maximum Take-Off Weight [kg]', 'FontSize', 14); 
ylabel('DOC, ADP, PREE, Flight Cost, Maintenance Cost (Normalizzati)', 'FontSize', 14); 
ylim([0 1]);
title('Valori Normalizzati di DOC, ADP, PREE, Flight Cost, Maintenance Cost vs MTOW', 'FontSize', 16); 
legend('Location', 'best', 'FontSize', 12); 
grid on; 
set(gca, 'FontSize', 12);
hold off;

%%
figure;
hold on;

for i = 1:length(t_c_vect)
    idx = (data.t_c == t_c_vect(i)); % Trova i dati per t_c specifico
    if any(idx) % Controlla se ci sono dati validi per questo t_c
        % Scatter plot
        scatter(data.WTO(idx), data.W_block_fuel(idx), 50, cmap(i, :), 'filled', ...
            'DisplayName', sprintf('t/c = %.2f°', t_c_vect(i)));
        
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.WTO(idx), data.W_block_fuel(idx), 1); % Regressione lineare
        WTO_fit = linspace(min(data.WTO(idx)), max(data.WTO(idx)), 100);
        block_fuel_fit = polyval(coeffs, WTO_fit);
        
        % Disegna la linea di tendenza
        logy(WTO_fit, block_fuel_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend t/c = %.2f°', t_c_vect(i)));
    end
end

% Aggiungere etichette e legenda
xlabel('Maximum Take-Off Weight [kg]', 'FontSize', 14);
xlim([8.25e4 11.2e4]);
ylabel('Block Fuel [kg]', 'FontSize', 14);
ylim([1.6e4 3.6e4]);
title('Block Fuel vs MTOW suddivisa per Spessore del Profilo', 'FontSize', 16);
legend('Location', 'best', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12); % Imposta la dimensione del font per gli assi
hold off;
