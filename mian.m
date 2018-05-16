% main

fn='04'; % INPUT YOUR SONG NAME HERE
is_soprano = 0;
hparams;

%% from wavefile to res matrix
% from wavefile to res matrix

if (exist([fn,'.wav'],'file'))
    [x,fs]=audioread([fn,'.wav']);
else
    [x,fs]=audioread([fn,'.mp3']);
end
x=mean(x,2);
x0=x;
fs0=fs;

if (is_soprano)
    fs=fs/2;
end

ds=pitchtest(x,fs,WP,fi0); %YIN
N=size(ds,2);
a=zeros(n1,N);
for i=n0:n1
    fi=220*2^((i-57)/12);%37+12*log2(i/220);
    n=fs/fi+1;
    ni=floor(n);
    p=n-ni;
    a(i,:)=(p*ds(ni+1,:)+(1-p)*ds(ni,:));
end
yin_res=1-a(n0:n1,:);

A=constqm(fs,[],1,n1,-1); %-0.5;
X=cqgram(x,fs,WP,A)/WL;
fft_res=X(n0:n1,:);
fft_res=log(fft_res*1000+1);

allres=[yin_res;fft_res];
save([fn,'.mat'],'allres','is_soprano');

%% from res matrix to pitch probability gram
% from res matrix to pitch probability gram

load([fn,'.mat']);
x=allres;
sx=size(x);
nx=sx(1);
tmax=sx(2)+1;
x=[zeros(nx,1),x];

load('pitch_lstm_444.mat');
sWhy=size(Why);
d=sWhy(2);
ny=sWhy(1);

hparams;

% Test
%initialize input here
% x, yt, tmax
h=randn(d,1);
c=zeros(d,1);

%initialize recorder
A=zeros(d,tmax);
I=zeros(d,tmax);
F=zeros(d,tmax);
O=zeros(d,tmax);
C=zeros(d,tmax);
H=zeros(d,tmax);
H(:,1)=h;
Y=zeros(ny,tmax);

% Forward
for t=2:tmax
    %forward
    a=tanh(Wc*x(:,t)+Uc*h);
    i=sigmf(Wi*x(:,t)+Ui*h,[alp,0]);
    f=sigmf(Wf*x(:,t)+Uf*h,[alp,0]);
    o=sigmf(Wo*x(:,t)+Uo*h,[alp,0]);
    c=i.*a+f.*c;
    h=o.*tanh(c);
    y=Why*h;
    if (issoftmax==1)
        y=y-max(y);
        y=exp(y);
        y=y/sum(y);
    end
    %record
    A(:,t)=a;
    I(:,t)=i;
    F(:,t)=f;
    O(:,t)=o;
    C(:,t)=c;
    H(:,t)=h;
    Y(:,t)=y;
end
yr=Y(:,2:end);    

save([fn,'_lstm_out.mat'],'yr','is_soprano');

%% from prob gram to pitch result
% from prob gram to pitch result

hparams;
x=x0;
fs=fs0;
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
% [~,notes]=max(ys,[],1);
% notes(notes==1)=nan;
% notes=notes+(n0-2);
[~,notes]=max(ys(2:end,:),[],1);
notes=notes+(n0-1);
if (is_soprano)
    notes=notes+12;
end
plot(notes,'o-');
save([fn,'_notes.mat'],'notes','beat');

