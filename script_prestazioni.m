W4_W3 = exp(-(SFC_cruise*range)/(M_des*a_cruise*mps2kmph*E_curr)); %cruise
Wloiter1 = exp(-(SFC_loiter*loiter1)/(E_curr/0.866)); %loiter1
W8_W7 = exp(-(SFC_cruise*diversione)/(M_des*a_cruise*mps2kmph*E_curr)); %diversion
W10_W9 = exp(-(SFC_loiter*loiter2)/(E_curr/0.866)); %loiter2

fuel_fraction = 1.05*(1-(W2_WTO*W3_W2*W4_W3*Wloiter1*W5_W4*W8_W7*W10_W9));

W_fuel = fuel_fraction * WTO_curr; % [kg]