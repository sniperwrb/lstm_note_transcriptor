function b=getbias(x,fs,c)
%     [x,fs]=audioread('abjones_1_01.wav');
%     x=mean(x,2);
    if (nargin<3)
        c=4;
    end
    v=novel(x,2048);
    [beat,WP,z]=tempo(v,2048,fs);
    WP=fs*(240/c)/beat;

    A=zeros(ceil(WP),1);
    l=length(x);
    for i=1:floor(l/WP)
        p=floor((i-1)*WP)+1;
        q=floor(i*WP);
        A(1:(q-p+1))=A(1:(q-p+1))+x(p:q).^2;
    end
%    plot(A);
    [~,b]=max(A);
end
% x=x(b:end);
% y=x(round(WP*202.75+b):round(WP*204.75+b)-1);
% sound(y,fs);