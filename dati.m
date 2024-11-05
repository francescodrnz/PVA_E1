% fattori di conversione
ft2m = 0.3048;
m2ft = 1 / ft2m;
sqft2sqm = ft2m*ft2m;
sqm2sqft = 1/sqft2sqm;
lb2kg = 0.45359237;
kg2lb = 1 / lb2kg;
nm2km = 1.852;
mps2kmph = 3.6;
kmph2mps = 1 / mps2kmph;
l2gal = 3.785411784;

% Dati
rho_SL = 1.225; % [kg/m^3]
a_SL = 340.3; % [m/s]
h_cruise = 33000*ft2m; % [m]
rho_cruise = 0.4127; % [kg/m^3]
a_cruise = 299.5; % [m/s]
visc_dinamica_cruise = 1.4571e-5; % [kg/(m*s)]

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
TOP = 165; % [lb/ft^2]
oswald_livello0 = 0.8; % fattore di Oswald
k_polare_livello0 = 1/(pi*AR*oswald_livello0); % calcolo Cd
Vstall = 115*nm2km; % [km/h]
g = 9.81; % [m/s^2]

% pesi
ultimate_load_fact = 3.75;
N_serbatoi = 6;