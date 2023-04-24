function [beamform,beamlook] = h_run_beamformer(source,solvegrid,psiObj,c0,plotr,plotz)

%% setup variables
f0 = source.frq;

%% array
lambda = c0/f0;
k0 = 2*pi/lambda;
degResolution = 4.5;

%% extract psigfz
zout = psiObj.zout;
rout = psiObj.rout;

irrx = floor(plotr/solvegrid.dr)+1; % range bin cursor
if rout(irrx)~=plotr
    warning('choosing %d instead of %d m',rout(irrx),plotr)
end

psi = psiObj.psi_gf(:,irrx);

%% get array and complex pressure on array
[numChannels,zArray,beamlook,ts_f] = eb_bf_makeArray(lambda,degResolution,plotz,zout,psi);

% mvdr
window = eb_bf_mvdr(zArray,beamlook,ts_f,k0);
steer = eb_bf_steervector(beamlook,zArray,window,k0);
angledepth_mvdr = eb_bf_beamform(beamlook,steer,ts_f);

% chebyshev comparison
window = eb_bf_window(numChannels);
steer = eb_bf_steervector(beamlook,zArray,window,k0);
angledepth_cheby = eb_bf_beamform(beamlook,steer,ts_f);

% scale factor combination
w = 0.2; % 0 = mvdr (narrow mainlobe), 1 = cheby (wide mainlobe)
beamform = w.*angledepth_cheby + (1-w).*angledepth_mvdr;

end

