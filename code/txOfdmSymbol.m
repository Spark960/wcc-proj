function samples = txOfdmSymbol(dataSymbols,cfg)
%TXOFDMSYMBOL One 64-bin OFDM symbol, with four known pilots and 16 CP.
assert(numel(dataSymbols)==numel(cfg.dataBins));
X = zeros(cfg.nFFT,1);
X(mod(cfg.dataBins,cfg.nFFT)+1) = dataSymbols(:);
X(mod(cfg.pilotBins,cfg.nFFT)+1) = cfg.pilotValues(:);
x = ifft(X,cfg.nFFT)*sqrt(cfg.nFFT);
samples = [x(end-cfg.cpLength+1:end); x];
end
