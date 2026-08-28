%% Demonstration Practical 1: Q3) Digital Twin
%
% 41277 Control Design
% University of Technology Sydney, Australia
%
% A/Prof Ricardo Aguilera
%
% Team Member 1: Jaylen Avtarovski (24767939)
% Team Member 2: Rhyse Williams (24817532)
% Team Member 3: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
s = tf('s'); %define Laplace operator

%% 1. Read saved TFs data
disp('***********************************************')
disp('1. Loading experimental data...')
dataFile = 'data_TFs_cart_pend.mat';
load(dataFile)

%% 2. Known System parameters
disp('***********************************************')
disp('2. Known Parameters...')
M = 0.22;       % Cart mass in kg
m = 0.1;        % Pendulum mass in kg
g = 9.81;       % Gravitational acceleration m/s^2  (stub had 8.1 -- typo)

%% 3. Q3.3) Identified parameters for your pendulum
disp([newline,'***********************************************'])
disp('3. Identified Parameters...')
L  = 0.3814;        % Actual pendulum length [m]        (= 3*lp/2)
bp = 0.0037708;     % Pendulum friction coeff [N m s/rad]
Kv = 0.28384;       % DC-motor voltage-to-force gain [N/V]
bc = 5.2000;        % Cart friction coeff [N s/m]        (missing from the stub)

lp = 2*L/3;         % Distance pivot -> centre of oscillation [m]

fprintf('  lp = %.4f m | L = %.4f m | bp = %.6f | Kv = %.5f | bc = %.4f\n', ...
        lp, L, bp, Kv, bc);

%% 3b. Analytical transfer functions for the LINEAR branch (Q2.2)
% Remark 6: the first block must be the FULL Gux(s), not the simplified one.
%
%            Kv*( m*lp^2 s^2 + bp s + m*g*lp )
%  Gux(s) = -----------------------------------
%                      s * Delta(s)
%
%  Delta(s) = M*m*lp^2 s^3 + [(M+m)bp + bc*m*lp^2] s^2
%             + [(M+m)*m*g*lp + bc*bp] s + bc*m*g*lp
%
%                  -m*lp s^2
%  Gxa(s) = -----------------------------
%            m*lp^2 s^2 + bp s + m*g*lp

Delta   = [ M*m*lp^2, ...
            (M+m)*bp + bc*m*lp^2, ...
            (M+m)*m*g*lp + bc*bp, ...
            bc*m*g*lp ];

num_Gux = Kv*[ m*lp^2, bp, m*g*lp ];
den_Gux = [Delta, 0];              % the extra s (speed -> position integrator)

num_Gxa = [ -m*lp, 0, 0 ];
den_Gxa = [ m*lp^2, bp, m*g*lp ];

Gux_full = tf(num_Gux, den_Gux)
Gxa_ana  = tf(num_Gxa, den_Gxa)

disp('  Gux poles:'); disp(roots(den_Gux).')

% --- Optional: push the coefficients straight into the Simulink blocks ---
% (otherwise type the expressions below into the block dialogs by hand)
% load_system('sim_2026_cart_pend');
% set_param('sim_2026_cart_pend/Linear Model/Gux (full)', ...
%           'Numerator','num_Gux','Denominator','den_Gux');
% set_param('sim_2026_cart_pend/Linear Model/Gxa', ...
%           'Numerator','num_Gxa','Denominator','den_Gxa');

%% 4. Q3.4) Run Simulation
disp([newline,'***********************************************'])
disp('4. Running your Cart Pendulum system simulation...')

% Initial Conditions
xc_o    = 0;
vc_o    = 0;
alpha_o = 0;
w_o     = 0;

sim('sim_2026_cart_pend.slx')

%% 5. Extract the logged signals
% The To Workspace blocks log in "Timeseries" format by default, so the
% variables xc_NL, alpha_NL, xc_L, alpha_L, u and time come back as
% timeseries objects. This handles both that and the "Array" format.
if isa(xc_NL,'timeseries')
    t_sim = xc_NL.Time;
    u_sim = squeeze(u.Data);
    xc_nl = squeeze(xc_NL.Data);      al_nl = squeeze(alpha_NL.Data);
    xc_li = squeeze(xc_L.Data);       al_li = squeeze(alpha_L.Data);
else
    t_sim = time;                     u_sim = u;
    xc_nl = xc_NL;                    al_nl = alpha_NL;
    xc_li = xc_L;                     al_li = alpha_L;
end

%% 6. Comparison plot: nonlinear vs linear model
figure(201); clf
set(gcf,'Color','w','Position',[100 100 900 700])

subplot(411)
plot(t_sim, u_sim, 'k', 'LineWidth', 1.3); grid on
ylabel('u [V]')
title('Cart pendulum digital twin: nonlinear vs linear model')
ylim([min(u_sim)-0.5, max(u_sim)+0.5])

subplot(412)
plot(t_sim, xc_nl, 'b-',  'LineWidth', 1.6); hold on
plot(t_sim, xc_li, 'r--', 'LineWidth', 1.6); grid on
ylabel('x_c [m]')
legend('nonlinear model','linear model','Location','southeast')

subplot(413)
plot(t_sim, al_nl*180/pi, 'b-',  'LineWidth', 1.6); hold on
plot(t_sim, al_li*180/pi, 'r--', 'LineWidth', 1.6); grid on
ylabel('\alpha [deg]')
legend('nonlinear model','linear model','Location','northeast')

subplot(414)
yyaxis left
plot(t_sim, (xc_nl-xc_li)*1000, 'LineWidth', 1.3); ylabel('\Deltax_c [mm]')
yyaxis right
plot(t_sim, (al_nl-al_li)*180/pi, 'LineWidth', 1.3); ylabel('\Delta\alpha [deg]')
grid on; xlabel('time [s]')
title('Nonlinear - linear mismatch')

%% 7. Quantitative comparison (numbers to quote in the report)
disp([newline,'***********************************************'])
disp('Nonlinear vs linear comparison:')
fprintf('  max |alpha|          : NL %.3f deg   L %.3f deg\n', ...
        max(abs(al_nl))*180/pi, max(abs(al_li))*180/pi);
fprintf('  max |xc|             : NL %.4f m     L %.4f m\n', ...
        max(abs(xc_nl)), max(abs(xc_li)));
fprintf('  RMS mismatch in xc   : %.4f mm\n',  ...
        sqrt(mean((xc_nl-xc_li).^2))*1000);
fprintf('  RMS mismatch in alpha: %.5f deg\n', ...
        sqrt(mean((al_nl-al_li).^2))*180/pi);
fprintf('  peak mismatch in alpha: %.5f deg\n', ...
        max(abs(al_nl-al_li))*180/pi);

disp(' ')
disp('Done!!!')
disp(' ')
