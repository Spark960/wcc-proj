function decoded = txIdealLoopback(txWaveform,cfg,mode,payloadBitCount)
%TXIDEALLOOPBACK Zero-impairment transmitter check, NOT the project receiver.
% Uses known frame boundary and a single pilot-derived gain. Abhinav's real
% receiver must independently synchronize and estimate a multipath channel.
symbolLength=cfg.nFFT+cfg.cpLength;
assert(mod(numel(txWaveform),symbolLength)==0);
blocks=reshape(txWaveform,symbolLength,[]);
spectra=fft(blocks(cfg.cpLength+1:end,:),cfg.nFFT,1)/sqrt(cfg.nFFT);
pilotRows=mod(cfg.pilotBins,cfg.nFFT)+1;
gain=mean(spectra(pilotRows,3)./cfg.pilotValues);
assert(abs(gain)>0);
dataRows=mod(cfg.dataBins,cfg.nFFT)+1;
headerSymbols=spectra(dataRows,3)/gain;
headerBits=hardDemap(headerSymbols,'QPSK');
payloadSymbols=spectra(dataRows,4:end)/gain;
payloadBits=hardDemap(payloadSymbols(:),mode);
payloadBits=payloadBits(1:payloadBitCount);
crcBits=hardDemap(payloadSymbols(:),mode);
crcBits=crcBits(payloadBitCount+(1:16));
decoded.headerBits=headerBits;
decoded.payloadBits=payloadBits;
decoded.crcBits=crcBits;
decoded.crcPass=isequal(txCrc16(payloadBits),crcBits);
end

function bits=hardDemap(symbols,mode)
switch upper(string(mode))
    case "QPSK", k=2;
    case "16QAM", k=4;
    case "64QAM", k=6;
end
labels=false(2^k,k);
for n=0:2^k-1
    labels(n+1,:)=logical(bitget(uint32(n),k:-1:1));
end
constellation=txQamMap(reshape(labels.',[],1),mode);
bits=false(numel(symbols)*k,1);
for n=1:numel(symbols)
    [~,ix]=min(abs(symbols(n)-constellation).^2);
    bits((n-1)*k+(1:k))=labels(ix,:).';
end
end
