function [beat,WP1,Z]=tempo(v,WP,fs,st,et,c)
%tempo estimator

if ((nargin<4)||(isempty(st)))
    st=60;
end
if ((nargin<6)||(isempty(c)))
    c=16; % WP output = (2c)-th note
end
if ((nargin<5)||(isempty(et)))
    et=240;
end

L=30*fs/WP;
while (L<512)
    L=L*2;
end
L=round(L);

z=zeros(L,1);
N=length(v);
zs=0;
cs=0;
for i=1:min(L,N-1)
    z(i)=sum(v(1:(N-i)).*v((i+1):N));
    zs=zs+z(i);
    cs=cs+1-i/N;
end
for i=1:min(L,N-1)
    z(i)=z(i)-(zs/cs)*(1-i/N);
end
Z=abs(fft(z));
Z=Z(2:floor(L/2+1));
% figure;
% plot(Z);
Z(1:(st-1))=0;
Z((et+1):end)=0;
Z(85:170)=Z(85:170)*1.2;%
[~,beat]=max(Z);

WP1=fs*120/c/beat;

end