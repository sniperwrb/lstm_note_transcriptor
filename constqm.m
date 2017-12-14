function [A,NFFT]=constqm(fs,NFFT,n1,n2,r)

if ((nargin<2)||(isempty(NFFT)))
    NFFT=fs;
end
if ((nargin<3)||(isempty(n1)))
    n1=35;
end
if ((nargin<4)||(isempty(n2)))
    n2=77;
end
if ((nargin<5)||(isempty(r)))
    r=-0.5;
end

n=n2-n1+1;
f1=ceil(220*2^((n1-58)/12)*(NFFT/fs));
f2=floor(220*2^((n2-56)/12)*(NFFT/fs));
A=zeros(f2,n);
for i=f1:f2
    k=(57-n1+1)+12*log2(i*(fs/NFFT)/220);
    fk=floor(k);
    if ((fk>0)&&(fk<=n))
        A(i,fk)=fk+1-k;
    end
    if ((fk>=0)&&(fk<n))
        A(i,fk+1)=k-fk;
    end
end
for i=1:n
    A(:,i)=A(:,i)*(sum(A(:,i))^r);
end

end