clearvars
clc

% Requisito
passeggeri = 180;
crew = 6;
range = 4500; % km
diversione = 700; % km
loiter = 0.5; % h
v_cruise = 835; % km/h

% Dati
peso_passeggero = 93; % kg
wingspan = 33.15;
wingarea = 122;
AR = wingspan^2 / wingarea;
Swet_Sref = 6.4;
k_E = 15.5;
A = 0.97;
C = -0.06;
SFC_loiter = 0.4; % Loiter SFC costante

W2_WTO = 0.97; % decollo
W3_W2 = 0.985; % climb
W5_W4 = 0.995; % atterraggio

% Calcoli
m_crew_payload = (passeggeri + crew) * peso_passeggero;
E_max = k_E * sqrt(AR / Swet_Sref);

W8_W7 = exp(-(SFC_loiter * diversione) / (v_cruise * 0.866 * E_max)); % diversion
W10_W9 = exp(-(SFC_loiter * loiter) / E_max); % loiter

tolerance = 1e-4;
max_iterations = 1000;

% Vettore SFC_cruise da 0.4 a 0.6 con step di 0.02
SFC_cruise_values = 0.4:0.02:0.6;
m_TO_values = zeros(size(SFC_cruise_values)); % Prealloca il vettore dei risultati

% Ciclo sui diversi valori di SFC_cruise
for i = 1:length(SFC_cruise_values)
    SFC_cruise = SFC_cruise_values(i);
    
    % Calcolo della frazione di carburante per il valore di SFC_cruise attuale
    W4_W3 = exp(-(SFC_cruise * range) / (v_cruise * 0.866 * E_max)); % cruise
    fuel_fraction = 1.05 * (1 - (W2_WTO * W3_W2 * W4_W3 * W5_W4 * W8_W7 * W10_W9));
    
    % Valore iniziale per m_TO
    m_TO = 60000;
    difference = inf; % Inizializza la differenza a un valore elevato
    iteration = 0; % Conta il numero di iterazioni
    
    % Iterazioni per trovare m_TO
    while difference > tolerance && iteration < max_iterations
        iteration = iteration + 1;
        
        % Calcolo di m_empty / m_TO
        m_empty_fraction = A * m_TO^C;
        
        % Nuovo m_TO secondo la formula
        m_TO_new = m_crew_payload / (1 - fuel_fraction - m_empty_fraction);
        
        % Calcolo della differenza tra due iterate
        difference = abs(m_TO_new - m_TO) / m_TO;
        
        % Aggiorna m_TO per la prossima iterazione
        m_TO = m_TO_new;
    end
    
    % Memorizza il valore di m_TO per il valore corrente di SFC_cruise
    m_TO_values(i) = m_TO;
end

% Grafico dei risultati
figure;
plot(SFC_cruise_values, m_TO_values, '-o', 'LineWidth', 2);
xlabel('SFC\_cruise (kg/kg/h)');
ylabel('m_{TO} (kg)');
title('Andamento di m_{TO} al variare di SFC\_cruise');
grid on;

% Infittire la griglia
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
