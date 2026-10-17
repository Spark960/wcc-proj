function mode = selectTxMode(previousSinrDb,cfg)
%SELECTTXMODE Causal adaptive mode for the NEXT frame.
% Pass NaN when no prior receiver report exists. Thresholds in getConfig
% are provisional and must be tuned using measured PER versus SINR.
if nargin<2 || isempty(cfg), cfg=getConfig(); end
if isnan(previousSinrDb)
    mode=cfg.firstFrameMode;
elseif previousSinrDb<cfg.modeSinrThresholdDb(1)
    mode='QPSK';
elseif previousSinrDb<cfg.modeSinrThresholdDb(2)
    mode='16QAM';
else
    mode='64QAM';
end
end
