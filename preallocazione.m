% Calcolo il numero totale di configurazioni possibili
num_configurazioni = length(W_S_vect) * length(AR_vect) * length(t_c_vect) * ...
                     length(sweep25_vect) * length(M_vect) * length(taper_ratio_vect);

W_S_des_memo = NaN(num_configurazioni, 1);
W_S_max_memo = NaN(num_configurazioni, 1);
AR_des_memo = NaN(num_configurazioni, 1);
t_c_des_memo = NaN(num_configurazioni, 1);
sweep25_des_memo = NaN(num_configurazioni, 1);
M_des_memo = NaN(num_configurazioni, 1);
lambda_des_memo = NaN(num_configurazioni, 1);
WTO_memo = NaN(num_configurazioni, 1);
CL_des_memo = NaN(num_configurazioni, 1);
E_curr_memo = NaN(num_configurazioni, 1);
T_curr_memo = NaN(num_configurazioni, 1);
S_ref_memo = NaN(num_configurazioni, 1);
OEW_memo = NaN(num_configurazioni, 1);
W_wing_memo = NaN(num_configurazioni, 1);
W_fus_memo = NaN(num_configurazioni, 1);
W_tail_memo = NaN(num_configurazioni, 1);
W_LG_memo = NaN(num_configurazioni, 1);
W_propuls_memo = NaN(num_configurazioni, 1);
W_fuelsys_memo = NaN(num_configurazioni, 1);
W_hydr_memo = NaN(num_configurazioni, 1);
W_elec_memo = NaN(num_configurazioni, 1);
W_antiice_memo = NaN(num_configurazioni, 1);
W_instr_memo = NaN(num_configurazioni, 1);
W_avionics_memo = NaN(num_configurazioni, 1);
W_engine_sys_memo = NaN(num_configurazioni, 1);
W_furn_memo = NaN(num_configurazioni, 1);
W_services_memo = NaN(num_configurazioni, 1);
W_crew_memo = NaN(num_configurazioni, 1);
W_fuel_memo = NaN(num_configurazioni, 1);