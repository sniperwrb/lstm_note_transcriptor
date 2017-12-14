function [y,WP]=novel(x,WP,WL,c)

s=size(x);
if (s(1)==2)
    x=sum(x,1);
end
if (s(2)==2)
    x=sum(x,2);
end

if ((nargin<2)||(isempty(WP)))
    WP=2048;
end
if ((nargin<3)||(isempty(WL)))
    WL=WP*2;
end
if ((nargin<4)||(isempty(c)))
    c=1000;
end

N=ceil((length(x)-WL)/WP);
x=x(1:(WL+(N-1)*WP));

y=zeros(N-1,1);
for i=1:N
    x1=x((1:WL)+(i-1)*WP);
    X1=abs(fft(x1));
    if (i>1)
        v=(log(1+c*X1)-log(1+c*X0));
        y(i-1)=sum(v(v>0));
    end
    X0=X1;
end

end