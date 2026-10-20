%CHECKRECEIVER Exact recovery, unknown timing/gain, multipath and failure checks.
cfg=getConfig(); modes={'QPSK','16QAM','64QAM'};
for m=1:3
    [tx,meta]=transmitFrame(17,modes{m},cfg);
    for prefix=[0 8 23]
        x=[zeros(prefix,1);tx*(0.4+0.3i)];
        d=receiveFrame(x,cfg);
        assert(d.headerSuccess && d.crcPass && d.frameId==17);
        assert(strcmp(d.mode,modes{m}) && isequal(d.payloadBits,meta.payloadBits));
    end
    h=zeros(10,1); h([1 3 6 10])=[1;0.2i;-0.1;0.08i];
    d=receiveFrame([zeros(8,1);filter(h,1,tx)],cfg);
    assert(d.crcPass && isequal(d.payloadBits,meta.payloadBits));
    % Regression: delayed paths stronger than the first arrival must not
    % produce an early return with a valid header but empty payload.
    for delay=[2 5]
        delayed=zeros(10,1); delayed(1)=0.1; delayed(delay+1)=1;
        d=receiveFrame([zeros(8,1);filter(delayed,1,tx)],cfg);
        assert(d.headerSuccess && d.crcPass && ...
            isequal(d.payloadBits,meta.payloadBits), ...
            'Dominant delayed path must not truncate payload recovery.');
    end
    stream=RandStream('mt19937ar','Seed',900+m);
    noise=sqrt(mean(abs(tx).^2)*1e-6/2)*(randn(stream,size(tx))+1i*randn(stream,size(tx)));
    d=receiveFrame([zeros(8,1);tx+noise],cfg);
    assert(d.crcPass && isequal(d.payloadBits,meta.payloadBits));
    % Replace one entire payload symbol by zeros, keeping header/training intact.
    damaged=tx; L=cfg.nFFT+cfg.cpLength; damaged(3*L+(1:L))=0;
    d=receiveFrame([zeros(8,1);damaged],cfg);
    assert(d.headerSuccess && ~d.crcPass,'Damaged payload must fail CRC.');
end
d=receiveFrame(zeros(1000,1),cfg); assert(~d.headerSuccess && ~d.crcPass);
d=receiveFrame(tx(1:100),cfg); assert(~d.crcPass);
assert(strcmp(selectTxMode(NaN,cfg),'QPSK'));
disp('Receiver checks passed: clean modes, timing, multipath, AWGN and CRC failure.');
