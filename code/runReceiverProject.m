%RUNRECEIVERPROJECT Run checks, smoke cases, calibration and final evaluation.
% Run in MATLAB from the project root after addpath(fullfile(pwd,'code')).
% Start a fresh diary so a prior failed attempt is not mixed into this run.
diary off
logFile=fopen('receiver_validation_log.txt','w');
assert(logFile>=0,'Cannot create receiver validation log.');
fclose(logFile);
diary('receiver_validation_log.txt');
try
    checkLokeshTx
    checkChannelIntegration
    checkReceiver
    cfg=getConfig();
    runReceiverValidation(20,cfg,'adaptive','smoke');
    % Independent calibration realization. Thresholds use PRIOR-frame SINR,
    % because channel fading is independently redrawn each frame in this model.
    calibration=cfg; calibration.channelSeed=cfg.channelSeed+2000000;
    modes={'QPSK','16QAM','64QAM'}; trials=cell(1,3);
    for m=1:3
        [~,trials{m}]=runReceiverValidation(100,calibration,modes{m},['calibration_' modes{m}]);
    end
    thresholds=[Inf Inf];
    for m=2:3
        t=trials{m};
        for threshold=0:1:60
            selected=isfinite(t.PreviousSINR_dB) & t.PreviousSINR_dB>=threshold;
            if sum(selected)>=50 && mean(~t.Success(selected))<=cfg.targetPer
                thresholds(m-1)=threshold; break
            end
        end
    end
    % Disable a higher mode when the calibration does not support it.
    thresholds(2)=max(thresholds(2),thresholds(1));
    cfg.modeSinrThresholdDb=thresholds;
    fprintf('Calibrated prior-frame SINR thresholds: %g, %g dB\n',thresholds);
    for m=1:3
        runReceiverValidation(500,cfg,modes{m},['fixed_' modes{m}]);
    end
    runReceiverValidation(500,cfg,'adaptive','final');
    save(fullfile('results','receiver','calibrated_config.mat'),'cfg');
    diary off
    zip('wcc_receiver_results.zip',{'results/receiver','receiver_validation_log.txt'});
catch err
    disp(getReport(err,'extended')); diary off; rethrow(err);
end
