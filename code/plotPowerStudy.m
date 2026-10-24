function plotPowerStudy()
%PLOTPOWERSTUDY Export combined MATLAB and preliminary field figures.
root=fullfile('results','receiver','power_study');
t=readtable(fullfile(root,'power_study_500.csv'));
policies={'QPSK','16QAM','64QAM','adaptive'};
powers=[10 15 20];
locations={'near','middle','edge'};
colors=lines(numel(policies));
f=figure('Visible','off','Color','w','Position',[100 100 1100 650]);
hold on;
for p=1:numel(powers)
    for m=1:numel(policies)
        per=zeros(1,3);
        for k=1:3
            key=[locations{k} '_lowInterference'];
            row=t.TxPower_dBm==powers(p) & strcmp(t.Policy,policies{m}) & strcmp(t.Scenario,key);
            assert(sum(row)==1);
            per(k)=100*t.PER(row);
        end
        plot(1:3,per,'-o','Color',colors(m,:),'LineWidth',1+p/2, ...
            'MarkerSize',4+p,'DisplayName',sprintf('%d dBm %s',powers(p),policies{m}));
    end
end
yline(5,'k--','5% target','HandleVisibility','off');
xticks(1:3); xticklabels(locations); xlim([0.8 3.2]); ylim([0 105]);
xlabel('Simulated location'); ylabel('Packet error rate (%)');
title('Matched-seed MATLAB power study: low load'); grid on;
leg=legend('Location','southoutside','NumColumns',3,'FontSize',8);
leg.Color='w'; leg.TextColor='k';
set(findall(f,'Type','axes'),'Color','w','XColor','k','YColor','k');
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(root,'power_study_low_load_per.png'),'Resolution',180); close(f);

field=readtable(fullfile('data','field_rssi.csv'),'Delimiter',',','ReadVariableNames',true);
channel=readtable(fullfile('results','channel_validation_results.csv'));
observed=zeros(1,3); simulated=zeros(1,3);
count=zeros(1,3); distinctValues=zeros(1,3);
minimum=zeros(1,3); maximum=zeros(1,3);
for k=1:3
    frow=strcmp(field.location,locations{k});
    crow=strcmp(channel.Scenario,[locations{k} '_lowInterference']);
    assert(sum(frow)>=1 && sum(crow)==1,'Expected field rows and one channel row per location.');
    v=field.rssi_dBm(frow);
    observed(k)=mean(v);
    count(k)=numel(v); distinctValues(k)=numel(unique(v));
    minimum(k)=min(v); maximum(k)=max(v);
    simulated(k)=channel.MeanMeasuredRxPower_dBm(crow);
end
observedChange=observed-observed(1);
simulatedChange=simulated-simulated(1);
comparison=table(locations(:),count(:),distinctValues(:),minimum(:),maximum(:),observed(:),simulated(:),observedChange(:),simulatedChange(:), ...
    (observedChange(:)-simulatedChange(:)), ...
    'VariableNames',{'Location','ExportRows','DistinctRSSIValues','MinRSSI_dBm','MaxRSSI_dBm','MeanExportedRSSI_dBm','SimulatedPower_dBm', ...
    'ObservedChangeFromNear_dB','SimulatedChangeFromNear_dB','ChangeDifference_dB'});
writetable(comparison,fullfile(root,'field_trend_comparison.csv'));
aligned=observed(1)+simulated-simulated(1);
f=figure('Visible','off','Color','w','Position',[100 100 900 550]);
plot(1:3,observed,'o-','LineWidth',2,'DisplayName','Mean exported Wi-Fi RSSI (may include cached values)'); hold on;
plot(1:3,aligned,'s--','LineWidth',2,'DisplayName','Simulated trend, aligned at near');
xticks(1:3); xticklabels(locations); xlim([0.8 3.2]);
xlabel('Location'); ylabel('RSSI / near-aligned simulated power (dBm)');
title('Field trend from one BSSID across three locations'); grid on;
leg=legend('Location','southwest'); leg.Color='w'; leg.TextColor='k';
set(findall(f,'Type','axes'),'Color','w','XColor','k','YColor','k');
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(root,'field_trend_preliminary.png'),'Resolution',180); close(f);
end
