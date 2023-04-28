%% harness
% eeshan bhatt (WHOI)
% ebhatt@whoi.edu
% april 2023
%
% main script to demonstrate components of this workflow
% accesses scripts in numbered subfolders

%% prep workspace
clear; clc; close all;

%% 1-ssp
% load a ssp file of your choosing into "profile"
% profile.ssp
% profile.depth

sspfile = '1-ssp/irminger-sep2018.mat';
profile = load(sspfile);

%% 2-rampe

% add path
addpath('2-rampe/');

% common parameters
sourceDepth = 75; % m
sourceFrequency = 200; % Hz

% beamed source
beamwidth = 12;
steerAngle = -10;

% computation
maxRange = 60e3; % m
dzm = 5;

% run RAM
fprintf('running RAM... \n');
[beamed,omni,solvegrid,~,speed,source,bathy,info] = ...
    h_compute_tl_beam_omni(profile,sourceDepth,sourceFrequency,beamwidth,steerAngle,maxRange,dzm);

%% plot 2-rampe

beamed.tl = 20.*log10(abs(beamed.psi_tl+eps))+beamed.di;
omni.tl   = 20.*log10(abs(omni.psi_tl+eps));

% figure 1
h_plot_tl(omni,source,speed,bathy);

% figure 2
h_plot_tl(beamed,source,speed,bathy);
subtitle(sprintf('beamwidth=%d, steerangle = %d',beamwidth,steerAngle));

%% 3-beamformer

addpath('3-beamformer/');

c0 = speed.c0;
plotr = 31000;
plotz = 75;

[beamformer.beamed,beamlook] = h_run_beamformer(source,solvegrid,beamed,c0,plotr,plotz);
[beamformer.omni,~]          = h_run_beamformer(source,solvegrid,omni,c0,plotr,plotz);

% figure 3
h_plot_beamformer(beamformer.beamed+beamed.di,beamformer.omni,beamlook);