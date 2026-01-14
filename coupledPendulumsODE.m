function dY = coupledPendulumsODE(~, Y, p, modelLevel)
% state: [theta1; omega1; theta2; omega2]

  th1 = Y(1); w1 = Y(2);
  th2 = Y(3); w2 = Y(4);

  g = p.g; l = p.l; k = p.k;
  m1 = p.m1; m2 = p.m2;

  switch modelLevel
    case 1
      th1dd = -(g/l)*th1 + (k/m1)*(th2 - th1);
      th2dd = -(g/l)*th2 - (k/m2)*(th2 - th1);

    case 2
      th1dd = -(g/l)*sin(th1) + (k/m1)*(sin(th2) - sin(th1))*cos(th1);
      th2dd = -(g/l)*sin(th2) - (k/m2)*(sin(th2) - sin(th1))*cos(th2);

    case 3

      a  = p.a;
      L0 = p.L0;

      x1 = l*sin(th1); y1 = -l*cos(th1);
      x2 = a + l*sin(th2); y2 = -l*cos(th2);

      rx = x2 - x1;
      ry = y2 - y1;
      d  = hypot(rx, ry);


      if d < 1e-12
        Fx = 0; Fy = 0;
      else
        Fmag = k*(d - L0);
        Fx = Fmag * (rx/d);
        Fy = Fmag * (ry/d);
      end

      r1x = x1;        r1y = y1;
      r2x = x2 - a;    r2y = y2;   % relative to pivot2

      tau1 = r1x*Fy - r1y*Fx;
      tau2 = r2x*(-Fy) - r2y*(-Fx); % using F2 = -F1

      th1dd = ( -m1*g*l*sin(th1) + tau1 ) / (m1*l*l);
      th2dd = ( -m2*g*l*sin(th2) + tau2 ) / (m2*l*l);

    otherwise
      error('Unknown modelLevel=%d. Use 1,2,3.', modelLevel);
  end

  dY = [w1; th1dd; w2; th2dd];
end


