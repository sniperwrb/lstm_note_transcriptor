%lstm test
%initialize input

fn='btg2';
load([fn,'.mat']);
x=allres;
sx=size(x);
nx=sx(1);
tmax=sx(2)+1;
x=[zeros(nx,1),x];

load('pitch_lstm.mat');
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
yr=yr(2:ny,:);
draw3d(1:tmax-1,n0:n1,yr,[0,1]);
xlabel('frame');ylabel('midi number');title('result');