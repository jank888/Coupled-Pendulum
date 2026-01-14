function animateCoupledPendulums(res, opts)
% animate one result struct (optionally save mp4)

  if nargin < 2, opts = struct(); end

  if ~isfield(opts,'fps'),         opts.fps = 30; end
  if ~isfield(opts,'speed'),       opts.speed = 1.0; end
  if ~isfield(opts,'saveVideo'),   opts.saveVideo = false; end
  if ~isfield(opts,'filename'),    opts.filename = 'coupled_pendulums.mp4'; end
  if ~isfield(opts,'trail'),       opts.trail = true; end
  if ~isfield(opts,'trailLength'), opts.trailLength = 300; end
  if ~isfield(opts,'visible'),     opts.visible = true; end
  if ~isfield(opts,'resolution'),  opts.resolution = 140; end
  if ~isfield(opts,'verbose'),     opts.verbose = opts.saveVideo; end

  p = res.p;
  t = res.t(:);
  Y = res.Y;

  th1 = Y(:,1);
  th2 = Y(:,3);

  l = p.l;
  a = p.a;

  x1 = l*sin(th1);      y1 = -l*cos(th1);
  x2 = a + l*sin(th2);  y2 = -l*cos(th2);

  showWindows = true;
  try
    showWindows = feature('ShowFigureWindows');
  catch
  end

  figVisible = 'on';
  if ~opts.visible || (opts.saveVideo && ~showWindows)
    figVisible = 'off';
  end

  fig = figure('Name',sprintf('Animation | Model %d',res.modelLevel), ...
    'Color','w','Visible',figVisible);
  ax = axes(fig); %#ok<LAXES>
  hold(ax,'on'); grid(ax,'on');
  axis(ax,'equal');
  xlabel(ax,'x (m)'); ylabel(ax,'y (m)');

  pad = 0.2*l;
  xmin = min([0, a, x1(:).', x2(:).']) - pad;
  xmax = max([0, a, x1(:).', x2(:).']) + pad;
  ymin = min([0, y1(:).', y2(:).']) - pad;
  ymax = max([0, y1(:).', y2(:).']) + pad;
  xlim(ax,[xmin xmax]); ylim(ax,[ymin ymax]);

  plot(ax, 0, 0, 'k^', 'MarkerFaceColor','k', 'MarkerSize',8);
  plot(ax, a, 0, 'k^', 'MarkerFaceColor','k', 'MarkerSize',8);

  rod1   = plot(ax, [0 x1(1)], [0 y1(1)], 'k-', 'LineWidth',2);
  rod2   = plot(ax, [a x2(1)], [0 y2(1)], 'k-', 'LineWidth',2);
  bob1   = plot(ax, x1(1), y1(1), 'o', 'MarkerSize',10, ...
    'MarkerFaceColor',[0.2 0.4 0.9], 'MarkerEdgeColor','k');
  bob2   = plot(ax, x2(1), y2(1), 'o', 'MarkerSize',10, ...
    'MarkerFaceColor',[0.9 0.3 0.2], 'MarkerEdgeColor','k');
  spring = plot(ax, [x1(1) x2(1)], [y1(1) y2(1)], '-', ...
    'Color',[0.1 0.7 0.2], 'LineWidth',1.5);
  txt    = text(ax, xmin + 0.02*(xmax-xmin), ymax - 0.06*(ymax-ymin), '', ...
    'FontName','Consolas');

  if opts.trail
    tr1 = plot(ax, x1(1), y1(1), '-', 'Color',[0.2 0.4 0.9 0.35], 'LineWidth',1.0);
    tr2 = plot(ax, x2(1), y2(1), '-', 'Color',[0.9 0.3 0.2 0.35], 'LineWidth',1.0);
  end

  vw = [];
  if opts.saveVideo
    outFile = opts.filename;
    outDir = fileparts(outFile);
    if ~isempty(outDir) && ~exist(outDir,'dir'), mkdir(outDir); end

    if exist(outFile,'file') == 2
      try
        delete(outFile);
      catch
        [pp, nn, ee] = fileparts(outFile);
        k = 1;
        cand = fullfile(pp, sprintf('%s_%d%s', nn, k, ee));
        while exist(cand,'file') == 2
          k = k + 1;
          cand = fullfile(pp, sprintf('%s_%d%s', nn, k, ee));
        end
        outFile = cand;
      end
    end

    vw = VideoWriter(outFile, 'MPEG-4');
    vw.FrameRate = opts.fps;
    open(vw);
  end

  dtTarget = (1/opts.fps) * max(opts.speed, 1e-9);
  nextT = t(1);
  frameIdx = zeros(0,1);
  for i = 1:numel(t)
    if t(i) + 1e-12 >= nextT
      frameIdx(end+1,1) = i; %#ok<AGROW>
      nextT = nextT + dtTarget;
    end
  end

  usePrintRgb = ~opts.visible;
  if ~isempty(vw) && ~usePrintRgb
    try
      getframe(fig);
    catch
      usePrintRgb = true;
    end
  end

  if opts.verbose && ~isempty(vw)
    fprintf('Animating %d frames -> %s\n', numel(frameIdx), vw.Filename);
  end

  for fi = 1:numel(frameIdx)
    i = frameIdx(fi);

    set(rod1, 'XData',[0 x1(i)], 'YData',[0 y1(i)]);
    set(rod2, 'XData',[a x2(i)], 'YData',[0 y2(i)]);
    set(bob1, 'XData',x1(i), 'YData',y1(i));
    set(bob2, 'XData',x2(i), 'YData',y2(i));
    set(spring,'XData',[x1(i) x2(i)], 'YData',[y1(i) y2(i)]);

    if opts.trail
      i0 = max(1, i-opts.trailLength);
      set(tr1, 'XData', x1(i0:i), 'YData', y1(i0:i));
      set(tr2, 'XData', x2(i0:i), 'YData', y2(i0:i));
    end

    set(txt,'String',sprintf('t = %.2f s | Model %d', t(i), res.modelLevel));
    if opts.visible
      drawnow limitrate;
    end

    if ~isempty(vw)
      try
        if usePrintRgb
          img = print(fig, '-RGBImage', sprintf('-r%d', opts.resolution));
          writeVideo(vw, im2frame(img));
        else
          writeVideo(vw, getframe(fig));
        end
      catch
      end
    end

    if opts.verbose && mod(fi, 250) == 0
      fprintf('  frame %d / %d\n', fi, numel(frameIdx));
    end
  end

  if ~isempty(vw)
    close(vw);
    if opts.verbose
      fprintf('Saved video: %s\n', vw.Filename);
    end
  end
end


