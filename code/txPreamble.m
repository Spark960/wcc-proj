function [samples, freq] = txPreamble(cfg)
%TXPREAMBLE Two identical known OFDM training symbols for timing/estimation.
% Deterministic BPSK on all 52 occupied carriers; DC/guard bins remain zero.
occupied = sort([cfg.dataBins(:);cfg.pilotBins(:)]);
state = rng;
rng(cfg.preambleSeed,'twister');
signs = 2*randi([0 1],numel(occupied),1)-1;
rng(state);
freq = zeros(cfg.nFFT,1);
freq(mod(occupied,cfg.nFFT)+1) = signs;
x = ifft(freq,cfg.nFFT)*sqrt(cfg.nFFT);
one = [x(end-cfg.cpLength+1:end);x];
samples = [one;one];
end
