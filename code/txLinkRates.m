function rates=txLinkRates(cfg)
%TXLINKRATES Uncoded continuous OFDM rates; frame overhead is separate.
if nargin<1, cfg=getConfig(); end
mode={'QPSK';'16QAM';'64QAM'};
bitsPerCarrier=[2;4;6];
symbolDurationS=(cfg.nFFT+cfg.cpLength)/cfg.sampleRateHz;
rawBitRateBps=numel(cfg.dataBins)*bitsPerCarrier/symbolDurationS;
payloadBits=8*cfg.payloadBytes;
payloadSymbols=ceil((payloadBits+16)./(numel(cfg.dataBins)*bitsPerCarrier));
frameDurationS=(3+payloadSymbols)*symbolDurationS; % 2 preamble + 1 header
framePayloadRateBps=payloadBits./frameDurationS; % ideal frame rate, zero errors
eirpDbm=repmat(cfg.txPowerDbm+cfg.txAntennaGainDbi-cfg.feederLossDb,3,1);
rates=table(mode,bitsPerCarrier,rawBitRateBps,framePayloadRateBps,eirpDbm);
end
