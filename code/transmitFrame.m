function [txWaveform,meta] = transmitFrame(frameId,mode,cfg,payloadBits)
%TRANSMITFRAME Framed adaptive OFDM transmitter for ICT3128 Question 20A.
% [txWaveform,meta] = transmitFrame(frameId,mode,cfg[,payloadBits])
% txWaveform is in sqrt(watts) for a nominal 1-ohm complex-baseband model.
% Antenna gain/feeder loss are LINK-BUDGET parameters, not waveform scaling.
if nargin<3 || isempty(cfg), cfg=getConfig(); end
if nargin<2 || isempty(mode), mode=cfg.firstFrameMode; end
assert(cfg.sampleRateHz==cfg.bandwidthHz, ...
    'Set sampleRateHz equal to bandwidthHz for this baseline model');
assert(frameId>=0 && frameId<65536 && frameId==floor(frameId));
if nargin<4 || isempty(payloadBits)
    state=rng;
    rng(cfg.seed+double(frameId),'twister');
    payloadBits=logical(randi([0 1],cfg.payloadBytes*8,1));
    rng(state);
else
    payloadBits=logical(payloadBits(:));
end
assert(numel(payloadBits)>0 && numel(payloadBits)<65536);
switch upper(string(mode))
    case "QPSK", bitsPerCarrier=2;
    case "16QAM", bitsPerCarrier=4;
    case "64QAM", bitsPerCarrier=6;
    otherwise, error('Mode must be QPSK, 16QAM, or 64QAM');
end
crc=txCrc16(payloadBits);
payloadWithCrc=[payloadBits;crc];
bitsPerOfdm=numel(cfg.dataBins)*bitsPerCarrier;
padCount=mod(-numel(payloadWithCrc),bitsPerOfdm);
mapped=txQamMap([payloadWithCrc;false(padCount,1)],mode);
nPayloadSymbols=numel(mapped)/numel(cfg.dataBins);
payloadWaveform=zeros(nPayloadSymbols*(cfg.nFFT+cfg.cpLength),1);
for k=1:nPayloadSymbols
    ix=(k-1)*numel(cfg.dataBins)+(1:numel(cfg.dataBins));
    samples=txOfdmSymbol(mapped(ix),cfg);
    jx=(k-1)*numel(samples)+(1:numel(samples));
    payloadWaveform(jx)=samples;
end
[preamble,preambleFreq]=txPreamble(cfg);
headerBits=txHeader(frameId,mode,numel(payloadBits),cfg);
header=txOfdmSymbol(txQamMap(headerBits,'QPSK'),cfg);
baseband=[preamble;header;payloadWaveform];
% Equalize complete-frame sample-average power so Tx power is unambiguous.
baseband=baseband/sqrt(mean(abs(baseband).^2));
txPowerW=10^((cfg.txPowerDbm-30)/10);
txWaveform=baseband*sqrt(txPowerW);
meta.frameId=frameId;
meta.mode=char(upper(string(mode)));
meta.payloadBits=payloadBits;
meta.payloadBitCount=numel(payloadBits);
meta.crcBits=crc;
meta.crcScheme='CRC-16/CCITT-FALSE, MSB-first, poly 0x1021, init 0xFFFF';
meta.headerBits=headerBits;
meta.headerScheme='marker8 + frameId16 + mode2 + payloadLength16 + CRC8/ATM + zero padding';
meta.padCount=padCount;
meta.nPayloadSymbols=nPayloadSymbols;
meta.nPreambleSymbols=2;
meta.nHeaderSymbols=1;
meta.dataBins=cfg.dataBins;
meta.pilotBins=cfg.pilotBins;
meta.pilotValues=cfg.pilotValues;
meta.preambleFreq=preambleFreq;
meta.sampleRateHz=cfg.sampleRateHz;
meta.frameDurationS=numel(txWaveform)/cfg.sampleRateHz;
meta.txPowerW=txPowerW;
meta.eirpDbm=cfg.txPowerDbm+cfg.txAntennaGainDbi-cfg.feederLossDb;
end
