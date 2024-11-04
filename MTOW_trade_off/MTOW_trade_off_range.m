clearvars
close all
clc

% Requisito
passeggeri = 180;
crew = 6;
diversione = 700; %km
loiter = 0.5; %h
v_cruise = 835; %km/h

% Dati
peso_passeggero = 93; %kg
wingspan = 33.15;
wingarea = 122;
AR = wingspan^2/wingarea;
Swet_Sref = 6.4;
k_E = 15.5;
A = 0.97;
C = -0.06;
SFC_cruise = 0.5;
SFC_loiter = 0.4;

W2_WTO = 0.97; %decollo
W3_W2 = 0.985; %climb
W5_W4 = 0.995; %atterraggio

% Calcoli
m_crew_payload = (passeggeri + crew) * peso_passeggero;
E_max = k_E * sqrt(AR / Swet_Sref);

W8_W7 = exp(-(SFC_cruise * diversione) / (v_cruise * 0.866 * E_max)); %diversion
W10_W9 = exp(-(SFC_loiter * loiter) / E_max); %loiter

tolerance = 1e-4;
max_iterations = 1000;

% Range da 5500 km a 7500 km con step di 100 km
range_values = 3500:100:5500;
m_TO_values = zeros(size(range_values)); % Prealloca il vettore dei risultati

% Ciclo sui diversi valori di range
for i = 1:length(range_values)
    range = range_values(i);
    
    % Calcolo della frazione di carburante per il range attuale
    W4_W3 = exp(-(SFC_cruise * range) / (v_cruise * 0.866 * E_max)); %cruise
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
    
    % Memorizza il valore di m_TO per il range corrente
    m_TO_values(i) = m_TO;
end

% Grafico dei risultati
figure;
plot(range_values, m_TO_values, '-o', 'LineWidth', 2);
xlabel('Range (km)');
ylabel('m_{TO} (kg)');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
title('Andamento di m_{TO} al variare del range');
grid on;
