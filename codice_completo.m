clearvars;close all;clc;requisiti;dati;fusoliera;

% variabili di design
% W_S_vect = [550 600 650 700]; % [kg/m^2]
% AR_vect = [7 8 9 10 11]; % []
% t_c_vect = [0.10 0.12 0.15]; % []
% M_vect = [0.76 0.80 0.82]; % []
% sweep25_vect = [20 25 30 35]; % [°]
% taper_ratio_vect = [0.23 0.27 0.31]; % []
aereo_scelto;

% inizializzazione valori del ciclo
Cd0 = Cd0_livello0;
k_polare = k_polare_livello0;
v_cruise = v_cruise_livello0;

% inizializzazione ciclo
MTOW;
W_inizializzazione = m_TO; % [kg] mTO da MTOW

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]
iterazioni_max = 1000;

% Preallocazione degli array per memorizzare i risultati
preallocazione;

f = waitbar(0,'Please wait...');
indice_config = 1;
start_time = tic;
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
                        while abs(delta_WTO) > tolleranza && iterazioni < iterazioni_max
                            % definisco variabili derivate che si aggiornano
                            S_ref = WTO_curr / W_S_des; % [m^2]
                            S_orizz = 0.25*S_ref;
                            S_vert = 0.18*S_ref;
                            b_ref = sqrt(AR_des*S_ref);  % [m]
                            c_root = S_ref/((b_ref-diametro_esterno_fus)/2*(1+lambda_des)); % [m]
                            MAC = 2/3 * c_root * (1+lambda_des+lambda_des^2) / (1+lambda_des); % [m]
                            v_cruise = M_des*a_cruise; % [m/s]
                            CL_des = 2*W_S_des*g/(rho_cruise*v_cruise^2); % [] CL di crociera

                            matching_chart_script;
                            T_curr = thrust_ratio_des * WTO_curr; % [kg] output del matching chart

                            aerodinamica;

                            pesi_script;

                            E_curr = CL_des/CD_curr; % efficienza in crociera
                            script_prestazioni;

                            % aggiornamento WTO
                            WTO_precedente = WTO_curr;
                            WTO_curr = W_payload + W_fuel + OEW_curr;

                            delta_WTO = WTO_curr - WTO_precedente;
                            iterazioni = iterazioni + 1;
                        end
                        costi;
                        if iterazioni == iterazioni_max
                            fprintf('Mancata convergenza: W_S=%.1f, AR=%.1f, t_c=%.1f, sweep=%.1f, M=%.2f, lambda=%.2f\n',...
                                W_S_des, AR_des, t_c_des, sweep25_des, M_des, lambda_des);
                        end
                        memorizzazione;

                        % waitbar
                        if mod(indice_config, 3) == 0
                            elapsed_time = toc(start_time);
                            est_total_time = elapsed_time / indice_config * num_configurazioni;
                            time_left = est_total_time - elapsed_time;
                            waitbar(indice_config / num_configurazioni, f, ...
                                sprintf('Progress: %.1f%% - Time left: %.2f sec', (indice_config / num_configurazioni) * 100, time_left));
                        end
                        indice_config = indice_config + 1;

                    end
                end
            end
        end
    end
end
close(f);
msg = sprintf('Tutte le configurazioni sono state elaborate con successo!\nTempo totale trascorso: %.2f secondi.', toc(start_time));
msgbox(msg, 'Calcolo completato');


% salvataggio configurazioni
%salvataggio;
% salvataggio_matrice;