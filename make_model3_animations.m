%% Model 3 animations (results pack)
clear; close all; clc;

%% Parameters
p.g  = 9.81;
p.l  = 1.0;
p.k  = 30.0;
p.a  = p.l/2;
p.L0 = p.l/2;

p.m1 = 1.0;
p.m2 = 1.0;

solver = @ode113;
opts = odeset('RelTol',1e-9,'AbsTol',1e-11);

outDir = fullfile(pwd,'model3_anims');
if ~exist(outDir,'dir'), mkdir(outDir); end

animBase = struct( ...
  'fps', 30, ...
  'speed', 1.0, ...
  'trail', true, ...
  'trailLength', 350, ...
  'saveVideo', true, ...
  'visible', false, ...
  'resolution', 140, ...
  'filename', '' ...
);

cases = [
  struct('tag','phase1_harmony',  'omega0',0.5, 'tspan',[0 25], 'speed',1.0)
  struct('tag','phase2_drift',    'omega0',2.5, 'tspan',[0 25], 'speed',1.0)
  struct('tag','phase3_fracture', 'omega0',5.0, 'tspan',[0 25], 'speed',1.0)
  struct('tag','phase4_rotor',    'omega0',12.0, 'tspan',[0 14], 'speed',1.0)
];

for i = 1:numel(cases)
  c = cases(i);
  Y0 = [0; c.omega0; 0; 0];

  res3 = simulateCoupledPendulums(p, 3, c.tspan, Y0, solver, opts);

  anim = animBase;
  anim.speed = c.speed;
  anim.filename = fullfile(outDir, sprintf('model3_%s_omega0_%.2f.mp4', c.tag, c.omega0));

  fprintf('Rendering %s (omega0=%.2f) -> %s\n', c.tag, c.omega0, anim.filename);
  animateCoupledPendulums(res3, anim);
end

fprintf('Done. Videos saved in: %s\n', outDir);


