function d = receiveFrame(rxWaveform,cfg)
%RECEIVEFRAME Training-based receiver; no transmitted bits or channel truth.
x=rxWaveform(:); N=cfg.nFFT; C=cfg.cpLength; L=N+C;
d=struct('timingSuccess',false,'headerSuccess',false,'frameStart',NaN, ...
    'frameId',NaN,'mode','','payloadBitCount',0,'payloadBits',false(0,1), ...
    'crcPass',false,'receivedPowerDbm',NaN,'sinrDb',NaN, ...
    'rawSymbols',[],'equalizedSymbols',[],'correlation',[],'channelEstimate',[]);
if isempty(x) || any(~isfinite(x)), return; end
% Total receiver input power includes interference and noise, over the buffer.
d.receivedPowerDbm=10*log10(max(mean(abs(x).^2),realmin)/1e-3);
if numel(x)<3*L, return; end
[preamble,known]=txPreamble(cfg);
corr=abs(conv(x,flipud(conj(preamble)),'valid')).^2;
energy=conv(abs(x).^2,ones(numel(preamble),1),'valid');
score=corr./max(energy*sum(abs(preamble).^2),realmin);
d.correlation=score;
[peak,idx]=max(score);
if peak<0.08, return; end % documented normalized-correlation detection gate
% Search nearby timing hypotheses in correlation order, using header CRC only.
% Multipath can make a delayed tap stronger than the earliest arrival.
candidates=max(1,idx-C):min(numel(x)-3*L+1,idx+C);
[~,order]=sort(score(candidates),'descend');
active=mod(sort([cfg.dataBins cfg.pilotBins]),N)+1;
data=mod(cfg.dataBins,N)+1; pilots=mod(cfg.pilotBins,N)+1;
for start=candidates(order)
    blocks=reshape(x(start:start+3*L-1),L,3);
    Y=fft(blocks(C+1:end,:),N,1)/sqrt(N);
    H=zeros(N,1); H(active)=mean(Y(active,1:2),2)./known(active);
    disturbance=mean(abs(Y(active,1)-Y(active,2)).^2)/2;
    signal=max(mean(abs(mean(Y(active,1:2),2)).^2)-disturbance/2,realmin);
    quality=10*log10(signal/max(disturbance,realmin));
    z=equalize(Y(:,3),H,pilots,cfg.pilotValues,data);
    b=rxDemap(z,'QPSK');
    id=number(b(9:24)); modeId=number(b(25:26)); count=number(b(27:42));
    if number(b(1:8))~=double(cfg.headerMarker) || modeId>2 || count==0, continue; end
    modes={'QPSK','16QAM','64QAM'}; mode=modes{modeId+1};
    expected=txHeader(id,mode,count,cfg);
    if ~isequal(b(43:50),expected(43:50)), continue; end
    d.timingSuccess=true; d.headerSuccess=true; d.frameStart=start;
    d.frameId=id; d.mode=mode; d.payloadBitCount=count;
    d.sinrDb=quality; d.channelEstimate=H;
    k=2*(modeId+1); nSymbols=ceil((count+16)/(numel(data)*k));
    % A strong delayed tap can yield a valid header but a window extending
    % beyond the supplied frame. Try another timing hypothesis instead of
    % immediately discarding an otherwise recoverable packet. Do not pad it
    % with invented samples or use payload CRC to select the timing.
    if start+(3+nSymbols)*L-1>numel(x), continue; end
    payload=reshape(x(start+3*L:start+(3+nSymbols)*L-1),L,nSymbols);
    Yp=fft(payload(C+1:end,:),N,1)/sqrt(N);
    equalized=zeros(numel(data),nSymbols);
    for s=1:nSymbols
        equalized(:,s)=equalize(Yp(:,s),H,pilots,cfg.pilotValues,data);
    end
    d.rawSymbols=reshape(Yp(data,:),[],1);
    d.equalizedSymbols=equalized(:);
    bits=rxDemap(equalized(:),mode);
    d.payloadBits=bits(1:count);
    d.crcPass=isequal(txCrc16(d.payloadBits),bits(count+(1:16)));
    return
end
% A detected training peak with no valid header is still a packet failure.
d.timingSuccess=true;
end

function z=equalize(Y,H,pilots,pilotValues,data)
% Least-squares common complex gain tracks pilot amplitude/phase per symbol.
reference=H(pilots).*pilotValues;
gain=(reference'*Y(pilots))/max(sum(abs(reference).^2),realmin);
response=H(data)*gain;
floorPower=max(max(abs(response).^2)*1e-12,realmin);
z=Y(data).*conj(response)./max(abs(response).^2,floorPower);
end

function v=number(bits)
v=sum(double(bits(:)).*2.^((numel(bits)-1:-1:0).'));
end
