function res = simulateCoupledPendulums(p, modelLevel, tspan, Y0, solverFcn, odeOpts)
% one run (plus energies)

  if nargin < 5 || isempty(solverFcn), solverFcn = @ode45; end
  if nargin < 6, odeOpts = odeset(); end

  f = @(t,Y) coupledPendulumsODE(t, Y, p, modelLevel);
  [t, Y] = solverFcn(f, tspan, Y0, odeOpts);

  E = coupledPendulumsEnergy(Y, p, modelLevel);

  res = struct();
  res.modelLevel = modelLevel;
  res.p = p;
  res.t = t;
  res.Y = Y;
  res.E = E;
end


