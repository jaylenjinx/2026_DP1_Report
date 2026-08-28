%% Demonstration Practical 1: System Identification
% 41277 Control Design
% University of Technology Sydney, Australia
%
% Coordinator: A/Prof Ricardo Aguilera
%
% Team Member 1: Rhyse Williams
% Team Member 2: Jaylen Avtarovski
% Team Member 3: Elina Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
s = tf('s'); %define Laplace operator

%% 1. Read saved experimental data
disp('***********************************************')
disp('1. Loading experimental data...')
%% Add your own experimental data obtained in lab 3
dataFile = 'data_test_01.mat';
load(dataFile)

figure(101)
plot_exp_data;  % plot your experimental data

%% 2. cart speed and acceleration
disp([newline,'***********************************************'])
disp('2. Obtaining cart speed and acceleration...')
vc  = filtered_derivative(xc_m,ts,25);
ac = filtered_derivative(vc,ts,10);

figure(102)
plot_xc_vc_ac;  % plot filtered derivatives 

%% 3. System Identification Gux(s) (simplified)
disp([newline,'***********************************************'])
disp('3. Identifying simplified Gux(s) transfer function...')
%
% vc: cart speed ==> xc = (1/s)*vc 
%
%  voltage to speed  speed to position
% u -->[Guvc(s)]-- vc -->[1/s]-->xc
%
%               a
%  Guvc(s) = ------
%             s + b
%
%               a        1
%   Gux(s) = -------- =  - Guvc(s)
%            s(s + b)    s

% ADJUST the input and output data, 
% as well as number of poles and zeros
y = vc; % TF output signal
u = Vm; % TF input signal
data = iddata(y,u,ts);      %data format required by tfest;
np=1;                       %Number of poles
nz=0;                       %Number of zeros 
Guvc_id = tfest(data,np,nz) % voltage to cart speed TF
Gux_id = (1/s)*Guvc_id      % voltage to cart position TF
Gux_id = 1*Gux_id;

%% 4. System Identification Gxa(s)
disp([newline,'***********************************************'])
disp('4. Identifying Gxa(s) transfer function...')
%
% ac: cart acceleration
%
% position to acceleration  acceleration to angle
%    xc-->[s^2]---- ac ---->[Gaca(s)]-->alpha
%

% ADJUST the input and output data, 
% as well as number of poles and zeros
y = alpha_rad;  % TF output signal
u = ac;         % TF input signal
data = iddata(y,u,ts);      %data format required by tfest;
np=2;                       %Number of poles
nz=0;                       %Number of zeros
Gaca_id = tfest(data,np,nz) % cart acceleration to angle
Gxa_id = (s^2)*Gaca_id      % cart position to angle

%% 5. Verification 
disp([newline,'***********************************************'])
disp('SysId Verification...')
% timeseries required to read saved signals in Simulink
vm_data = timeseries(Vm, time); 
alpha_data = timeseries(alpha_rad, time);
xc_data = timeseries(xc_m, time);
Tsim = time(end);

%% Verification for Gux(s)
u_data = vm_data;   %time series format
[num, den] = tfdata(Gux_id, 'v');
Gp_test.Numerator = num;
Gp_test.Denominator = den;
sim('SysId_verification')   % run Simulink model verification
xc_test = y_test;           % simulated cart position

%% Verification for Gxa(s)
u_data = xc_data;
[num, den] = tfdata(Gxa_id, 'v');
Gp_test.Numerator = num;
Gp_test.Denominator = den;
sim('SysId_verification')   % run Simulink model verification
alpha_test = y_test;        % simulated pendulum angle

%% Comparison plot
figure(103)
plot_SysId_comp;    % plot SysId comparison

%% 6. Saving TFs 
disp([newline,'***********************************************'])
disp('Saving Identified TFs...')
FileName = 'data_TFs_cart_pend.mat';
save(FileName)

disp(' ')
disp('Done!!!')
disp(' ')