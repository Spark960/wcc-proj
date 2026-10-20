function [rxWaveform, info] = applyChannel(txWaveform, cfg, scenario)
%APPLYCHANNEL Integrated propagation model for Lokesh's power-scaled waveform.
% [rxWaveform,info] = applyChannel(txWaveform,cfg,scenario)
% Input is transmitFrame() output (complex column vector, sqrt(W) scaling).
% Output is an impaired complex column vector for Abhinav's receiver.
% Operational input is separated from diagnostic truth in info.
% Base MATLAB only.

validateattributes(txWaveform, {'numeric'}, {'vector','nonempty'});
required = {'centerFrequencyHz','bandwidthHz','sampleRateHz','txPowerDbm', ...
    'txAntennaGainDbi','feederLossDb','rxAntennaGainDbi','referenceDistanceM', ...
    'pathLossExponent','shadowSigmaDb','noiseFigureDb','channelTapDelaysSamples', ...
    'channelTapPowersDb','channelSeed'};
for k=1:numel(required)
    assert(isfield(cfg,required{k}), 'Missing cfg field: %s', required{k});
end
assert(isfield(scenario,'distanceM') && isfield(scenario,'obstacleLossDb') && ...
    isfield(scenario,'interferencePowerDbm') && isfield(scenario,'seed'), ...
    'Scenario must contain distanceM, obstacleLossDb, interferencePowerDbm and seed.');
assert(cfg.sampleRateHz==cfg.bandwidthHz, 'Baseline expects sample rate = bandwidth.');
assert(max(cfg.channelTapDelaysSamples)<cfg.cpLength, ...
    'Maximum channel delay should be less than the OFDM cyclic prefix.');

x = txWaveform(:);
% Preserve caller RNG state and use scenario-local deterministic randomness.
stream = RandStream('mt19937ar','Seed',double(scenario.seed));
c = 299792458;
d0 = cfg.referenceDistanceM;
fsplDb = 20*log10(4*pi*d0*cfg.centerFrequencyHz/c);
pathLossDb = fsplDb + 10*cfg.pathLossExponent*log10(max(scenario.distanceM,d0)/d0);
shadowDb = cfg.shadowSigmaDb*randn(stream,1,1);
% Received signal power relative to transmit waveform: antenna gains and feeder
% loss are included once in the RF link budget; txWaveform already has Tx power.
largeScaleLossDb = pathLossDb + shadowDb + scenario.obstacleLossDb ...
    + cfg.feederLossDb - cfg.txAntennaGainDbi - cfg.rxAntennaGainDbi;
largeScaleGain = 10^(-largeScaleLossDb/10);
xAfterPathLoss = sqrt(largeScaleGain)*x;

% Independent complex Rayleigh tapped-delay line, normalized to unit mean tap power.
delays = double(cfg.channelTapDelaysSamples(:).');
tapDb = double(cfg.channelTapPowersDb(:).');
assert(numel(delays)==numel(tapDb) && ~isempty(delays));
assert(all(delays>=0 & delays==floor(delays)));
tapPowers = 10.^(tapDb/10); tapPowers = tapPowers/sum(tapPowers);
taps = (randn(stream,1,numel(tapPowers))+1i*randn(stream,1,numel(tapPowers))) ...
    ./sqrt(2).*sqrt(tapPowers);
h = complex(zeros(max(delays)+1,1));
for k=1:numel(delays), h(delays(k)+1)=h(delays(k)+1)+taps(k); end
faded = filter(h,1,xAfterPathLoss);

% Eight-sample prefix gives the receiver a nonzero unknown start to detect.
leadingDelaySamples = 8;
faded = [complex(zeros(leadingDelaySamples,1)); faded];

% Receiver thermal noise: -174 dBm/Hz + 10log10(B) + NF.
kB=1.380649e-23; temperatureK=290;
noisePowerW=kB*temperatureK*cfg.bandwidthHz*10^(cfg.noiseFigureDb/10);
noise=sqrt(noisePowerW/2)*(randn(stream,size(faded))+1i*randn(stream,size(faded)));

% Independent in-band co-channel interference at the specified receiver-input
% power. A complex Gaussian process is used as a tractable wideband interferer
% proxy; this is not a standards-compliant second WLAN transmitter waveform.
interferencePowerW=0;
interference=complex(zeros(size(faded)));
if isfinite(scenario.interferencePowerDbm)
    interferencePowerW=10^((scenario.interferencePowerDbm-30)/10);
    interference=sqrt(interferencePowerW/2)*(randn(stream,size(faded))+1i*randn(stream,size(faded)));
end
rxWaveform=faded+noise+interference;

signalPowerW=mean(abs(faded).^2);
measuredNoiseW=mean(abs(noise).^2);
measuredInterferenceW=mean(abs(interference).^2);
info=struct();
info.scenarioName=scenario.name;
info.distanceM=scenario.distanceM;
info.pathLossDb=pathLossDb;
info.shadowingDb=shadowDb;
info.obstacleLossDb=scenario.obstacleLossDb;
info.largeScaleLossDb=largeScaleLossDb;
info.eirpDbm=cfg.txPowerDbm+cfg.txAntennaGainDbi-cfg.feederLossDb;
info.predictedReceivedPowerDbm=info.eirpDbm+cfg.rxAntennaGainDbi-pathLossDb-shadowDb-scenario.obstacleLossDb;
info.noisePowerDbm=10*log10(noisePowerW/1e-3);
info.interferenceTargetDbm=scenario.interferencePowerDbm;
info.signalPowerW=signalPowerW;
info.measuredSignalPowerDbm=10*log10(max(signalPowerW,realmin)/1e-3);
info.measuredNoisePowerW=measuredNoiseW;
info.measuredInterferencePowerW=measuredInterferenceW;
info.sinrDb=10*log10(max(signalPowerW,realmin)/max(measuredNoiseW+measuredInterferenceW,realmin));
info.multipathTaps=taps;
info.multipathDelaysSamples=delays;
info.leadingDelaySamples=leadingDelaySamples;
info.rxSampleCount=numel(rxWaveform);
info.seed=scenario.seed;
% info is diagnostic truth for evaluation only; do not feed its channel taps
% or power values into the operational receiver.
end
