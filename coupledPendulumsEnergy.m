function E = coupledPendulumsEnergy(Y, p, modelLevel)
% energies (mostly for sanity checking)

  th1 = Y(:,1); w1 = Y(:,2);
  th2 = Y(:,3); w2 = Y(:,4);

  g = p.g; l = p.l; k = p.k;
  m1 = p.m1; m2 = p.m2;

  T1 = 0.5*m1*(l*l).*w1.^2;
  T2 = 0.5*m2*(l*l).*w2.^2;
  T  = T1 + T2;

  switch modelLevel
    case 1
      Vg1 = 0.5*m1*g*l.*th1.^2;
      Vg2 = 0.5*m2*g*l.*th2.^2;
      Vg  = Vg1 + Vg2;
      dx = l*(th2 - th1);
      Vs = 0.5*k.*dx.^2;

    case 2
      Vg1 = m1*g*l.*(1 - cos(th1));
      Vg2 = m2*g*l.*(1 - cos(th2));
      Vg  = Vg1 + Vg2;
      dx = l*(sin(th2) - sin(th1));
      Vs = 0.5*k.*dx.^2;

    case 3
      Vg1 = m1*g*l.*(1 - cos(th1));
      Vg2 = m2*g*l.*(1 - cos(th2));
      Vg  = Vg1 + Vg2;
      a  = p.a;
      L0 = p.L0;
      x1 = l*sin(th1);      y1 = -l*cos(th1);
      x2 = a + l*sin(th2);  y2 = -l*cos(th2);
      d  = hypot(x2 - x1, y2 - y1);
      Vs = 0.5*k.*(d - L0).^2;

    otherwise
      error('Unknown modelLevel=%d. Use 1,2,3.', modelLevel);
  end

  E = struct();
  E.T = T;
  E.T1 = T1;
  E.T2 = T2;
  E.Vg = Vg;
  E.Vg1 = Vg1;
  E.Vg2 = Vg2;
  E.Vs = Vs;
  E.Etot = T + Vg + Vs;
end


