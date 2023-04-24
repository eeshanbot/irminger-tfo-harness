function [] = h_plot_beamformer(beam1,beam2,beamlook);

figure('name','beamformer','renderer','painters','position',[100 100 500 800]);

thetadeg = rad2deg(beamlook) - 90;


plot(beam1,thetadeg);
hold on
plot(beam2,thetadeg);
hold off

grid on
xlabel('dB');
ylabel('degrees from horizontal');

legend('beamed','omnidirectional');

ylim([-25 25]);


end

