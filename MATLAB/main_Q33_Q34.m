%% Demonstration Practical 1: Q3) Digital Twin
%
% 41277 Control Design
% University of Technology Sydney, Australia
%
% A/Prof Ricardo Aguilera
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
s = tf('s'); %define Laplace operator

%% 1. Read saved TFs data
disp('***********************************************')
disp('1. Loading experimental data...')
%% Add your own experimental data obtained in lab 3
dataFile = 'data_TFs_cart_pend.mat';
load(dataFile)

%% 2. Known System parameters
disp('***********************************************')
disp('1. Known Parameters...')
M = 0.22    % Cart mass in Kg
m = 0.1     % Pendulum mass in Kg
g = 9.81     % Gravitational acceleration m/s^2

%% 3. Q3.3) Provide the identified Parameters for your pendulum
disp([newline,'***********************************************'])
disp('2. Identified Parameters...')
% CHANGE these values with the ones you have identified
a_hat = 0.887
b_hat = 16.25
k_hat = -3.902
a_hat1 = 0.5832
a_hat0 = 38.58

lp = g / a_hat0 % little l
L = 3 * lp / 2  % Equivalent length of the pendulum
bp = m * (lp^2) * a_hat1 % friction coefficient of the pendulum
bc = (M + m) * b_hat
Kv = (M + m) * a_hat % DC-Motor Voltage to force gain N/v

%% 4. Q3.4) Run Simulation
%% Make sure to modify the Simulink file sim_2026_cart_pend.slx
%% Add the team member names in your simulation file
disp([newline,'***********************************************'])
disp('2. Runnig your Cart Pendulum system simulation...')

% Initial Conditions
xc_o = 0;
vc_o = 0;
alpha_o = 0;
w_o = 0;

sim('sim_2026_cart_pend.slx')

%% 5. Add your comparison plot here
% compare the nonlinear model results against the liner model ones
figure(201); clf
set(gcf,'Color','w','Position',[100 100 900 700])

subplot(411)
plot(time, u, 'k', 'LineWidth', 1.3); grid on
ylabel('u [V]')
title('Cart pendulum digital twin: nonlinear vs linear model')
ylim([min(u)-0.5, max(u)+0.5])

subplot(412)
plot(time, xc_NL, 'b-',  'LineWidth', 1.6); hold on
plot(time, xc_L, 'r--', 'LineWidth', 1.6); grid on
ylabel('x_c [m]')
legend('nonlinear model','linear model','Location','southeast')
ylim([min(xc_NL)-0.05, max(xc_NL)+0.05])

subplot(413)
plot(time, alpha_NL*180/pi, 'b-',  'LineWidth', 1.6); hold on
plot(time, alpha_L*180/pi, 'r--', 'LineWidth', 1.6); grid on
ylabel('\alpha [deg]')
legend('nonlinear model','linear model','Location','northeast')
ylim([-7.5, 7.5])

subplot(414)
yyaxis left
plot(time, (xc_NL-xc_L)*1000, 'LineWidth', 1.3); ylabel('\Deltax_c [mm]')
yyaxis right
plot(time, (alpha_NL-alpha_L)*180/pi, 'LineWidth', 1.3); ylabel('\Delta\alpha [deg]')
grid on; xlabel('time [s]')
title('Nonlinear - linear mismatch')
ylim([-0.5, 0.5])

disp(' ')
disp('Done!!!')
disp(' ')