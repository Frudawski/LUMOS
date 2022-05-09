function plot_mesh_2D(dt)
% plot 2D coordinates

dt.Points = dt.mesh.points;
dt.ConnectivityList = dt.mesh.list;

clf
hold on
datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
dataz = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];

for i = 1:size(datax,1)
    fill(datax(i,:),dataz(i,:),[0.75 0.75 0.75],'Facecolor',[0.5 0.5 0.5],'FaceAlpha',0.5);
    %plot(datax(i,:),dataz(i,:),'-k')
end
axis off

% window
for win = 1:size(dt.windows,2)
     %triplot(windows{win},'Color','b')
     
     %dt = [];
     dt.Points = dt.windows{win}.mesh.points;
     dt.ConnectivityList = dt.windows{win}.mesh.list;
     
     datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
     dataz = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
     %dataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];
     for i = 1:size(datax,1)
         fill(datax(i,:),dataz(i,:),[0 0.5 0.75],'Facecolor',[0 0.5267 0.6461],'Facealpha',0.5)
     end
end
axis equal

% end of plot 2D
end
