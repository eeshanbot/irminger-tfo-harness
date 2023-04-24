function [] = h_plot_tl(tlobj,source,speed,bathy)

rr = tlobj.rout;
zz = tlobj.zout;
tl = tlobj.tl;

figure('name','ram-plot','renderer','painters','position',[2000 2000 1500 800]);
tiledlayout(1,5,'TileSpacing','compact');

%% tile 1 - ssp
nexttile(1);
plot_cw = speed.cw(1:end-2);
plot_zw = speed.zw(1:end-2);
plot(plot_cw,plot_zw);
hold on
plot(speed.cs,speed.zs);
hold off
set(gca,'ydir','reverse');
xlabel('c [m/s]');
ylabel('depth [m]');
grid on
ylim([0 max(zz)]);
xbuff = 0.01;
cmin = min(plot_cw);
cmax = max(plot_cw);
xlim([(1-xbuff/10).*cmin (1+xbuff).*cmax]);

%% tile 2:5
nexttile([1 4]);

%pcolor(rout./1000,zg,xram)
imagescn(rr./1000,zz,tl);
shading interp

% coloring
% colormap(jet);
cmocean('thermal',30);
colorbar

c_mid = floor(median(tl(:),'omitnan'));
hit3 = mod(c_mid,3);
while hit3 ~=0
    c_mid = c_mid+1;
    hit3 = mod(c_mid,3);
end
caxis([c_mid-6 c_mid+24]);

% plot details
xlabel('range [km]');

titstr = {'RAM PE',['zs=' num2str(source.depth) ' m, f=' num2str(source.frq) ' Hz']};
title(titstr);
set(gca,'ydir','reverse');

if bathy.rb == 0
    hline(bathy.zb,'color',[1 1 1 0.5],'linewidth',2);
else
    plot(bathy.rb,bathy.zb,'w','linewidth',2);
end

yticklabels([]);

end

