clearvars;close all;clc;dati;requisiti;
larghezza_sedile = 0.52; % [m]
sedili_fila = 6;
larghezza_corridoio = 0.5; % [m]

diametro_interno_min = larghezza_sedile*sedili_fila+larghezza_corridoio;
diametro_esterno_fus = 4.1; % [m]

numero_file = passeggeri/sedili_fila;
pitch_sedile = 0.72; % [m]
lunghezza_file = pitch_sedile*numero_file; % [m]

A_fus = pi*(diametro_esterno_fus/2)^2; % [m^2]
L_n = 1.5*diametro_esterno_fus; % [m] slide 10
L_t = 2.5*diametro_esterno_fus; % [m]

lunghezza_fus = L_n+L_t+lunghezza_file; % [m]

cargo_vol = 2.64*1.24*15; % [m^3]
bagagli_vol = passeggeri*0.113; % [m^3]
% 7 container LD3/46W
peso_container = 1135; % [kg]
numero_container = 6;
W_cargo = peso_container * numero_container; % [kg]