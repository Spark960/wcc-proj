function [waveform,info] = channelOfdmInterference(sampleCount,cfg,powerDbm,seed)
%CHANNELOFDMINTERFERENCE Independent QPSK OFDM traffic at receiver-input power.
% Own random stream; 48 data carriers, configured pilots/nulls and CP.
% Crop at a nonzero sample offset to avoid symbol alignment with desired Tx.
% Scale the retained observation to the requested average power in watts.
validateattributes(sampleCount,{'numeric'},{'scalar','integer','positive'});
validateattributes(powerDbm,{'numeric'},{'scalar','real'});
assert(isfinite(powerDbm) || powerDbm==-Inf,'Power must be finite or -Inf (disabled).');
info=struct('seed',seed,'offsetSamples',0,'mode','QPSK');
waveform=complex(zeros(sampleCount,1));
if powerDbm==-Inf, return; end
stream=RandStream('mt19937ar','Seed',double(seed));
symbolLength=cfg.nFFT+cfg.cpLength;
offset=randi(stream,symbolLength-1);
nSymbols=ceil((sampleCount+offset)/symbolLength);
traffic=complex(zeros(nSymbols*symbolLength,1));
for k=1:nSymbols
    bits=logical(randi(stream,[0 1],2*numel(cfg.dataBins),1));
    symbols=txQamMap(bits,'QPSK');
    traffic((k-1)*symbolLength+(1:symbolLength))=txOfdmSymbol(symbols,cfg);
end
waveform=traffic(offset+(1:sampleCount));
powerW=10^((powerDbm-30)/10);
waveform=waveform*sqrt(powerW/mean(abs(waveform).^2));
info.offsetSamples=offset;
end
