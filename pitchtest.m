function ds=pitchtest(x,fs,WP,f0,f1,WL)
%YIN method

if ((nargin<3)||(isempty(WP)))
    WP=2048;
end
if ((nargin<4)||(isempty(f0)))
    f0=50;
end
if ((nargin<5)||(isempty(f1)))
    f1=1000;
end
if ((nargin<6)||(isempty(WL)))
    WL=round(WP*2);
end
L1=ceil(fs/f0);
L0=ceil(fs/f1);

%N=ceil((length(x)-WL-st)/WP);
L=L1+2;
if (WL<L)
    WL=L;
end
N=ceil((length(x)-WL)/WP);

ds=zeros(L,N);
f=zeros(f1,N);
t=zeros(L,1);
for h=1:N
    y=x((1:WL)+round((h-1)*WP));
    d1=conv(y,rot90(y,2));
    d=d1(WL:WL+L-1);
    
    t(L)=sum(y(L:WL).^2);
    for i=L-1:-1:1
        t(i)=t(i+1)+y(i)^2;
    end
    d=(t+t(1))-2*d;
    d2=d;
    s=0;
    d(1)=2;
    for i=2:L
        s=s+d2(i);
        d(i)=d2(i)*i/s;
    end
    
    if (sum(isnan(d))==0)
        ds(:,h)=d;
    end
end

end