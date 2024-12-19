% fattori di conversione
ft2m = 0.3048;
m2ft = 1 / ft2m;
sqft2sqm = ft2m*ft2m;
sqm2sqft = 1/sqft2sqm;
lb2kg = 0.45359237;
kg2lb = 1 / lb2kg;
nm2km = 1.852;
km2nm = 1 / nm2km;
mps2kmph = 3.6;
kmph2mps = 1 / mps2kmph;
l2gal = 3.785411784;
kt2mps = nm2km*kmph2mps;
hr2sec = 3600;
sec2hr = 1 / hr2sec;
hp2W = 745.7;
W2hp = 1 / hp2W;
inflazione = 1.64;

% Dati
v_cruise_livello0 = 835; % [km/h]
rho_SL = IntStandAir_SI(0, ['rho']); % [kg/m^3]
a_SL = IntStandAir_SI(0, ['a']); % [m/s]
h_cruise = 33000*ft2m; % [m]
rho_cruise = IntStandAir_SI(h_cruise, ['rho']); % [kg/m^3]
a_cruise = IntStandAir_SI(h_cruise, ['a']); % [m/s]
visc_dinamica_cruise = IntStandAir_SI(h_cruise, ['mu']); % [kg/(m*s)]

% MTOW
peso_passeggero = 93; % [kg]
wingspan = 33.15; % [m]
wingarea = 122; % [m^2]
AR = wingspan^2/wingarea;
Swet_Sref = 6.4;
k_E = 15.5;
A = 0.97;
C = -0.06;
SFC_cruise = 0.5; % [kg/kg/h]
SFC_loiter = 0.4; % [kg/kg/h]

W2_WTO = 0.97; %decollo
W3_W2 = 0.985; %climb
W5_W4 = 0.995; %atterraggio

% payload_range
fuel_density = 0.785; % [kg/l]
max_fuel_volume = 24000; % [l]

% matching_chart
% BFL A320: 6900 ft
TOP = 165 * lb2kg / sqft2sqm ; % conversione in [kg/m^2]
C_L_max_2D = 1.7; % profilo NASA SC(2)-0610
oswald_livello0 = 0.8; % fattore di Oswald
k_polare_livello0 = 1/(pi*AR*oswald_livello0); % calcolo Cd
Vstall = 115*nm2km; % [km/h]
g = 9.81; % [m/s^2]
Cd0_livello0 = 0.017; % valore che ho usato per fare il matching chart preliminare

% pesi
N_prop = 2; % numero propulsori
ultimate_load_fact = 3.75;
N_serbatoi = 6;

% stabilita
S_orizz_livello0 = 37; % [m^2]
AR_orizz = 5;
t_c_orizz = 0.1;
sweep25_orizz = 29; % [°]
S_vert_livello0 = 30; % [m^2]
AR_vert = 1.8;
t_c_vert = 0.12;
sweep25_vert = 34; % [°]

% costi
jet_fuel_cost = 686.33; % [$/(kg*10^3)]
man_hour_cost = 55*inflazione; % [$/h]
K_engine = 0.57;
OPR = 32;
BPR = 50;
N_comp = 12;
FED = 12000; % [Wh/kg]