function cfg = getConfig()
%GETCONFIG Shared ICT3128 Q20 baseline. Change values here, not in modules.
cfg.nFFT = 64;
cfg.cpLength = 16;
cfg.bandwidthHz = 20e6;
cfg.sampleRateHz = cfg.bandwidthHz; % complex-baseband sample rate follows channel bandwidth
cfg.dataBins = setdiff([-26:-1 1:26], [-21 -7 7 21]);
cfg.pilotBins = [-21 -7 7 21];
cfg.pilotValues = [1 1 1 -1].';
cfg.payloadBytes = 96;
cfg.seed = 3128;
cfg.txPowerDbm = 15;
cfg.txAntennaGainDbi = 2;
cfg.feederLossDb = 0;
cfg.rxAntennaGainDbi = 0;
% Frozen baseline channel/scenario assumptions. Replace only with documented
% field-supported values; keep all group modules on the same configuration.
cfg.centerFrequencyHz = 2.437e9; % 2.4 GHz channel-6 baseline; record actual AP channel
cfg.referenceDistanceM = 1;
cfg.pathLossExponent = 3.2;
cfg.shadowSigmaDb = 4;
cfg.locationNames = {'near','middle','edge'};
cfg.distanceM = [2 8 20];
cfg.wallLossDb = [0 6 15];
cfg.channelTapDelaysSamples = [0 2 5 9];
cfg.channelTapPowersDb = [0 -3 -6 -9];
cfg.noiseFigureDb = 6;
cfg.interferenceNames = {'low','high'};
cfg.interferencePowerDbm = [-110 -80];
cfg.channelSeed = 6202;
cfg.smokeFramesPerScenario = 20;
cfg.finalFramesPerScenario = 500;
cfg.fieldSamplesPerLocation = 10;
cfg.targetPer = 0.05;
cfg.targetGoodputBps = 5e6;
cfg.candidateTxPowerDbm = [10 15 20];
cfg.firstFrameMode = 'QPSK';
cfg.modeSinrThresholdDb = [12 23]; % provisional; calibrate from receiver PER curves
cfg.crcPolynomialHex = '1021';
cfg.crcInitialHex = 'FFFF';
cfg.preambleSeed = 2026;
cfg.headerMarker = uint8(hex2dec('A7'));
assert(numel(cfg.dataBins)==48 && numel(cfg.pilotBins)==4);
assert(isempty(intersect(cfg.dataBins,cfg.pilotBins)));
assert(cfg.sampleRateHz==cfg.bandwidthHz);
assert(max(cfg.channelTapDelaysSamples)<cfg.cpLength);
end
