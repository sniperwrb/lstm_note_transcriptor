[x,fs]=audioread('btg.mp3');
x=mean(x,2);
v=novel(x,2048);
[beat,WP,z]=tempo(v,2048,fs);
% WP=fs*15/beat;
WP=fs*60/beat;

A=zeros(ceil(WP),1);
l=length(x);
for i=1:floor(l/WP)
    p=floor((i-1)*WP)+1;
    q=floor(i*WP);
    A(1:(q-p+1))=A(1:(q-p+1))+x(p:q).^2;
end
plot(A);
[~,b]=max(A);
y=x(1:round(WP*37.75+b)-1);
%sound(y,fs);
audiowrite('btg2.wav',y,fs);
