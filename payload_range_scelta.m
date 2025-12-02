clearvars; close all; clc;

%% 1. CARICAMENTO DATI CONFIGURAZIONE
% Cerca il file CSV più recente
files = dir('dati_convergenza_*.csv'); % Assicurati che il path sia corretto
if isempty(files)
    % Prova a cercare in sottocartelle comuni se non lo trova
    files = dir('**/dati_convergenza_*.csv');
end

if isempty(files)
    error('Nessun file dati_convergenza trovato. Esegui prima il codice di ottimizzazione o specifica il path.');
end

[~, idx] = sort([files.datenum], 'descend');
filename = fullfile(files(idx(1)).folder, files(idx(1)).name);
opts = detectImportOptions(filename);
T = readtable(filename, opts);

% Definizione parametri della configurazione scelta
my_WS = 600;
my_AR = 9;
my_tc = 0.10;
my_M = 0.76;
my_sweep = 20;
my_lambda = 0.23;

% Trova la riga corrispondente nel CSV
% Nota: usiamo tolleranze per i float
tol = 0.001;
idx_config = find(abs(T.W_S - my_WS) < 1 & ...
                  abs(T.AR - my_AR) < tol & ...
                  abs(T.t_c - my_tc) < tol & ...
                  abs(T.M - my_M) < tol & ...
                  abs(T.sweep25 - my_sweep) < 1 & ...
                  abs(T.lambda - my_lambda) < tol, 1);

if isempty(idx_config)
    error('Configurazione scelta non trovata nel file CSV!');
end

row = T(idx_config, :);

fprintf('Configurazione caricata: MTOW = %.0f kg, OEW = %.0f kg\n', row.WTO, row.OEW);

%% 2. DATI DI PROGETTO E MISSIONE
% Recuperiamo i dati necessari dal "row" o dai requisiti standard
% (Assicurati che questi combacino con il tuo file requisiti.m)

% Pesi
MTOW = row.WTO;
OEW = row.OEW;
% VOLUME CARBURANTE DAL CSV
V_fuel_litri = row.V_fuel; % Litri
Max_Fuel_Kg = row.W_fuel;

% Payload
n_pax = 180;
weight_pax = 93; % kg 
W_Pax_Total = n_pax * weight_pax; % Peso soli passeggeri
Max_Payload = 22415; 

% Prestazioni
% a_cruise a 33000ft (10058m) ~ 299.207 m/s
V_cruise_mps = row.M * 299.207; 
V_cruise_kmh = V_cruise_mps * 3.6;

SFC = 0.5; % [kg/kg/h] (da requisiti)
E_cruise = row.E_crociera; % Efficienza calcolata

% Frazioni di peso (Missione Standard)
W2_1 = 0.970; % Takeoff
W3_2 = 0.985; % Climb
W4_3 = 0.995; % Descent

% Diversione e Loiter
Range_div = 700; % km (da requisiti)
t_loiter = 0.5; % h (da requisiti)
SFC_loiter = 0.4; 

f_div = exp(-(SFC * Range_div) / (V_cruise_kmh * 0.866 * E_cruise)); 
E_loiter = E_cruise / 0.866; 
f_loiter = exp(-(SFC_loiter * t_loiter) / E_loiter);

%% 3. CALCOLO PUNTI DIAGRAMMA

% --- PUNTO A: Max Payload, Range nullo (o minimo) ---
PtA_Payload = Max_Payload;
PtA_Range = 0; 

% --- PUNTO B: Max Payload, Max Fuel (con Max Payload) ---
% Punto di progetto (Armonic Point)
W_available_for_fuel = MTOW - OEW - Max_Payload+1135;

if W_available_for_fuel < 0
    error('Errore: OEW + Max Payload > MTOW. Impossibile decollare a pieno carico.');
end

Fuel_B = W_available_for_fuel; 

K_factor = V_cruise_kmh * E_cruise / SFC;
prod_frazioni_fisse = W2_1 * W3_2 * W4_3 * f_div * f_loiter;

% Range B
m_final_frac_B = 1 - (Fuel_B / MTOW) / 1.05;
PtB_Range = -log(m_final_frac_B / prod_frazioni_fisse) * K_factor;
PtB_Payload = Max_Payload;

% --- PUNTO C: Max Fuel, Payload Ridotto ---
% Riempiamo i serbatoi fino alla capacità massima (dal CSV)
Fuel_C = Max_Fuel_Kg+1135;
Payload_C = MTOW - OEW - Fuel_C;

if Payload_C < 0
    Payload_C = 0;
    Fuel_C = MTOW - OEW;
end

m_final_frac_C = 1 - (Fuel_C / MTOW) / 1.05;
PtC_Range = -log(m_final_frac_C / prod_frazioni_fisse) * K_factor;
PtC_Payload = Payload_C;

% --- PUNTO D: Max Fuel, Zero Payload ---
W_TO_D = OEW + Max_Fuel_Kg;

% Qui la frazione di carburante è rispetto al W_TO_D attuale
m_final_frac_D = 1 - (Max_Fuel_Kg / W_TO_D) / 1.05;
PtD_Range = -log(m_final_frac_D / prod_frazioni_fisse) * K_factor;
PtD_Payload = 0;

%% 4. PLOT
% --- INTERPOLAZIONE A 4500 KM ---
% Verifica se 4500 km cade tra B e C o tra C e D
Req_Range = 4500;
Payload_at_Req = 0;

if Req_Range <= PtB_Range
    Payload_at_Req = Max_Payload; % Siamo nel plateau
elseif Req_Range > PtB_Range && Req_Range <= PtC_Range
    % Interpolazione lineare BC
    slope = (PtC_Payload - PtB_Payload) / (PtC_Range - PtB_Range);
    Payload_at_Req = PtB_Payload + slope * (Req_Range - PtB_Range);
elseif Req_Range > PtC_Range && Req_Range <= PtD_Range
    % Interpolazione lineare CD
    slope = (PtD_Payload - PtC_Payload) / (PtD_Range - PtC_Range);
    Payload_at_Req = PtC_Payload + slope * (Req_Range - PtC_Range);
else
    Payload_at_Req = 0; % Irraggiungibile
end


figure('Color', 'w', 'Position', [100 100 900 600]);
hold on; grid on;

% Area del diagramma
ranges = [0, PtB_Range, PtC_Range, PtD_Range];
payloads = [PtA_Payload, PtB_Payload, PtC_Payload, PtD_Payload];

% Area sotto la curva
x_poly = [0, ranges, 0]; % Aggiungo punti a y=0 per chiudere
y_poly = [0, payloads, 0]; 
fill(x_poly, y_poly, [0.8 0.9 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); 

plot(ranges, payloads, '-o', 'LineWidth', 2.5, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', 'w');

% Linee limite e target
yline(Max_Payload, '--k', 'Max Payload');
yline(W_Pax_Total, '--b', 'Solo Passeggeri', 'LineWidth', 1.5); % Linea verde per i soli pax
xline(Req_Range, '--r'); 

% Annotazione Requisito Range
text(Req_Range+50, 2000, 'Requisito (4500 km)', 'Color', 'r', 'Rotation', 90, ...
    'VerticalAlignment', 'middle', 'FontSize', 10, 'FontWeight', 'bold');

% Annotazioni Punti
text(PtB_Range, PtB_Payload, sprintf('  B (%.0f km, %.0f kg)', PtB_Range, PtB_Payload), ...
    'VerticalAlignment', 'bottom', 'FontWeight', 'bold', 'FontSize', 10);
text(PtC_Range, PtC_Payload, sprintf('  C (%.0f km, %.0f kg)', PtC_Range, PtC_Payload), ...
    'VerticalAlignment', 'bottom', 'FontWeight', 'bold', 'FontSize', 10);
text(PtD_Range, PtD_Payload, sprintf('  D (%.0f km)', PtD_Range), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontWeight', 'bold', 'FontSize', 10);

% Punto di Progetto Effettivo (a 4500 km)
plot(Req_Range, Payload_at_Req, 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
text(Req_Range, Payload_at_Req, sprintf('  Capacità @ 4500km:\n  %.0f kg', Payload_at_Req), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'Color', 'r', 'FontWeight', 'bold');

% Check Soddisfacimento Requisito
if Payload_at_Req >= W_Pax_Total
    title_str = 'Diagramma Payload-Range';
    col_tit = 'k';
else
    title_str = 'ATTENZIONE: Requisito Pax NON Soddisfatto!';
    col_tit = 'r';
end

% Labels
xlabel('Range [km]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Payload [kg]', 'FontSize', 12, 'FontWeight', 'bold');
title(title_str, 'FontSize', 14, 'Color', col_tit);

% Abbellimento assi
ax = gca;
ax.XAxis.Exponent = 0; 
ax.YAxis.Exponent = 0;
xtickformat('%.0f');
ytickformat('%.0f');
ylim([0 Max_Payload*1.2]);
xlim([0 PtD_Range*1.05]);

% Salvataggio
saveas(gcf, 'payload_range_finale.png');
fprintf('Grafico salvato come payload_range_finale.png\n');
fprintf('Payload trasportabile a 4500 km: %.0f kg\n', Payload_at_Req);
fprintf('Peso dei soli 180 passeggeri: %.0f kg\n', W_Pax_Total);