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
% Shadowing stays fixed across frames and loads; fading varies by frame.
assert(isequal(scenarios,channelScenarios(cfg)));
for s=1:2:numel(scenarios)
    assert(scenarios(s).shadowingDb==scenarios(s+1).shadowingDb);
    [~,low]=applyChannel(tx,cfg,scenarios(s));
    [~,high]=applyChannel(tx,cfg,scenarios(s+1));
    assert(isequal(low.multipathTaps,high.multipathTaps));
    for f=1:3
        trial=scenarios(s); trial.seed=trial.seed+f;
        [~,next]=applyChannel(tx,cfg,trial);
        assert(next.shadowingDb==low.shadowingDb);
        assert(~isequal(next.multipathTaps,low.multipathTaps));
    end
end
% Verify OFDM structure (CP and null FFT bins), not just random power.
state=rng;
[interferer,details]=channelOfdmInterference(1000,cfg,-80,12345);
assert(isequal(state,rng),'Interferer must preserve caller RNG.');
[again,~]=channelOfdmInterference(1000,cfg,-80,12345);
assert(isequal(interferer,again));
assert(abs(mean(abs(interferer).^2)/1e-11-1)<1e-12);
L=cfg.nFFT+cfg.cpLength;
assert(details.offsetSamples>0 && details.offsetSamples<L);
firstFull=L-details.offsetSamples+1;
block=interferer(firstFull:firstFull+L-1);
assert(norm(block(1:cfg.cpLength)-block(end-cfg.cpLength+1:end))<1e-15);
bins=fft(block(cfg.cpLength+1:end));
active=mod([cfg.dataBins cfg.pilotBins],cfg.nFFT)+1;
nulls=setdiff(1:cfg.nFFT,active);
assert(norm(bins(nulls))<1e-12*norm(bins(active)));
[strong,~]=channelOfdmInterference(1000,cfg,-50,12345);
assert(norm(strong-sqrt(1000)*interferer)<1e-12*norm(strong));
[off,~]=channelOfdmInterference(1000,cfg,-Inf,12345);
assert(all(off==0));
assert(abs(info1.measuredInterferencePowerW/ ...
    10^((scenarios(1).interferencePowerDbm-30)/10)-1)<1e-12);
disp('Transmitter-to-channel integration checks passed.');
