function bits = txBits(value, width)
%TXBITS Unsigned integer to MSB-first logical column, no toolbox required.
assert(value>=0 && value < 2^width && value==floor(value));
bits = logical(bitget(uint32(value),width:-1:1).');
bits = bits(:);
end
