function scenarios = channelScenarios(cfg)
%CHANNELSCENARIOS Six cases from the shared project configuration.
if nargin<1 || isempty(cfg), cfg=getConfig(); end
scenarios=struct('name',{},'distanceM',{},'obstacleLossDb',{},'interferencePowerDbm',{},'seed',{},'shadowingDb',{});
k=0;
for i=1:numel(cfg.distanceM)
    % One reproducible shadow draw per location, shared across loads/frames.
    shadowStream=RandStream('mt19937ar','Seed',double(cfg.channelSeed+10000+i));
    shadowDb=cfg.shadowSigmaDb*randn(shadowStream,1,1);
    for j=1:numel(cfg.interferencePowerDbm)
        k=k+1;
        scenarios(k).name=sprintf('%s_%sInterference',cfg.locationNames{i},cfg.interferenceNames{j});
        scenarios(k).distanceM=cfg.distanceM(i);
        scenarios(k).obstacleLossDb=cfg.wallLossDb(i);
        scenarios(k).interferencePowerDbm=cfg.interferencePowerDbm(j);
        % Match fading/noise across loads; reserve distinct location ranges.
        scenarios(k).seed=cfg.channelSeed+100000*i;
        scenarios(k).shadowingDb=shadowDb;
    end
end
end
