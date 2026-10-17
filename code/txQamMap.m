function symbols = txQamMap(bits, mode)
%TXQAMMAP Gray-coded, unit-mean-power square QAM (QPSK/16/64).
bits = logical(bits(:));
switch upper(string(mode))
    case "QPSK", k = 2;
    case "16QAM", k = 4;
    case "64QAM", k = 6;
    otherwise, error('Unsupported modulation: %s',mode);
end
assert(mod(numel(bits),k)==0,'Bit count must divide by modulation order');
nAxis = k/2;
nLevels = 2^nAxis;
b = reshape(bits,k,[]).';
iGray = zeros(size(b,1),1);
qGray = zeros(size(b,1),1);
for j = 1:nAxis
    iGray = 2*iGray + double(b(:,j));
    qGray = 2*qGray + double(b(:,nAxis+j));
end
iBinary = iGray;
qBinary = qGray;
for shift = 1:nAxis-1
    iBinary = bitxor(uint32(iBinary),bitshift(uint32(iBinary),-shift));
    qBinary = bitxor(uint32(qBinary),bitshift(uint32(qBinary),-shift));
end
levelsI = 2*double(iBinary)-nLevels+1;
levelsQ = 2*double(qBinary)-nLevels+1;
symbols = (levelsI + 1i*levelsQ) / sqrt(2*(nLevels^2-1)/3);
symbols = symbols(:);
end
