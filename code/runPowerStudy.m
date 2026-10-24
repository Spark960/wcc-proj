function study = runPowerStudy(nFrames)
%RUNPOWERSTUDY Matched-seed 10/15/20 dBm receiver evaluation.
% Run from the repository root after addpath(fullfile(pwd,'code')).
% Field RSSI is not input to this simulation; it remains separate evidence.
if nargin<1 || isempty(nFrames), nFrames=500; end
validateattributes(nFrames,{'numeric'},{'scalar','integer','positive','<=',10000});
checkLokeshTx;
checkChannelIntegration;
checkReceiver;
base=getConfig();
% Thresholds were calibrated by runReceiverProject at the 15 dBm baseline.
base.modeSinrThresholdDb=[40 44];
powers=base.candidateTxPowerDbm;
policies={'QPSK','16QAM','64QAM','adaptive'};
study=table();
for p=1:numel(powers)
    cfg=base; cfg.txPowerDbm=powers(p);
    for m=1:numel(policies)
        policy=policies{m};
        tag=sprintf('power_%02ddBm_%s_%d',powers(p),policy,nFrames);
        [summary,~]=runReceiverValidation(nFrames,cfg,policy,tag);
        summary.TxPower_dBm=repmat(powers(p),height(summary),1);
        summary.Policy=repmat({policy},height(summary),1);
        study=[study; summary]; %#ok<AGROW>
    end
end
out=fullfile('results','receiver','power_study');
if ~isfolder(out), mkdir(out); end
writetable(study,fullfile(out,sprintf('power_study_%d.csv',nFrames)));
save(fullfile(out,sprintf('power_study_%d.mat',nFrames)),'study','powers','policies','base','nFrames');
fprintf('Power study complete: %d configurations, %d scenario rows.\n',numel(powers)*numel(policies),height(study));
end
