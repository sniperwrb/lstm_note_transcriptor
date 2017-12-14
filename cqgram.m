function X=cqgram(x,NFFT,WP,A,N,st,WL)

s=size(x);
if (s(1)==2)
    x=sum(x,1);
end
if (s(2)==2)
    x=sum(x,2);
end

if ((nargin<7)||(isempty(WL)))
    WL=round(WP*2);
end
if ((nargin<6)||(isempty(st)))
    st=0;
end
if ((nargin<5)||(isempty(N)))
    N=ceil((length(x)-WL-st)/WP);
end

s=size(A);
x=x(st+(1:(WL+round((N-1)*WP))))';

X=zeros(N,s(2));
for i=1:N
    x1=x((1:WL)+round((i-1)*WP));
    X1=abs(fft(x1,NFFT));
    X(i,:)=X1(1:s(1))*A;
end

X=X';
end