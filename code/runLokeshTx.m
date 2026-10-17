%RUNLOKESHTX Reproducible transmitter figures and numerical summary.
cfg=getConfig();
outDir=fullfile(fileparts(mfilename('fullpath')),'..','figures');
if ~isfolder(outDir), mkdir(outDir); end
rates=txLinkRates(cfg);
disp(rates);
fprintf('EIRP: %.2f dBm (Tx %.2f dBm + gain %.2f dBi - loss %.2f dB)\n', ...
    cfg.txPowerDbm+cfg.txAntennaGainDbi-cfg.feederLossDb, ...
    cfg.txPowerDbm,cfg.txAntennaGainDbi,cfg.feederLossDb);
f1=figure('Visible','off','Color','w');
stem(cfg.dataBins,ones(size(cfg.dataBins)),'filled','DisplayName','Data');hold on;
stem(cfg.pilotBins,1.3*ones(size(cfg.pilotBins)),'filled','DisplayName','Pilots');
xlabel('Subcarrier index relative to DC');ylabel('Allocation');
title('64-point OFDM resource mapping');ylim([0 1.6]);grid on;legend('Location','best');
set(gca,'Color','w','XColor','k','YColor','k');
exportgraphics(f1,fullfile(outDir,'tx_resource_mapping.png'),'Resolution',180);close(f1);
[txWaveform,meta]=transmitFrame(1,'QPSK',cfg);
N=8192;
P=abs(fftshift(fft(txWaveform,N))).^2;
Pdb=10*log10(P/max(P)+eps);
freqMHz=(-N/2:N/2-1)*(cfg.sampleRateHz/N)/1e6;
f2=figure('Visible','off','Color','w');
plot(freqMHz,Pdb);grid on;xlabel('Frequency offset (MHz)');ylabel('Relative power (dB)');
title('Transmitted framed OFDM spectrum');ylim([-100 5]);
set(gca,'Color','w','XColor','k','YColor','k');
exportgraphics(f2,fullfile(outDir,'tx_spectrum.png'),'Resolution',180);close(f2);
fprintf('Frame 1: %d payload bits, %d payload symbols, %d samples, %.3f us, mean power %.6g W\n', ...
    meta.payloadBitCount,meta.nPayloadSymbols,numel(txWaveform),1e6*meta.frameDurationS,mean(abs(txWaveform).^2));
