function crc = txCrc16(bits)
%TXCRC16 CRC-16/CCITT-FALSE, MSB-first, poly 0x1021, init 0xFFFF.
bits = logical(bits(:));
state = uint16(hex2dec('FFFF'));
poly = uint16(hex2dec('1021'));
for k = 1:numel(bits)
    feedback = xor(bitget(state,16) ~= 0, bits(k));
    state = bitshift(state,1);
    if feedback
        state = bitxor(state,poly);
    end
end
crc = logical(bitget(state,16:-1:1).');
crc = crc(:);
end
