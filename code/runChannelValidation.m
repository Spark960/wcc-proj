function results = runChannelValidation(nFrames)
%RUNCHANNELVALIDATION Run Lokesh's transmitter through Prisha's channel model.
% results=runChannelValidation() runs cfg.smokeFramesPerScenario frames/case.
% results=runChannelValidation(500) selects the final run count.
% Receiver not required yet: this validates transmitter-to-channel integration.
if nargin<1 || isempty(nFrames), cfg=getConfig(); nFrames=cfg.smokeFramesPerScenario; else, cfg=getConfig(); end
assert(isscalar(nFrames) && nFrames>=1 && nFrames==floor(nFrames));
outDir=fullfile(fileparts(mfilename('fullpath')),'..','results');
if ~isfolder(outDir), mkdir(outDir); end
scenarios=channelScenarios(cfg);
rows=struct('Scenario',{},'Frames',{},'Distance_m',{},'ObstacleLoss_dB',{}, ...
    'InterferenceTarget_dBm',{},'MeanPathLoss_dB',{},'MeanShadowing_dB',{}, ...
    'MeanPredictedRxPower_dBm',{},'MeanMeasuredRxPower_dBm',{},'Noise_dBm',{},'MeanSINR_dB',{},'RxSamplesPerFrame',{});
exampleTx=[]; exampleRx=[]; exampleInfo=[];
for s=1:numel(scenarios)
    infos=repmat(struct(),nFrames,1); rxPower=zeros(nFrames,1); sinr=zeros(nFrames,1); pathloss=zeros(nFrames,1); shadow=zeros(nFrames,1); predicted=zeros(nFrames,1); measured=zeros(nFrames,1); sampleCount=zeros(nFrames,1);
    for f=1:nFrames
        frameId=(s-1)*nFrames+f;
        % First frame in each case QPSK; keep transmitter's shared API.
        [txWaveform,txMeta]=transmitFrame(frameId,'QPSK',cfg); %#ok<NASGU>
        trial=scenarios(s); trial.seed=scenarios(s).seed+f-1;
        [rxWaveform,info]=applyChannel(txWaveform,cfg,trial);
        rxPower(f)=info.signalPowerW; sinr(f)=info.sinrDb; pathloss(f)=info.pathLossDb; shadow(f)=info.shadowingDb; predicted(f)=info.predictedReceivedPowerDbm; measured(f)=info.measuredSignalPowerDbm; sampleCount(f)=info.rxSampleCount;
        if f==1 && s==1, exampleTx=txWaveform; exampleRx=rxWaveform; exampleInfo=info; end
    end
    rows(s).Scenario=scenarios(s).name; rows(s).Frames=nFrames; rows(s).Distance_m=scenarios(s).distanceM; rows(s).ObstacleLoss_dB=scenarios(s).obstacleLossDb; rows(s).InterferenceTarget_dBm=scenarios(s).interferencePowerDbm; rows(s).MeanPathLoss_dB=mean(pathloss); rows(s).MeanShadowing_dB=mean(shadow); rows(s).MeanPredictedRxPower_dBm=mean(predicted); rows(s).MeanMeasuredRxPower_dBm=10*log10(mean(rxPower)/1e-3); rows(s).Noise_dBm=info.noisePowerDbm; rows(s).MeanSINR_dB=mean(sinr); rows(s).RxSamplesPerFrame=sampleCount(1);
end
results=struct2table(rows); disp(results);
writetable(results,fullfile(outDir,'channel_validation_results.csv'));
f=figure('Visible','off','Color','w');
subplot(2,1,1); plot(real(exampleTx(1:min(300,end)))); grid on; title('Transmitter output (real part)'); xlabel('Sample'); ylabel('sqrt(W)');
subplot(2,1,2); plot(real(exampleRx(1:min(308,end)))); grid on; title(sprintf('Received waveform: %s (8-sample leading delay)',exampleInfo.scenarioName)); xlabel('Sample'); ylabel('sqrt(W)');
printable(f);
exportgraphics(f,fullfile(outDir,'tx_channel_waveform.png'),'Resolution',180); close(f);
f=figure('Visible','off','Color','w');
bar(categorical(results.Scenario),[results.MeanPredictedRxPower_dBm results.MeanMeasuredRxPower_dBm]); grid on; ylabel('Received signal power (dBm)'); legend('Link-budget prediction','Simulated faded waveform','Location','best'); title('Channel integration: received power'); set(gca,'Color','w','XColor','k','YColor','k');
printable(f);
exportgraphics(f,fullfile(outDir,'received_power_comparison.png'),'Resolution',180); close(f);
f=figure('Visible','off','Color','w'); bar(categorical(results.Scenario),results.MeanSINR_dB); grid on; ylabel('Diagnostic SINR (dB)'); title('Channel integration: estimated truth SINR'); set(gca,'Color','w','XColor','k','YColor','k');
printable(f);
exportgraphics(f,fullfile(outDir,'sinr_by_scenario.png'),'Resolution',180); close(f);
fprintf('Saved integrated channel results and plots under %s\n',outDir);
fprintf('These are channel-model diagnostics, not receiver BER/PER results.\n');
end

function printable(f)
% Make exports legible regardless of the local MATLAB theme.
set(findall(f,'Type','axes'),'Color','w','XColor','k','YColor','k');
set(findall(f,'Type','text'),'Color','k');
set(findall(f,'Type','legend'),'Color','w','TextColor','k');
end
