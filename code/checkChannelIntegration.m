%CHECKCHANNELINTEGRATION Basic transmitter-to-channel interface checks.
cfg=getConfig();
scenarios=channelScenarios(cfg);
assert(numel(scenarios)==6,'Expected six channel scenarios.');
[tx,meta]=transmitFrame(1,'QPSK',cfg);
assert(iscolumn(tx) && ~isempty(tx));
assert(abs(mean(abs(tx).^2)-meta.txPowerW)<1e-12,'Tx waveform power mismatch.');
[rx1,info1]=applyChannel(tx,cfg,scenarios(1));
[rx2,info2]=applyChannel(tx,cfg,scenarios(1));
assert(isequal(rx1,rx2),'Same seed should reproduce the channel waveform.');
assert(numel(rx1)==numel(tx)+info1.leadingDelaySamples,'Unexpected received length.');
assert(isfinite(info1.sinrDb) && isfinite(info2.sinrDb));
assert(info1.leadingDelaySamples==8);
disp('Transmitter-to-channel integration checks passed.');
