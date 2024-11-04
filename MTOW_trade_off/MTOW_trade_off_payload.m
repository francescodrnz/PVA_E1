clearvars;close all;clc;requisiti;dati;addpath('..');MTOW;


W4_W3 = exp(-(SFC_cruise*range)/(v_cruise*E_cruise)); %cruise
Wloiter1 = exp(-(SFC_loiter*loiter1)/(E_max)); %loiter1
W8_W7 = exp(-(SFC_cruise*diversione)/(v_cruise*E_cruise)); %diversion
W10_W9 = exp(-(SFC_loiter*loiter2)/(E_max)); %loiter2

fuel_fraction = 1.05*(1-(W2_WTO*W3_W2*W4_W3*Wloiter1*W5_W4*W8_W7*W10_W9));

tolerance = 1e-4;
max_iterations = 1000;

% Numero di passeggeri da 160 a 200 con step di 5
passeggeri_values = 160:5:200;
m_TO_values = zeros(size(passeggeri_values)); % Prealloca il vettore dei risultati

% Ciclo sui diversi valori di passeggeri
for i = 1:length(passeggeri_values)
    
    % Calcolo del peso del payload per l'attuale numero di passeggeri
    m_crew_payload = (passeggeri_values(i) + crew) * peso_passeggero;
    
    % Calcolo della frazione di carburante
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
    
    % Memorizza il valore di m_TO per il numero di passeggeri corrente
    m_TO_values(i) = m_TO;
end

% Grafico dei risultati
figure;
plot(passeggeri_values, m_TO_values, '-o', 'LineWidth', 2);
xlabel('Numero di passeggeri');
ylabel('m_{TO} (kg)');
title('Andamento di m_{TO} al variare del numero di passeggeri');
grid on;

% Infittire la griglia
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
