function velocity = calculate_velocity_nf_direct(hh)
ds=50; %NUMBER OF SAMPLES TO GET 50ms OF DATA
%in h5 file row 1 is roll, row 2 is pitch (equivalent to forward(y) motion
%in maze), row 3 is yaw (equivalent to right/left (x) motion in the maze)
%the channle identities may vary depending on the rig - 2p+ hh(2,:)=roll,
%hh(3,:) = pitch, hh(4,:)=yaw;
velocity=zeros(length(hh(1,:)),2);
hh(3,:)=hh(3,:)-4600;%4601;
hh(2,:)=hh(2,:)-4488;%4601;

% for i=1:length(hh(1,:))
%     if hh(3,i)>=-12 && hh(3,i)<=12
%         hh(3,i)=0;
%     end
%     if hh(2,i)>=-12 && hh(2,i)<=10
%         hh(2,i)=0;
%     end
% end

%figure(1);
%plot(hh(3,:));
%title('raw x wavesurfer');
%figure(2);
%plot(hh(2,:));
%title('raw y wavesurfer');
C=20.32*pi;
position_est=3*C;
gain=8e-7;%0.41; %this value must be calibrated


for i=1:ds:length(hh(1,:))-ds
    temp_data1=hh(2,i:i+ds);%y
    
    temp_data2=hh(3,i:i+ds);%x
    data1=mean(temp_data1); %y
    data2=mean(temp_data2);%x
%     if data2>-1.8 && data2<1.8
%         data2=0;
%     end
%     if data1>-2 && data1<0.2
%         data1=0;
%     end
    
    
%     data1(isnan(data1))=0;
%     data2(isnan(data2))=0;




    velocity_test2(1)=data2*gain; %x
    
    velocity_test2(2)=data1*gain; %y

    for d=1:2
        velocity(i:i+ds,d)=velocity_test2(d);
    end
end
velocity=velocity';

int = cumtrapz(velocity(2,:));
% figure(50)
% clf
% plot(int)
% distnace = abs(int(9.02e5)-int(6.67e5));

%xvel=velocity(1,:);
%xvel_abs=abs(xvel);
%figure;
%plot(xvel_abs)
%yvel=velocity(2,:);
%yvel_abs=abs(yvel);
%figure;
%plot(yvel_abs)

%to check calibration 
%tot_ms=length(xvel);
% time=linspace(0,tot_ms/1000,tot_ms);
% positionx=cumtrapz(time,xvel_abs);
% positiony=cumtrapz(time,yvel_abs);

% changepts=findchangepts(xvel_abs,'Statistic','mean');


% bs=100;
% xchangepts=[];
% ychangepts=[];
% 
% for i=1:length(xvel_abs)-(2*bs)
%     
%     prevx=xvel_abs(i:i+bs);
%     latex=xvel_abs(i+(bs):i+(2*bs));
%     h=ttest2(prevx,latex);
%     if h==1
%         xchangepts=[xchangepts i+bs];
%     end
%         
%     prevy=yvel_abs(i:i+bs);
%     latey=yvel_abs(i+(bs):i+(2*bs));
%     h=ttest2(prevy,latey);
%      if h==1
%         ychangepts=[ychangepts i+bs];
%      end
% end
% 
%    




%do vector addition of x and y components

