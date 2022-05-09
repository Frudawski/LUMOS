function plot_mesh_3D(wall)
% 3D coordinates 

dt.Points = wall.mesh.points;
dt.ConnectivityList = wall.mesh.list;

%cla
hold on
grid on
axis equal
%axis off

datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
datay = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
dataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];

for i = 1:size(datax,1)
    fill3(datax(i,:),datay(i,:),dataz(i,:),[0.75 0.75 0.75],'Facecolor',[0.5 0.5 0.5]);
end

% window(s)

try
    for win = 1:size(wall.windows,2)
        
        dt.Points = wall.windows{win}.mesh.points;
        dt.ConnectivityList = wall.windows{win}.mesh.list;
        
        wdatax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
        wdatay = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
        wdataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];
        
        for i = 1:size(wdatax,1)
            fill3(wdatax(i,:),wdatay(i,:),wdataz(i,:),[0 0.5 0.75],'Facecolor',[0 0.5267 0.6461])
        end
    end
catch
end

% end of plot3d
end

