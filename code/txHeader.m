function bits = txHeader(frameId,mode,payloadBitCount,cfg)
%TXHEADER 8-bit marker, 16-bit ID, 2-bit mode, 16-bit length, 8-bit CRC.
switch upper(string(mode))
    case "QPSK", modeId = 0;
    case "16QAM", modeId = 1;
    case "64QAM", modeId = 2;
    otherwise, error('Unsupported mode');
end
fields = [txBits(double(cfg.headerMarker),8);txBits(frameId,16); ...
    txBits(modeId,2);txBits(payloadBitCount,16)];
% CRC-8/ATM: poly 0x07, init 0x00, MSB-first.
state = uint8(0);
for k=1:numel(fields)
    feedback = xor(bitget(state,8)~=0,fields(k));
    state = bitshift(state,1);
    if feedback, state=bitxor(state,uint8(7)); end
end
check = logical(bitget(state,8:-1:1).');
bits = [fields;check(:);false(96-numel(fields)-8,1)];
end
