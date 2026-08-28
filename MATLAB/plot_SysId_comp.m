
font_size = 14;

subplot(311)
plot(time,Vm,'LineWidth',2)
title('SysId Verification')
grid
ylabel('$u(t)$~[V]','FontSize',font_size,'Interpreter','latex')
ylim([-1 1.1*max(Vm)])

subplot(312)
plot(time,xc_m,'b',time,xc_test,'r--','LineWidth',2)
grid
ylabel('$x_c(t)$~[m]','FontSize',font_size,'Interpreter','latex')
ylim([-0.01 1.1*max(xc_m)])

subplot(313)
plot(time,rad2deg(alpha_rad),'b',time,rad2deg(alpha_test),'r--','LineWidth',2)
grid
ylabel('$\alpha (t)$~[deg]','FontSize',font_size,'Interpreter','latex')
xlabel('Time (s)','FontSize',font_size,'Interpreter','latex')
ylim(max(abs(Vm))*[-1,1])