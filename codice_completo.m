tic
clearvars;close all;clc;dati;requisiti;fusoliera;

% ciclo principale
% definisco vettori delle variabili di design
W_S_vect = [550 600 650 700]; % [kg/m^2]
AR_vect = [7 8 9 10 11]; % []
t_c_vect = [0.10 0.12 0.15]; % []
M_vect = [0.76 0.80 0.82]; % []
sweep25_vect = [20 25 30 35]; % [°]
taper_ratio_vect = [0.23 0.27 0.31]; % []

% primo blocco: matching chart per avere T/W, servono alcuni valori della
% polare che non abbiamo.
Cd0 = Cd0_livello0; % inizializzo valore del ciclo
k_polare = k_polare_livello0;

% inizializzazione ciclo
% stima peso livello 0: codice del task 2 MTOW
MTOW;
W_inizializzazione = m_TO; % [kg] mTO da MTOW

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

% Preallocazione degli array per memorizzare i risultati
preallocazione;

% ciclo di dimensionamento
for i_W_S = 1:length(W_S_vect)
    for i_AR = 1:length(AR_vect)
        for i_t_c = 1:length(t_c_vect)
            for i_sweep25 = 1:length(sweep25_vect)
                for i_M = 1:length(M_vect)
                    for i_taper = 1:length(taper_ratio_vect)
                        % step 1: dichiarare variabili di design che si aggiornano
                        W_S_des = W_S_vect(i_W_S);
                        AR_des = AR_vect(i_AR);
                        t_c_des = t_c_vect(i_t_c);
                        sweep25_des = sweep25_vect(i_sweep25);
                        M_des = M_vect(i_M);
                        lambda_des = taper_ratio_vect(i_taper);

                        % ciclo di convergenza sul peso
                        delta_WTO = 1000; % [kg] inizializzazione per entrare nel while
                        WTO_curr = W_inizializzazione;
                        iterazioni = 0;
                        while abs(delta_WTO) > tolleranza && iterazioni < 1000
                            % definisco variabili derivate che si aggiornano
                            S_ref = WTO_curr / W_S_des; % [m^2]
                            b_ref = sqrt(AR_des*S_ref);  % [m]
                            standard_mean_chord_ala = b_ref/AR_des; % [m]
                            V_cruise = M_des*a_cruise; % [m/s]
                            CL_des = 2*W_S_des*g/(rho_cruise*V_cruise^2); % [] CL di crociera


                            % script delle varie parti
                            matching_chart_script;
                            T_curr = thrust_ratio_des * WTO_curr; % [kg] output del matching chart
                            aerodinamica;
                            pesi_script;
                            % PRESTAZIONI
                            E_curr = CL_des/CD_curr; % CD_curr da aerodinamica cd0+cdi+cdw
                            script_prestazioni;

                            % aggiornamento WTO
                            WTO_precedente = WTO_curr;
                            WTO_curr = W_payload + W_fuel + OEW_curr;

                            delta_WTO = WTO_curr - WTO_precedente;
                            iterazioni = iterazioni + 1;
                        end

                        % Memorizzazione dei risultati dopo la convergenza
                        indice_contatore = indice_contatore + 1;
                        W_S_des_memo(indice_contatore) = W_S_des;
                        W_S_max_memo(indice_contatore) = wing_load_max;
                        AR_des_memo(indice_contatore) = AR_des;
                        t_c_des_memo(indice_contatore) = t_c_des;
                        sweep25_des_memo(indice_contatore) = sweep25_des;
                        M_des_memo(indice_contatore) = M_des;
                        lambda_des_memo(indice_contatore) = lambda_des;
                        WTO_memo(indice_contatore) = WTO_curr;
                        CL_des_memo(indice_contatore) = CL_des;
                        E_curr_memo(indice_contatore) = E_curr;
                        T_curr_memo(indice_contatore) = T_curr;
                        S_ref_memo(indice_contatore) = S_ref;
                        OEW_memo(indice_contatore) = OEW_curr;
                        W_wing_memo(indice_contatore) = W_wing;
                        W_fus_memo(indice_contatore) = W_fus;
                        W_tail_memo(indice_contatore) = W_tail;
                        W_LG_memo(indice_contatore) = W_LG;
                        W_propuls_memo(indice_contatore) = W_propulsione;
                        W_fuelsys_memo(indice_contatore) = W_fuelsys;
                        W_hydr_memo(indice_contatore) = W_hydraulic;
                        W_elec_memo(indice_contatore) = W_elec;
                        W_antiice_memo(indice_contatore) = W_antiice;
                        W_instr_memo(indice_contatore) = W_instr;
                        W_avionics_memo(indice_contatore) = W_avionics;
                        W_engine_sys_memo(indice_contatore) = W_engine_sys;
                        W_furn_memo(indice_contatore) = W_furn;
                        W_services_memo(indice_contatore) = W_services;
                        W_crew_memo(indice_contatore) = W_crew;
                        W_fuel_memo(indice_contatore) = W_fuel;
                        W_payload_memo(indice_contatore) = W_payload;

                    end
                end
            end
        end
    end
end

% visualizzazione configurazioni
% con matrice:
% Creazione della tabella
T = array2table([W_S_des_memo(1:indice_contatore), W_S_max_memo(1:indice_contatore), AR_des_memo(1:indice_contatore), ...
    t_c_des_memo(1:indice_contatore), sweep25_des_memo(1:indice_contatore), ...
    M_des_memo(1:indice_contatore), lambda_des_memo(1:indice_contatore), ...
    WTO_memo(1:indice_contatore), CL_des_memo(1:indice_contatore), ...
    E_curr_memo(1:indice_contatore), T_curr_memo(1:indice_contatore), ...
    S_ref_memo(1:indice_contatore), OEW_memo(1:indice_contatore), ...
    W_wing_memo(1:indice_contatore), W_fus_memo(1:indice_contatore), ...
    W_tail_memo(1:indice_contatore), W_LG_memo(1:indice_contatore), ...
    W_propuls_memo(1:indice_contatore), W_fuelsys_memo(1:indice_contatore), ...
    W_hydr_memo(1:indice_contatore), W_elec_memo(1:indice_contatore), ...
    W_antiice_memo(1:indice_contatore), W_instr_memo(1:indice_contatore), ...
    W_avionics_memo(1:indice_contatore), W_engine_sys_memo(1:indice_contatore), ...
    W_furn_memo(1:indice_contatore), W_services_memo(1:indice_contatore), ...
    W_crew_memo(1:indice_contatore), W_fuel_memo(1:indice_contatore), W_fuel_memo(1:indice_contatore)/0.8, ...
    W_payload_memo(1:indice_contatore)], ...
    'VariableNames', {'W/S', 'W/S max' 'AR', 't/c', 'sweep25', 'M', 'lambda', 'WTO', 'CL_crociera', ...
                      'E', 'T', 'S', 'OEW', 'W_wing', 'W_fus', 'W_tail', 'W_LG', ...
                      'W_propuls', 'W_fuelsys', 'W_hydr', 'W_elec', 'W_antiice', ...
                      'W_instr', 'W_avionics', 'W_engine_sys', 'W_furn', ...
                      'W_services', 'W_crew', 'W_fuel', 'V_fuel', 'W_payload'});
toc
tic
% Salvataggio della tabella in un file .csv
writetable(T, 'dati_convergenza.csv');
toc