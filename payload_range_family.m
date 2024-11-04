clearvars;close all;clc;requisiti;dati;MTOW;
% Famiglia di aerei
configurations = [150, 180, 210, 210]; % Numero di passeggeri per ogni modello
crew_config = [5, 6, 7, 7]; % Numero di membri dell'equipaggio per ogni configurazione
colors = {'g', 'b', 'r', 'm'};
max_fuel_volume = [24000, 24000, 24000, 35000];

% Crea una nuova finestra di grafico
figure; 
hold on;

% Ciclo per ogni configurazione di aerei
for i = 1:length(configurations)
    
    % Aggiorna il numero di passeggeri e crew per ogni configurazione
    passeggeri = configurations(i);
    crew = crew_config(i);
    
    % Calcolo del peso del crew e dei passeggeri
    m_crew_payload = (passeggeri + crew) * peso_passeggero;
    
    % Calcoli preliminari (come prima)
    E_max = k_E * sqrt(AR / Swet_Sref);
    E_cruise = 0.866 * E_max;
    W4_W3 = exp(-(SFC_cruise * range) / (v_cruise * E_cruise)); % Cruise
    Wloiter1 = exp(-(SFC_loiter*loiter1)/(E_max)); %loiter1
    W8_W7 = exp(-(SFC_cruise * diversione) / (v_cruise * E_cruise)); % Diversion
    W10_W9 = exp(-(SFC_loiter * loiter2) / (E_max)); % Loiter2
    
    fuel_fraction = 1.05 * (1 - (W2_WTO * W3_W2 * W4_W3 * W5_W4 * Wloiter1 * W8_W7 * W10_W9));
    
    % Inizializza m_TO
    m_TO = 60000;
    difference = inf;
    iteration = 0;
    
    while difference > tolerance && iteration < max_iterations
        iteration = iteration + 1;
        m_empty_fraction = A * m_TO^C;
        m_TO_new = m_crew_payload / (1 - fuel_fraction - m_empty_fraction);
        difference = abs(m_TO_new - m_TO) / m_TO;
        m_TO = m_TO_new;
    end
    
    % Calcolo massimo carburante
    m_fuel_max = max_fuel_volume(i) * fuel_density;
    
    % Range C: punto con il massimo carico di carburante
    fuel_frac_max_fuel = m_fuel_max / m_TO;
    m_final_frac_max_fuel = 1 - fuel_frac_max_fuel / 1.05;
    range_C = -log(m_final_frac_max_fuel / (W2_WTO * W3_W2 * W5_W4 * W8_W7 * W10_W9)) * v_cruise * E_cruise / SFC_cruise;

    % Range D: punto con nessun payload
    m_TO_D = 2 * peso_passeggero + m_fuel_max + m_empty_fraction * m_TO;
    fuel_frac_D = m_fuel_max / m_TO_D;
    m_final_frac_D = 1 - fuel_frac_D / 1.05;
    range_D = -log(m_final_frac_D / (W2_WTO * W3_W2 * W5_W4 * W8_W7 * W10_W9)) * v_cruise * E_cruise / SFC_cruise;

    % Calcolo dei punti del grafico payload-range
    payload1 = passeggeri * peso_passeggero;
    range1 = 0;
    
    payload2 = passeggeri * peso_passeggero;
    range2 = range;
    
    payload3 = m_TO - (m_fuel_max + m_empty_fraction * m_TO + crew * peso_passeggero);
    range3 = range_C;
    
    payload4 = 0;
    range4 = range_D;
    
    % Dati del grafico
    payload = [payload1, payload2, payload3, payload4];
    range_vals = [range1, range2, range3, range4];
    
    % Traccia il grafico per ogni configurazione con il colore corrispondente
    plot(range_vals, payload, '-o', 'Color', colors{i}, 'LineWidth', 2);
end

% Aggiungi etichette e legende
xlabel('Range (km)');
ylabel('Payload (kg)');
title('Diagramma Payload-Range per la famiglia di aerei');
legend('150 passeggeri', '180 passeggeri', '210 passeggeri', '210 passeggeri (ER)');
grid on;
yticks(0:2000:20000); 
yticklabels(0:2000:20000); 
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
hold off;
