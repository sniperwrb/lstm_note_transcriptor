% voicedness and pitch contour to note

hparams;
fn='btg2';
[x,fs]=audioread([fn,'.wav']);
x=mean(x,2);
load([fn,'_lstm_out_uv.mat']); % yr
uv=yr;
load([fn,'_lstm_out_1.mat']); % yr
load([fn,'.mat']); % allres
xr=allres;

ny=size(yr,1);
nx=size(xr,1);
l=min([size(uv,2),size(xr,2),size(yr,2)]);
if (size(xr,2)>l)
    xr=xr(:,1:l);
end
if (size(yr,2)>l)
    yr=yr(:,1:l);
end
if (size(uv,2)>l)
    uv=uv(:,1:l);
end
uv=uv(2,:)-uv(1,:);
% xr_diff=xr(:,2:l)-xr(:,1:l-1);

v=novel(x,WP);
[beat,~,z]=tempo(v,WP,fs);

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
uvs=zeros(1,N);
for i=1:N
    p=ceil(bias+L*(i-1));
    q=floor(bias+L*i);
    ys(:,i)=mean(yr(:,p:q),2);
    uvs(i)=mean(uv(p:q));
end
[~,notes]=max(ys,[],1);
notes=notes+(n0-1);
if (is_soprano)
    notes=notes+12;
end

for i=1:N
    if (uvs(i)<0)
        notes(i)=nan;
    end
end
plot(notes,'o-');
hold on
plot(notes1,'r+-');
xlabel('note');ylabel('midi number');
legend('result','ground truth','Location','NorthWest');
title('decide voicedness first');