%% Storyline figures (Coupled Pendulums)
clear; close all; clc;

energyPlotWindow_s = 5; % seconds shown on the Phase-2 energy plot

%% Parameters (match your project)
p.g  = 9.81;
p.l  = 1.0;
p.k  = 30.0;
p.a  = p.l/2;
p.L0 = p.l/2;

% Choose a mass case
p.m1 = 1.0;
p.m2 = 1.0;

solver = @ode113;
opts = odeset('RelTol',1e-9,'AbsTol',1e-11);

outDir = fullfile(pwd,'story_figs');
if ~exist(outDir,'dir'), mkdir(outDir); end



%% "Story beats" (omega0 in rad/s)
omega_small = 0.5;
omega_mid   = 2.5;
omega_huge  = 5.0;
omega_loop  = 12.0;  % adjust upward if you want guaranteed rotations

tspan_small = [0 40];
tspan_mid   = [0 40];
tspan_huge  = [0 40];
tspan_loop  = [0 25];

%% Phase 1: Harmony (all overlap)
res1s = simulateCoupledPendulums(p, 1, tspan_small, [0; omega_small; 0; 0], solver, opts);
res2s = simulateCoupledPendulums(p, 2, tspan_small, [0; omega_small; 0; 0], solver, opts);
res3s = simulateCoupledPendulums(p, 3, tspan_small, [0; omega_small; 0; 0], solver, opts);

fig = figure('Color','w','Name','Phase1');
plotOverlayTheta(res1s,res2s,res3s, sprintf('Phase 1: Harmony (\\omega_0=%.2f rad/s)', omega_small));
saveas(fig, fullfile(outDir,'phase1_theta_overlay.png'));

%% Phase 2: Drift (Model 1 runs ahead; energy exchange imperfect in Model 3)
res1m = simulateCoupledPendulums(p, 1, tspan_mid, [0; omega_mid; 0; 0], solver, opts);
res3m = simulateCoupledPendulums(p, 3, tspan_mid, [0; omega_mid; 0; 0], solver, opts);

fig = figure('Color','w','Name','Phase2_TimeZoom');
plotZoomThetaCompare(res1m,res3m, sprintf('Phase 2: Drift (\\omega_0=%.2f rad/s)', omega_mid));
saveas(fig, fullfile(outDir,'phase2_time_zoom_model1_vs_3.png'));

fig = figure('Color','w','Name','Phase2_EnergyExchange');
plotEnergyExchange(res1m,res3m,energyPlotWindow_s, sprintf('Phase 2: Energy Exchange (\\omega_0=%.2f rad/s)', omega_mid));
saveas(fig, fullfile(outDir,'phase2_energy_exchange.png'));

%% Phase 3: Fracture (geometry dominates; configuration space & phase portrait distort)
res1h = simulateCoupledPendulums(p, 1, tspan_huge, [0; omega_huge; 0; 0], solver, opts);
res3h = simulateCoupledPendulums(p, 3, tspan_huge, [0; omega_huge; 0; 0], solver, opts);

fig = figure('Color','w','Name','Phase3_Config');
plotConfigSpaceCompare(res1h,res3h, sprintf('Phase 3: Fracture (\\omega_0=%.2f rad/s)', omega_huge));
saveas(fig, fullfile(outDir,'phase3_config_space.png'));

fig = figure('Color','w','Name','Phase3_PhasePortrait');
plotPhasePortraitCompare(res1h,res3h, sprintf('Phase 3: Fracture (\\omega_0=%.2f rad/s)', omega_huge));
saveas(fig, fullfile(outDir,'phase3_phase_portrait.png'));

%% Phase 4: Chaos / Separatrix crossing (rotor vs oscillator)
res1x = simulateCoupledPendulums(p, 1, tspan_loop, [0; omega_loop; 0; 0], solver, opts);
res3x = simulateCoupledPendulums(p, 3, tspan_loop, [0; omega_loop; 0; 0], solver, opts);

fig = figure('Color','w','Name','Phase4_WrappedPhase');
plotWrappedPhase(res1x,res3x, sprintf('Phase 4: Rotor regime (\\omega_0=%.2f rad/s)', omega_loop));
saveas(fig, fullfile(outDir,'phase4_wrapped_phase.png'));

fprintf('Saved storyline figures to: %s\n', outDir);

%% ---- Local plotting helpers ----
function plotOverlayTheta(r1,r2,r3, ttl)
  tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

  nexttile; hold on; grid on;
  plot(r1.t, rad2deg(r1.Y(:,1)),'LineWidth',1.2);
  plot(r2.t, rad2deg(r2.Y(:,1)),'LineWidth',1.2);
  plot(r3.t, rad2deg(r3.Y(:,1)),'LineWidth',1.2);
  xlabel('t (s)'); ylabel('\theta_1 (deg)');
  title(ttl);
  legend('Model 1','Model 2','Model 3','Location','best');

  nexttile; hold on; grid on;
  plot(r1.t, rad2deg(r1.Y(:,3)),'LineWidth',1.2);
  plot(r2.t, rad2deg(r2.Y(:,3)),'LineWidth',1.2);
  plot(r3.t, rad2deg(r3.Y(:,3)),'LineWidth',1.2);
  xlabel('t (s)'); ylabel('\theta_2 (deg)');
end

function plotZoomThetaCompare(r1,r3, ttl)
  tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

  % pick a window where drift is visible (late time)
  t0 = 15; t1 = 25;

  nexttile; hold on; grid on;
  plot(r1.t, rad2deg(r1.Y(:,1)),'LineWidth',1.2);
  plot(r3.t, rad2deg(r3.Y(:,1)),'LineWidth',1.2);
  xlim([t0 t1]);
  xlabel('t (s)'); ylabel('\theta_1 (deg)');
  title([ttl ' | time zoom']);
  legend('Model 1','Model 3','Location','best');

  nexttile; hold on; grid on;
  plot(r1.t, rad2deg(r1.Y(:,3)),'LineWidth',1.2);
  plot(r3.t, rad2deg(r3.Y(:,3)),'LineWidth',1.2);
  xlim([t0 t1]);
  xlabel('t (s)'); ylabel('\theta_2 (deg)');
end

function plotEnergyExchange(r1,r3, tWindow_s, ttl)
  tiledlayout(2,1,'TileSpacing','compact','Padding','compact');


  E1_1 = r1.E.T1 + r1.E.Vg1;
  E2_1 = r1.E.T2 + r1.E.Vg2;
  Es_1 = r1.E.Vs;

  E1_3 = r3.E.T1 + r3.E.Vg1;
  E2_3 = r3.E.T2 + r3.E.Vg2;
  Es_3 = r3.E.Vs;

  nexttile; hold on; grid on;
  plot(r1.t, E1_1,'LineWidth',1.2);
  plot(r1.t, E2_1,'LineWidth',1.2);
  plot(r1.t, Es_1,'LineWidth',1.2);
  xlim([0 min(tWindow_s, max(r1.t))]);
  xlabel('t (s)'); ylabel('Energy (J)');
  title([ttl ' | Model 1']);
  legend('E_1 = T_1+V_{g1}','E_2 = T_2+V_{g2}','E_{spring}','Location','best');

  nexttile; hold on; grid on;
  plot(r3.t, E1_3,'LineWidth',1.2);
  plot(r3.t, E2_3,'LineWidth',1.2);
  plot(r3.t, Es_3,'LineWidth',1.2);
  xlim([0 min(tWindow_s, max(r3.t))]);
  xlabel('t (s)'); ylabel('Energy (J)');
  title([ttl ' | Model 3']);
  legend('E_1 = T_1+V_{g1}','E_2 = T_2+V_{g2}','E_{spring}','Location','best');
end

function plotConfigSpaceCompare(r1,r3, ttl)
  tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

  nexttile; hold on; grid on; axis equal;
  plot(rad2deg(r1.Y(:,1)), rad2deg(r1.Y(:,3)),'LineWidth',1.0);
  xlabel('\theta_1 (deg)'); ylabel('\theta_2 (deg)');
  title('Model 1');

  nexttile; hold on; grid on; axis equal;
  plot(rad2deg(r3.Y(:,1)), rad2deg(r3.Y(:,3)),'LineWidth',1.0);
  xlabel('\theta_1 (deg)'); ylabel('\theta_2 (deg)');
  title('Model 3');

  sgtitle(ttl);
end

function plotPhasePortraitCompare(r1,r3, ttl)
  tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

  nexttile; hold on; grid on;
  plot(rad2deg(r1.Y(:,1)), rad2deg(r1.Y(:,2)),'LineWidth',1.0);
  xlabel('\theta_1 (deg)'); ylabel('\omega_1 (deg/s)');
  title('Model 1 (ideal ellipse-ish)');

  nexttile; hold on; grid on;
  plot(rad2deg(r3.Y(:,1)), rad2deg(r3.Y(:,2)),'LineWidth',1.0);
  xlabel('\theta_1 (deg)'); ylabel('\omega_1 (deg/s)');
  title('Model 3 (distorted orbit)');

  sgtitle(ttl);
end

function plotWrappedPhase(r1,r3, ttl)
  tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

  th1_1 = wrap180(r1.Y(:,1)); % split at 180deg instead of 0deg
  th1_3 = wrap180(r3.Y(:,1));

  nexttile; hold on; grid on;
  plotWrapped(rad2deg(th1_1), rad2deg(r1.Y(:,2)));
  xlim([-180 180]);
  xlabel('wrap_{180}(\theta_1) (deg)'); ylabel('\omega_1 (deg/s)');
  title('Model 1 (linear model breaks conceptually here)');

  nexttile; hold on; grid on;
  plotWrapped(rad2deg(th1_3), rad2deg(r3.Y(:,2)));
  xlim([-180 180]);
  xlabel('wrap_{180}(\theta_1) (deg)'); ylabel('\omega_1 (deg/s)');
  title('Model 3 (rotor-like wrapped phase)');

  sgtitle(ttl);
end

function thw = wrap180(th)
  thw = mod(th + pi, 2*pi) - pi;
end

function plotWrapped(xdeg, ydeg)
  x = xdeg(:);
  y = ydeg(:);

  jumps = [false; abs(diff(x)) > 180];
  x(jumps) = NaN;
  y(jumps) = NaN;

  plot(x, y, 'LineWidth', 1.0);
end


