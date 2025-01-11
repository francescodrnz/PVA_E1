%clearvars;close all;clc;dati;requisiti;AR = 9;v_cruise = 835;

% Calcoli
m_crew_payload = (passeggeri + crew)*peso_passeggero;

E_max = k_E*sqrt(AR/Swet_Sref);
E_cruise = 0.866*E_max;
W4_W3 = exp(-(SFC_cruise*range)/(v_cruise*E_cruise)); %cruise
Wloiter1 = exp(-(SFC_loiter*loiter1)/(E_max)); %loiter1
W8_W7 = exp(-(SFC_cruise*diversione)/(v_cruise*E_cruise)); %diversion
W10_W9 = exp(-(SFC_loiter*loiter2)/(E_max)); %loiter2

fuel_fraction = 1.05*(1-(W2_WTO*W3_W2*W4_W3*Wloiter1*W5_W4*W8_W7*W10_W9));


tolerance = 1e-4;
max_iterations = 1000;

% inizializzazione m_TO
m_TO = 60000;
difference = inf; 
iteration = 0;

while difference > tolerance && iteration < max_iterations
    iteration = iteration + 1;
    
    % Calcolo di m_empty / m_TO
    m_empty_fraction = A * m_TO^C;
    
    % Nuovo m_TO
    m_TO_new = m_crew_payload / (1 - fuel_fraction - m_empty_fraction);
    
    % Calcolo della differenza tra due iterate
    difference = abs(m_TO_new - m_TO)/m_TO;
    
    % Aggiorna m_TO per la prossima iterazione
    m_TO = m_TO_new;
end

if iteration == max_iterations
    fprintf('Numero massimo di iterazioni raggiunto (%d).\n', max_iterations);
else
    fprintf('Il valore finale di m_TO è: %.4f\n', m_TO);
    fprintf('Il valore finale di m_empty è: %.4f\n', m_empty_fraction);
    fprintf('Convergenza in %d iterazioni.\n', iteration);
end