% Decollo
TOP = TOP * lb2kg / sqft2sqm ; % conversione in [kg/m^2]
% Calcolo C_L_max
C_L_max_clean = 0.9*C_L_max_2D*cosd(sweep25_des);

delta_C_L_flap_2D = 1.55; % slat + Fowler flap
Sflap = 0.85*S_ref; % da misura ala A320
delta_C_L_flap = 0.92*delta_C_L_flap_2D*Sflap/S_ref*cosd(sweep25_des);

C_L_max_flapped = C_L_max_clean + delta_C_L_flap;

thrust_ratio_decollo = W_S_des / (TOP * C_L_max_flapped); % []

% Stall Speed
wing_load_max = 0.5*rho_SL*(1.136*Vstall*kmph2mps)^2*C_L_max_flapped/g; % [km/m^2]

% Climb
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(35)^2;
C_D_LG = 2.92e-03*(WTO_curr*kg2lb)^0.785/(S_ref*sqm2sqft);
% first segment
gamma1 = atan(0/100);
thrust_ratio1 = 2*(0.5*rho_SL*(1.2*Vstall*kmph2mps)^2/(W_S_des*g)*((Cd0+C_D_flap+C_D_LG) + k_polare*(2*(W_S_des*g)*cos(gamma1)/(rho_SL*(1.2*Vstall*kmph2mps)^2))^2) + sin(gamma1));
% second segment
gamma2 = atan(2.4/100);
thrust_ratio2 = 2*(0.5*rho_SL*(1.2*Vstall*kmph2mps)^2/(W_S_des*g)*((Cd0+C_D_flap) + k_polare*(2*(W_S_des*g)*cos(gamma2)/(rho_SL*(1.2*Vstall*kmph2mps)^2))^2) + sin(gamma2));
% third segment
gamma3 = atan(1.2/100);
thrust_ratio3 = 2*(0.5*rho_SL*(1.25*Vstall*kmph2mps)^2/(W_S_des*g)*((Cd0) + k_polare*(2*(W_S_des*g)*cos(gamma3)/(rho_SL*(1.25*Vstall*kmph2mps)^2))^2) + sin(gamma3));

thrust_ratio_climb = max([thrust_ratio1, thrust_ratio2, thrust_ratio3]);

% Cruise
gammaCruise = 0;
thrust_ratio_cruise = 2*(0.5*rho_cruise*(V_cruise*kmph2mps)^2/(W_S_des*g)*((Cd0) + k_polare*(2*(W_S_des*g)*cos(gammaCruise)/(rho_cruise*(V_cruise*kmph2mps)^2))^2) + sin(gammaCruise));
thrust_ratio_cruise = thrust_ratio_cruise/(rho_SL/rho_cruise); % riferisco il matching chart al SL

% Landing climb
vLdgClimb = 1.23*Vstall;
gammaLdgClimb = atan(3.2/100);
thrust_ratio_ldg_climb = 2*(0.5*rho_SL*(vLdgClimb*kmph2mps)^2/(W_S_des*g)*((Cd0+C_D_flap+C_D_LG) + k_polare*(2*(W_S_des*g)*cos(gammaLdgClimb)/(rho_SL*(vLdgClimb*kmph2mps)^2))^2) + sin(gammaLdgClimb));

% Approach climb
vAppClimb = 1.41*Vstall;
gammaAppClimb = atan(2.1/100);
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(20)^2;
thrust_ratio_app_climb = 2*(0.5*rho_SL*(vAppClimb*kmph2mps)^2/(W_S_des*g)*((Cd0+C_D_flap) + k_polare*(2*(W_S_des*g)*cos(gammaAppClimb)/(rho_SL*(vAppClimb*kmph2mps)^2))^2) + sin(gammaAppClimb));

% Thrust ratio massimo tra tutte le curve
thrust_ratio_des = max([thrust_ratio_decollo, thrust_ratio_climb, thrust_ratio_cruise, ...
    thrust_ratio_ldg_climb, thrust_ratio_app_climb]);

%disp(['Thrust ratio minimo al wing load di ', num2str(W_S_des), ' kg/m²: ', num2str(thrust_ratio_des)]);