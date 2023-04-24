% h_compute_tl_beam_omni
% Eeshan Bhatt, August 2022
%
% INPUTS
% filename      : what data will be saved as
% profile       : object containing ssp and depth fields
% sourceDepth   : depth of source
% f0            : center frequency
% beamwidth     : beamwidth of launch ray
% steerAngle    : steering angle of launch ray in degrees
% maxRange      : maximum range to compute out to
% dzm           : downscaling factor for depth grid

function [beamed,omni,solvegrid,plotgrid,speed,source,bathy,info] = h_compute_tl_beam_omni(profile,sourceDepth,f0,beamwidth,steerAngle,maxRange,dzm)

%% classify inputs
% sound speed = profile.ssp;
% sound speed depth = profile.depth;
profile.ssp = profile.ssp;
profile.depth = profile.depth;

% source depth
zsrc = sourceDepth;

% src-rcvr max range
rmax=maxRange;

% beam parameters
bmwd    =  beamwidth;          % beamwidth
theta   = steerAngle;         % steering angle (deg)

% center frequency
fo = f0;

filename = 'demo';

%% omni directional source parameters for RAM
% run to establish base parameters (could optimize this)
[speed,source,~,solvegrid,~,info] = h_prep_ram_input(...
        zsrc,fo,profile.ssp,profile.depth,rmax,[filename '-omni-input'],dzm);
    
[OMNI_PSI,omni.zout,omni.rout] = h_run_ram([filename '-omni-input']);
omni.rout(1) = eps;
[SCALE,PSI0] = eb_get_greens_tl_factors(fo,omni.rout,info.dim,speed.c0);

% get psi
for irr = 1:solvegrid.nr
    PSI_TL_OMNI(:,irr) = PSI0(irr)*OMNI_PSI(:,irr);
    PSI_GF_OMNI(:,irr) = SCALE(irr)*OMNI_PSI(:,irr);
end

omni.psi_tl = PSI_TL_OMNI;
omni.psi_gf = PSI_GF_OMNI;

%% beam source pattern
% cos^{2}(\pi (tht-thtgtrd)(z-zsrc)/lwx),
% lwx aperture for beamwidth at freq and bmwdrd

lambdagrid = speed.c0./fo;
[zsrcx,DI,iffc] = eb_get_beam_source_pattern(theta,bmwd,source,lambdagrid,solvegrid);

%% plot beam at center frequency
zsrc    =  zsrcx(:,iffc);

% run ram
[speed,source,bathy,solvegrid,plotgrid,info] = h_prep_ram_input(zsrc,fo,...
    profile.ssp,profile.depth,rmax,[filename '-beam-input'],dzm);

[BEAM_PSI,beamed.zout,beamed.rout] = h_run_ram([filename '-beam-input']);
rout(1) = eps;
beamed.di = DI;
beamed.theta = steerAngle;

% get psi
for irr = 1:solvegrid.nr
    PSI_TL_BEAM(:,irr) = PSI0(irr)*BEAM_PSI(:,irr);
    PSI_GF_BEAM(:,irr) = SCALE(irr)*BEAM_PSI(:,irr);
end

beamed.psi_tl = PSI_TL_BEAM;
beamed.psi_gf = PSI_GF_BEAM;

%% save
% save([filename '-output'],...
    %'speed','source','bathy','solvegrid','plotgrid','info','beamed','omni','-v7.3');

end