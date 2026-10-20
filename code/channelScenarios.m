function scenarios = channelScenarios(cfg)
%CHANNELSCENARIOS Six cases from the shared project configuration.
if nargin<1 || isempty(cfg), cfg=getConfig(); end
scenarios=struct('name',{},'distanceM',{},'obstacleLossDb',{},'interferencePowerDbm',{},'seed',{});
k=0;
for i=1:numel(cfg.distanceM)
    for j=1:numel(cfg.interferencePowerDbm)
        k=k+1;
        scenarios(k).name=sprintf('%s_%sInterference',cfg.locationNames{i},cfg.interferenceNames{j});
        scenarios(k).distanceM=cfg.distanceM(i);
        scenarios(k).obstacleLossDb=cfg.wallLossDb(i);
        scenarios(k).interferencePowerDbm=cfg.interferencePowerDbm(j);
        scenarios(k).seed=cfg.channelSeed+k;
    end
end
end
