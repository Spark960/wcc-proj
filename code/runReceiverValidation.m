function [summary,frames] = runReceiverValidation(nFrames,cfg,policy,tag)
%RUNRECEIVERVALIDATION Truth stays here, outside receiveFrame.
if nargin<2 || isempty(cfg), cfg=getConfig(); end
if nargin<1 || isempty(nFrames), nFrames=cfg.smokeFramesPerScenario; end
if nargin<3, policy='adaptive'; end
if nargin<4, tag=policy; end
validateattributes(nFrames,{'numeric'},{'scalar','integer','positive','<=',10000});
out=fullfile(fileparts(mfilename('fullpath')),'..','results','receiver',tag);
if ~isfolder(out), mkdir(out); end
scenarios=channelScenarios(cfg); rows=struct([]); summaries=struct([]); example=[];
for s=1:numel(scenarios)
    previous=NaN;
    for f=1:nFrames
        if strcmp(policy,'adaptive'), mode=selectTxMode(previous,cfg); else, mode=policy; end
        % Same payload and random channel for matched scenarios/configurations.
        [tx,meta]=transmitFrame(f,mode,cfg);
        trial=scenarios(s); trial.seed=trial.seed+f-1;
        [rx,truth]=applyChannel(tx,cfg,trial);
        d=receiveFrame(rx,cfg);
        aligned=d.headerSuccess && d.frameId==meta.frameId && ...
            numel(d.payloadBits)==numel(meta.payloadBits);
        errors=0; compared=0;
        if aligned
            compared=numel(meta.payloadBits); errors=sum(d.payloadBits~=meta.payloadBits);
        end
        success=aligned && d.crcPass;
        r=struct('Scenario',scenarios(s).name,'Frame',f,'Mode',mode, ...
            'PreviousSINR_dB',previous,'TimingOK',d.timingSuccess, ...
            'HeaderOK',d.headerSuccess,'CRCOK',d.crcPass,'Success',success, ...
            'UndetectedPayloadError',success && errors>0, ...
            'BitErrors',errors,'ComparedBits',compared,'ExcludedBER',~aligned, ...
            'DeliveredBits',double(success)*meta.payloadBitCount, ...
            'Airtime_s',meta.frameDurationS,'RxPower_dBm',d.receivedPowerDbm, ...
            'EstimatedSINR_dB',d.sinrDb,'TruthSINR_dB',truth.sinrDb, ...
            'Shadowing_dB',truth.shadowingDb,'FrameStart',d.frameStart);
        % Establish the field schema before indexed struct assignment.
        if isempty(rows)
            rows=r;
        else
            rows(end+1)=r; %#ok<AGROW>
        end
        % No report => QPSK fallback on the next frame. Never use truth here.
        previous=d.sinrDb;
        if isempty(example) && success
            example=d;
        end
    end
    t=struct2table(rows(end-nFrames+1:end));
    bad=sum(~t.Success); per=bad/nFrames; bits=sum(t.ComparedBits);
    ber=NaN; if bits>0, ber=sum(t.BitErrors)/bits; end
    airtime=sum(t.Airtime_s); goodput=sum(t.DeliveredBits)/airtime;
    latency=Inf; if per<1, latency=mean(t.Airtime_s)/(1-per); end
    % Wilson 95% binomial interval (descriptive Monte Carlo uncertainty).
    z=1.95996398454005; denom=1+z*z/nFrames;
    center=(per+z*z/(2*nFrames))/denom;
    half=z*sqrt(per*(1-per)/nFrames+z*z/(4*nFrames*nFrames))/denom;
    q=struct('Scenario',scenarios(s).name,'Frames',nFrames,'BadPackets',bad, ...
        'SyncFailures',sum(~t.TimingOK),'HeaderFailures',sum(t.TimingOK & ~t.HeaderOK), ...
        'BERExcludedFrames',sum(t.ExcludedBER),'BitErrors',sum(t.BitErrors), ...
        'ComparedBits',bits,'BER',ber,'PER',per,'PER95Low',max(0,center-half), ...
        'PER95High',min(1,center+half),'DeliveredBits',sum(t.DeliveredBits), ...
        'Airtime_s',airtime,'Goodput_Mbps',goodput/1e6,'LatencyProxy_us',latency*1e6, ...
        'MeanRxPower_dBm',10*log10(mean(10.^(t.RxPower_dBm/10))), ...
        'MeanEstimatedSINR_dB',mean(t.EstimatedSINR_dB,'omitnan'), ...
        'SINREstimateCount',sum(isfinite(t.EstimatedSINR_dB)), ...
        'MeanTruthSINR_dB',mean(t.TruthSINR_dB), ...
        'QPSKFrames',sum(strcmp(t.Mode,'QPSK')), ...
        'QAM16Frames',sum(strcmp(t.Mode,'16QAM')),'QAM64Frames',sum(strcmp(t.Mode,'64QAM')), ...
        'Shadowing_dB',scenarios(s).shadowingDb, ...
        'MeetsTargets',per<=cfg.targetPer && goodput>=cfg.targetGoodputBps);
    if isempty(summaries)
        summaries=q;
    else
        summaries(end+1)=q; %#ok<AGROW>
    end
    fprintf('%s: PER %.3f (%d/%d), goodput %.2f Mbps\n',q.Scenario,per,bad,nFrames,q.Goodput_Mbps);
end
summary=struct2table(summaries); frames=struct2table(rows);
writetable(summary,fullfile(out,'receiver_summary.csv'));
writetable(frames,fullfile(out,'receiver_frames.csv'));
save(fullfile(out,'receiver_run.mat'),'cfg','policy','nFrames','summary','frames','example');
f=figure('Visible','off','Color','w','Position',[100 100 1200 900]);
tiledlayout(2,2,'TileSpacing','compact');
values={summary.BER,summary.PER,summary.Goodput_Mbps,summary.LatencyProxy_us};
labels={'Payload BER (aligned frames)','Packet error rate','Goodput (Mbps)','Latency proxy (microseconds)'};
for p=1:4
    nexttile; bar(values{p}); xticks(1:height(summary));
    xticklabels(strrep(summary.Scenario,'_',' ')); xtickangle(25);
    ylabel(labels{p}); grid on;
end
exportgraphics(f,fullfile(out,'receiver_performance.png'),'Resolution',180); close(f);
if ~isempty(example)
    f=figure('Visible','off','Color','w','Position',[100 100 1100 750]);
    tiledlayout(2,2,'TileSpacing','compact');
    nexttile; plot(example.correlation); xline(example.frameStart,'r--');
    xlabel('Candidate start (sample)'); ylabel('Normalized correlation'); grid on;
    nexttile; plot(abs(example.channelEstimate)); xlabel('FFT bin'); ylabel('Estimated channel magnitude'); grid on;
    nexttile; plot(real(example.rawSymbols),imag(example.rawSymbols),'.');
    title('Before equalization'); xlabel('I'); ylabel('Q'); axis equal; grid on;
    nexttile; plot(real(example.equalizedSymbols),imag(example.equalizedSymbols),'.');
    title(['After equalization: ' example.mode]); xlabel('I'); ylabel('Q'); axis equal; grid on;
    exportgraphics(f,fullfile(out,'receiver_example.png'),'Resolution',180); close(f);
end
f=figure('Visible','off','Color','w');
plot(frames.TruthSINR_dB,frames.EstimatedSINR_dB,'.'); hold on;
limits=[min(frames.TruthSINR_dB) max(frames.TruthSINR_dB)]; plot(limits,limits,'k--');
xlabel('Offline diagnostic SINR (dB)'); ylabel('Training-based effective SINR (dB)'); grid on;
exportgraphics(f,fullfile(out,'receiver_sinr_validation.png'),'Resolution',180); close(f);
disp(summary);
end
