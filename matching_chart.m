clearvars;close all;clc;dati;requisiti;MTOW; % necessario se si runna da qui anziché da main

wing_load = 0.01:10:800; % range di valutazione
S = m_TO*wing_load.^(-1); % superficie alare calcolata in funzione del wing load

% Decollo
TOP = TOP * lb2kg / sqft2sqm ; % conversione in [kg/m^2]
% Calcolo C_L_max
C_L_max_2D = 1.7; % profilo NASA SC(2)-0610
freccia = deg2rad(25); % freccia A320
C_L_max_clean = 0.9*C_L_max_2D*cos(freccia);

delta_C_L_flap_2D = 1.55; % slat + Fowler flap
Sflap = 0.85*S; % da misura ala A320
delta_C_L_flap = 0.92*delta_C_L_flap_2D*Sflap/S*cos(freccia);

C_L_max_flapped = C_L_max_clean + delta_C_L_flap;

thrust_ratio_decollo = wing_load / (TOP * C_L_max_flapped);

figure;
hold on;
ylim([0 1]);
plot(wing_load, thrust_ratio_decollo, 'b','Color', 'b', 'LineWidth', 2);
grid on;

% Stall Speed
wing_load_max = 0.5*rho_SL*(1.136*Vstall/3.6)^2*C_L_max_flapped/g;
xline(wing_load_max, 'LineWidth', 2);

% Climb
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S * sind(35)^2;
C_D_LG = 2.92e-03*(m_TO*kg2lb)^0.785*(S*sqm2sqft).^(-1);
% first segment
gamma1 = deg2rad(0);
thrust_ratio1 = 2*(0.5*rho_SL*(1.2*Vstall/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0+C_D_flap+C_D_LG) + k_polare_livello0*(2*(g*wing_load)*cos(gamma1)/(rho_SL*(1.2*Vstall/3.6)^2)).^2) + sin(gamma1));
% second segment
gamma2 = atan(2.4/100);
thrust_ratio2 = 2*(0.5*rho_SL*(1.2*Vstall/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0+C_D_flap) + k_polare_livello0*(2*(g*wing_load)*cos(gamma2)/(rho_SL*(1.2*Vstall/3.6)^2)).^2) + sin(gamma2));
% third segment
gamma3 = atan(1.2/100);
thrust_ratio3 = 2*(0.5*rho_SL*(1.25*Vstall/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0) + k_polare_livello0*(2.*(g*wing_load)*cos(gamma3)/(rho_SL*(1.25*Vstall/3.6)^2)).^2) + sin(gamma3));

thrust_ratio_climb = max(max(thrust_ratio1, thrust_ratio2), thrust_ratio3);
plot(wing_load, thrust_ratio_climb, 'b','Color', 'r', 'LineWidth', 2);

% Cruise
gammaCruise = 0;
thrust_ratio_cruise = 2*(0.5*rho_cruise*(v_cruise/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0) + k_polare_livello0*(2.*(g*wing_load)*cos(gammaCruise)/(rho_cruise*(v_cruise/3.6)^2)).^2) + sin(gammaCruise));
thrust_ratio_cruise = thrust_ratio_cruise/(rho_cruise/rho_SL); % riferisco il matching chart al SL
plot(wing_load, thrust_ratio_cruise, 'b','Color', 'g', 'LineWidth', 2);

% Landing climb
vLdgClimb = 1.23*Vstall;
gammaLdgClimb = atan(3.2/100);
thrust_ratio_ldg_climb = 2*(0.5*rho_SL*(vLdgClimb/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0+C_D_flap+C_D_LG) + k_polare_livello0*(2.*(g*wing_load)*cos(gammaLdgClimb)/(rho_SL*(vLdgClimb/3.6)^2)).^2) + sin(gammaLdgClimb));
plot(wing_load, thrust_ratio_ldg_climb, 'b','Color', 'k', 'LineWidth', 2);

% Approach climb
vAppClimb = 1.41*Vstall;
gammaAppClimb = atan(2.1/100);
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S * sin(deg2rad(20))^2;
thrust_ratio_app_climb = 2*(0.5*rho_SL*(vAppClimb/3.6)^2*(g*wing_load).^(-1).*((Cd0_livello0+C_D_flap) + k_polare_livello0*(2.*(g*wing_load)*cos(gammaAppClimb)/(rho_SL*(vAppClimb/3.6)^2)).^2) + sin(gammaAppClimb));
plot(wing_load, thrust_ratio_app_climb, 'b','Color', 'c', 'LineWidth', 2);

legend('Takeoff', 'Stall Speed', 'Climb', 'Cruise', 'Landing Climb', 'Approach Climb');

hold off;
% Interpolazione del thrust ratio per ciascuna curva al wing load di design
thrust_ratio_decollo_interp = interp1(wing_load, thrust_ratio_decollo, wing_load_max, 'linear');
thrust_ratio_climb_interp = interp1(wing_load, thrust_ratio_climb, wing_load_max, 'linear');
thrust_ratio_cruise_interp = interp1(wing_load, thrust_ratio_cruise, wing_load_max, 'linear');
thrust_ratio_ldg_climb_interp = interp1(wing_load, thrust_ratio_ldg_climb, wing_load_max, 'linear');
thrust_ratio_app_climb_interp = interp1(wing_load, thrust_ratio_app_climb, wing_load_max, 'linear');

% Thrust ratio massimo tra tutte le curve
thrust_ratio_des = max([thrust_ratio_decollo_interp, thrust_ratio_climb_interp, thrust_ratio_cruise_interp, ...
    thrust_ratio_ldg_climb_interp, thrust_ratio_app_climb_interp]);

disp(['Thrust ratio minimo al massimo wing load di ', num2str(wing_load_max), ' kg/m²: ', num2str(thrust_ratio_des)]);