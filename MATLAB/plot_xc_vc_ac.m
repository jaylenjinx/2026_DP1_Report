
font_size = 14;
fs = 1/ts;
fn = 0.5*fs;

vc_hf  = filtered_derivative(xc_m,ts,0.5*fn);

subplot(311)
plot(time,xc_m)
title('Cart Position, Speed, and Acceleration')
grid
ylabel('$x_c (t)$~[m]','FontSize',font_size,'Interpreter','latex')
xlabel('Time (s)','FontSize',font_size,'Interpreter','latex')

subplot(312)
plot(time,vc_hf,time,vc,'--r')
grid
ylabel('$v_c (t)$~[m/s]','FontSize',font_size,'Interpreter','latex')
xlabel('Time (s)','FontSize',font_size,'Interpreter','latex')

subplot(313)
plot(time,ac)
grid
ylabel('$a_c (t)$~[m/s$^2$]','FontSize',font_size,'Interpreter','latex')
xlabel('Time (s)','FontSize',font_size,'Interpreter','latex')

