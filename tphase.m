function [ph,a]=tphase(v,WP,beat,fs,c,bins)
%tempo estimator

if ((nargin<6)||(isempty(bins)))
    bins=360;
end
if ((nargin<5)||(isempty(c)))
    c=8; % 8-th note 
end

L=fs*(480/c)/beat/WP; % how many frames in a period
l=length(v); % how many frames in total

a=zeros(bins,1);
for i=1:l
    p=ceil(2*pi*(i-1)*bins/L);
    q=floor(2*pi*(i+1)*bins/L);
    for j=p:q
        a(mod(j,bins)+1)=a(mod(j,bins)+1)+v(i)*abs(j*L/(2*pi*bins)-i);
    end
end

[~,ph]=max(a);
ph=(ph-1)*2*pi/bins;

end