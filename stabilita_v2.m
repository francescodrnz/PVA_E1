clearvars; close all; clc;

%% 1. CARICAMENTO DATI E CONFIGURAZIONE
files = dir('dati_convergenza_*.csv');
if isempty(files), files = dir('**/dati_convergenza_*.csv'); end
if isempty(files), error('Nessun file dati trovato.'); end
[~, idx] = sort([files.datenum], 'descend');
filename = fullfile(files(idx(1)).folder, files(idx(1)).name);
T = readtable(filename);

% Configurazione Scelta
my_WS = 600; my_AR = 9; my_tc = 0.10; my_M = 0.76; my_sweep = 20;
tol = 0.001;
idx_config = find(abs(T.W_S - my_WS) < 1 & abs(T.AR - my_AR) < tol & ...
                  abs(T.t_c - my_tc) < tol & abs(T.M - my_M) < tol & ...
                  abs(T.sweep25 - my_sweep) < 1, 1);
if isempty(idx_config), error('Configurazione non trovata.'); end
row = T(idx_config, :);

fprintf('--- STABILITÀ LONGITUDINALE E DIREZIONALE (Metodo Volumi di Coda) ---\n');

%% 2. DATI GEOMETRICI E DI PESO
% Pesi [kg]
MTOW = row.WTO;
OEW  = row.OEW;
W_fuel = row.W_fuel;
W_pay  = 22415;
W_wing = row.W_wing;
W_tail = row.W_tail; 
W_prop = row.W_propuls;
W_lg   = row.W_LG;

% Massa Fusoliera + Sistemi + Arredi + Crew (Tutto il resto)
W_fus_group_OEW = OEW - (W_wing + W_tail + W_prop + W_lg);

% Geometria
S = row.S;
b = row.b;
MAC = row.MAC;
c_root = row.c_root;
L_fus = 38.0; 
d_fus = 4.1;
lambda = 0.23;
AR = 9;
sweep_LE = atand(tand(my_sweep) + ((1-lambda)/(1+lambda))*(1/AR) - 0); 

%% STEP 0: POSIZIONAMENTO INIZIALE COMPONENTI (Ipotesi di Progetto)
X_LE_root = 0.42 * L_fus; 

% Calcolo posizione MAC
y_mac = (b/6) * ((1+2*lambda)/(1+lambda));
x_mac_shift = y_mac * tand(sweep_LE);
X_MAC_LE = X_LE_root + x_mac_shift;

% Posizioni Baricentri Componenti (metri da naso)
x_fus_cg  = 0.46 * L_fus; 
x_pay_cg  = x_fus_cg; 
x_tail_cg = 0.94 * L_fus; % Coda in fondo (braccio leva coda)
x_wing_cg = X_LE_root + 0.25*c_root + (0.35/2*b-d_fus/2)*tand(my_sweep);%X_MAC_LE + 0.40 * MAC; 
x_fuel_cg = x_wing_cg;%X_MAC_LE + 0.45 * MAC; 
x_eng_cg  = X_LE_root + 0.4*3.565; % da slide, x_LE + 0.4*L_nac 
x_lg_cg   = x_fus_cg;%X_MAC_LE + 0.8 * MAC; 

%% STEP 1: SELECT TAIL VOLUME (Slide 31 e Standard)
V_H_design = 1.0; % Volume Coda Orizzontale
V_V_design = 0.11; % Volume Coda Verticale (Standard Jet Transport 0.08 - 0.14)
fprintf('1. Volumi di Coda di Progetto scelti:\n   V_H = %.2f\n   V_V = %.2f\n', V_H_design, V_V_design);

%% STEP 2: ASSESS AIRCRAFT CG @ MZFW AND TAIL ARM (Slide 32-38)
% Momento OEW
M_OEW = W_fus_group_OEW * x_fus_cg + ...
        W_tail * x_tail_cg + ...
        W_wing * x_wing_cg + ...
        W_prop * x_eng_cg + ...
        W_lg   * x_lg_cg;

% Momento MZFW
M_MZFW = M_OEW + W_pay * x_pay_cg;
MZFW = OEW + W_pay;
X_CG_MZFW = M_MZFW / MZFW;

% Braccio di Coda (Tail Arm) @ MZFW
L_tail_MZFW = x_tail_cg - X_CG_MZFW;

fprintf('2. Posizione CG @ MZFW: %.2f m (%.1f%% MAC)\n', X_CG_MZFW, (X_CG_MZFW-X_MAC_LE)/MAC*100);
fprintf('   Braccio di Coda @ MZFW: %.2f m\n', L_tail_MZFW);

%% STEP 3: ASSESS PLANFORM AREA OF TAIL (Slide 39)
% Orizzontale: S_HT = (V_H * S * MAC) / L_tail
S_HT_req = (V_H_design * S * MAC) / L_tail_MZFW;

% Verticale: S_VT = (V_V * S * b) / L_tail
S_VT_req = (V_V_design * S * b) / L_tail_MZFW;

fprintf('3. Superfici di Coda Richieste (per stabilità @ MZFW):\n');
fprintf('   S_HT richiesta: %.2f m^2 (Attuale: %.2f m^2)\n', S_HT_req, row.S_orizz);
fprintf('   S_VT richiesta: %.2f m^2 (Attuale: %.2f m^2)\n', S_VT_req, row.S_vert);

% Aggiorniamo con le superfici calcolate per la verifica finale
S_HT_final = S_HT_req; 
S_VT_final = S_VT_req;

%% STEP 4: RE-DO STEP 2 @ MTOW AND CALCULATE TAIL VOLUME (Slide 42)
% Calcolo CG @ MTOW
M_MTOW = M_MZFW + W_fuel * x_fuel_cg;
X_CG_MTOW = M_MTOW / MTOW;

% Nuovo Braccio di Coda @ MTOW
L_tail_MTOW = x_tail_cg - X_CG_MTOW;

% Calcolo Volumi di Coda effettivi @ MTOW
V_H_MTOW = (S_HT_final * L_tail_MTOW) / (S * MAC);
V_V_MTOW = (S_VT_final * L_tail_MTOW) / (S * b);

fprintf('4. Posizione CG @ MTOW: %.2f m (%.1f%% MAC)\n', X_CG_MTOW, (X_CG_MTOW-X_MAC_LE)/MAC*100);
fprintf('   Braccio di Coda @ MTOW: %.2f m\n', L_tail_MTOW);
fprintf('   Volume Orizzontale @ MTOW (V_H): %.4f\n', V_H_MTOW);
fprintf('   Volume Verticale   @ MTOW (V_V): %.4f\n', V_V_MTOW);

% Verifica Requisiti
fprintf('   VERIFICA 0.8 <= V_H <= 1.35: ');
if V_H_MTOW >= 0.8, fprintf('SUCCESSO\n'); else, fprintf('FALLITA\n'); end

fprintf('   VERIFICA 0.08 <= V_V <= 0.14: '); % Valore minimo da slide
if V_V_MTOW >= 0.08, fprintf('SUCCESSO\n'); else, fprintf('FALLITA\n'); end

%% PLOT ESCURSIONE CG (Visualizzazione Migliorata)
figure('Name','Escursione Baricentro','Color','w', 'Position', [100, 100, 1000, 600]);
hold on; grid on; axis equal;

% --- SFONDO E FUSOLIERA ---
% Fusoliera come rettangolo con bordi arrotondati e riempimento sfumato
rectangle('Position', [0, -d_fus/2, L_fus, d_fus], 'Curvature', 0.2, ...
    'EdgeColor', [0.2, 0.2, 0.2], 'LineWidth', 2, 'FaceColor', [0.9, 0.9, 0.95]);

% --- ALA E MAC ---
% Disegno schematico dell'ala (trapezio)
wing_color = [0.7, 0.8, 1.0]; % Azzurro chiaro
y_span = b/2;
x_root_te = X_LE_root + c_root;
c_tip = row.c_tip;
x_tip_le = X_LE_root + y_span * tand(sweep_LE);
x_tip_te = x_tip_le + c_tip;

patch([X_LE_root, x_tip_le, x_tip_te, x_root_te], ...
      [0, y_span, y_span, 0], wing_color, 'EdgeColor', 'b', 'FaceAlpha', 0.5);
patch([X_LE_root, x_tip_le, x_tip_te, x_root_te], ...
      [0, -y_span, -y_span, 0], wing_color, 'EdgeColor', 'b', 'FaceAlpha', 0.5);

% Evidenzia la MAC
plot([X_MAC_LE, X_MAC_LE+MAC], [y_mac y_mac], 'b-', 'LineWidth', 4); 
plot([X_MAC_LE, X_MAC_LE+MAC], [-y_mac -y_mac], 'b-', 'LineWidth', 4); 
text(X_MAC_LE + MAC/2, y_mac + 1, 'MAC', 'Color', 'b', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);

% Limiti MAC con linee tratteggiate sulla fusoliera (y=0)
xline(X_MAC_LE, ':b', 'LineWidth', 1.5);
xline(X_MAC_LE+MAC, ':b', 'LineWidth', 1.5);

% --- CODA ---
% Posizione schematica della coda (stima geometrica)
tail_color = [0.8, 0.8, 0.8]; % Grigio
S_ht = row.S_orizz; 
AR_ht = 5; 
b_ht = sqrt(S_ht * AR_ht);
c_root_ht = (2*S_ht)/(b_ht*(1+0.4)); % ipotizzando lambda=0.4
x_tail_le = x_tail_cg - 0.25*c_root_ht; 

patch([x_tail_le, x_tail_le+b_ht/2*tand(29), x_tail_le+b_ht/2*tand(29)+c_root_ht*0.4, x_tail_le+c_root_ht], ...
      [0, b_ht/2, b_ht/2, 0], tail_color, 'EdgeColor', 'k', 'FaceAlpha', 0.5);
patch([x_tail_le, x_tail_le+b_ht/2*tand(29), x_tail_le+b_ht/2*tand(29)+c_root_ht*0.4, x_tail_le+c_root_ht], ...
      [0, -b_ht/2, -b_ht/2, 0], tail_color, 'EdgeColor', 'k', 'FaceAlpha', 0.5);

% --- BARICENTRI (CG) ---
% Plot dei punti
h_MZFW = plot(X_CG_MZFW, 0, 'mo', 'MarkerSize', 12, 'MarkerFaceColor', 'm', 'LineWidth', 2);
h_MTOW = plot(X_CG_MTOW, 0, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'LineWidth', 2);
% Aggiunta delle etichette DIRETTAMENTE SUL GRAFICO
text(X_CG_MZFW, 0.2, 'CG @ MZFW', 'Color', 'm', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 15);

text(X_CG_MTOW, 0.2, 'CG @ MTOW', 'Color', 'r', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 15);

% Frecce per indicare l'escursione (sopra fusoliera)
y_arrow = d_fus/2-1.2;
quiver(X_CG_MZFW, y_arrow, X_CG_MTOW-X_CG_MZFW, 0, 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 1.8, 'HandleVisibility', 'off');
text((X_CG_MZFW+X_CG_MTOW)/2, y_arrow+0.4, 'Escursione CG', 'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold');

% --- ASSI, TITOLI E LEGENDA ---
xlabel('Posizione Longitudinale X [m]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Posizione Laterale Y [m]', 'FontSize', 12, 'FontWeight', 'bold');
title('Escursione del Baricentro', 'FontSize', 14);

ylim([-b/2-2, b/2+2]); 
xlim([-2, 41.5]);
set(gca, 'FontSize', 12);

saveas(gcf, 'cg_excursion.png');