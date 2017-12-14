% pitch contour to note

hparams;
fn='btg2';
[x,fs]=audioread([fn,'.wav']);
x=mean(x,2);
load([fn,'_lstm_out.mat']); % yr
load([fn,'.mat']); % allres
xr=allres;

ny=size(yr,1);
nx=size(xr,1);
l=min(size(xr,2),size(yr,2));
if (size(xr,2)>l)
    xr=xr(:,1:l);
end
if (size(yr,2)>l)
    yr=yr(:,1:l);
end
% xr_diff=xr(:,2:l)-xr(:,1:l-1);

% v=novel(x,WP1);
% [beat,~,z]=tempo(v,WP1,fs);

z1=zeros(300,1);
for i=1:10
    WP1=round(512*(rand+1));
    v=novel(x,WP1);
    [~,~,z]=tempo(v,WP1,fs);
    z=z(1:240);
    z1(1:240)=z1(1:240)+z;
end
[~,beat]=max(z1);
v=novel(x,WP);

c=16;
[ph,ph_list]=tphase(v,WP,beat,fs,c);
PH=abs(fft(ph_list));
while (PH(2)>PH(3))
    c=c/2;
    [ph,ph_list]=tphase(v,WP,beat,fs,c);
    PH=abs(fft(ph_list));
end
c=c*2;
[ph,ph_list]=tphase(v,WP,beat,fs,c);
L=fs*(480/c)/beat/WP;
bias=(ph/2/pi)*L;

c=16;
L=fs*(480/c)/beat/WP;
bias=mod(bias,L);

N=floor((l-bias)/L); %notes
ys=zeros(ny,N);
for i=1:N
    p=ceil(bias+L*(i-1));
    q=floor(bias+L*i);
    ys(:,i)=mean(yr(:,p:q),2);
end
[~,notes]=max(ys,[],1);
notes(notes==1)=nan;
notes=notes+(n0-2);
if (is_soprano)
    notes=notes+12;
end
plot(notes,'o-');
% hold on
% plot(notes1,'r+-');
% xlabel('note');ylabel('midi number');
% legend('result','ground truth','Location','NorthWest');
% title('1k epochs');
save([fn,'_notes.mat'],'notes','beat');
