%clearvars;close all;clc;requisiti;dati;MTOW; % necessario se si runna da qui anziché da main

%Calcolo max range

% Requisito

% Dati

m_fuel_armonic = fuel_fraction*m_TO;

% Calcoli punto C
m_fuel_max = max_fuel_volume*fuel_density;
fuel_frac_max_fuel = m_fuel_max / m_TO;
m_final_frac_max_fuel = 1-fuel_frac_max_fuel/1.05;
range_C = -log(m_final_frac_max_fuel/(W2_WTO*W3_W2*W5_W4*Wloiter1*W8_W7*W10_W9))*v_cruise*E_cruise/SFC_cruise;

% Calcoli punto D
m_TO_D = 2*peso_passeggero + m_fuel_max + m_empty_fraction*m_TO;
fuel_frac_D = m_fuel_max / m_TO_D;
m_final_frac_D = 1-fuel_frac_D/1.05;
range_D = -log(m_final_frac_D/(W2_WTO*W3_W2*W5_W4*Wloiter1*W8_W7*W10_W9))*v_cruise*E_cruise/SFC_cruise;

% Diagramma payload-range

% Valori di payload e range nei punti del diagramma
payloadA = passeggeri * peso_passeggero; % Payload massimo
rangeA = 0;

payloadB = passeggeri * peso_passeggero; % Payload massimo
rangeB = range; % Range da requisito

payloadC = m_TO - (m_fuel_max + m_empty_fraction*m_TO + crew * peso_passeggero); % Payload ridotto al punto C
rangeC = range_C; % Range al punto C con massimo fuel

payloadD = 0; % Nessun payload, solo fuel
rangeD = range_D; % Range massimo senza payload

figure;
plot([rangeA, rangeB, rangeC, rangeD], [payloadA, payloadB, payloadC, payloadD], '-o', 'Color', 'b',  'LineWidth', 2);
xlabel('Range (km)');
ylabel('Payload (kg)');
title('Diagramma Payload-Range');
grid on;
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';



