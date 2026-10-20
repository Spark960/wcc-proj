function bits = rxDemap(symbols,mode)
%RXDEMAP Nearest-point decisions using the transmitter's exact label mapping.
switch upper(char(mode))
    case 'QPSK', k=2;
    case '16QAM', k=4;
    case '64QAM', k=6;
    otherwise, error('Unsupported modulation');
end
labels=false(2^k,k);
for n=0:2^k-1, labels(n+1,:)=logical(bitget(uint32(n),k:-1:1)); end
points=txQamMap(reshape(labels.',[],1),mode);
[~,index]=min(abs(symbols(:)-points.').^2,[],2);
bits=reshape(labels(index,:).',[],1);
end
