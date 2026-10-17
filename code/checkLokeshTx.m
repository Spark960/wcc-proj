%CHECKLOKESHTX Functional checks of the transmitter, no receiver dependency.
cfg=getConfig();
ascii=uint8('123456789');
knownBits=false(8*numel(ascii),1);
for n=1:numel(ascii)
    knownBits((n-1)*8+(1:8))=logical(bitget(ascii(n),8:-1:1).');
end
expectedCrc=logical(bitget(uint16(hex2dec('29B1')),16:-1:1).');
assert(isequal(txCrc16(knownBits),expectedCrc),'CRC-16 known vector failed');
assert(numel(txHeader(1,'QPSK',768,cfg))==96);
assert(numel(intersect(cfg.dataBins,cfg.pilotBins))==0);
assert(strcmp(selectTxMode(NaN,cfg),'QPSK'));
assert(strcmp(selectTxMode(15,cfg),'16QAM'));
assert(strcmp(selectTxMode(25,cfg),'64QAM'));
rates=txLinkRates(cfg);
assert(isequal(rates.rawBitRateBps,[24;48;72]*1e6));
assert(isequal(rates.framePayloadRateBps,[16;24;32]*1e6));
for mode={'QPSK','16QAM','64QAM'}
    [a,ma]=transmitFrame(7,mode{1},cfg);
    [b,mb]=transmitFrame(7,mode{1},cfg);
    assert(isequal(a,b) && isequal(ma.payloadBits,mb.payloadBits));
    assert(abs(mean(abs(a).^2)-ma.txPowerW)<1e-12);
    assert(mod(numel(a),cfg.nFFT+cfg.cpLength)==0);
    decoded=txIdealLoopback(a,cfg,mode{1},ma.payloadBitCount);
    assert(isequal(decoded.headerBits,ma.headerBits));
    assert(isequal(decoded.payloadBits,ma.payloadBits));
    assert(decoded.crcPass);
    fprintf('%s: %d samples, %.3f us, deterministic, power %.6g W\n', ...
        mode{1},numel(a),1e6*ma.frameDurationS,mean(abs(a).^2));
end
disp('Transmitter checks passed.');
