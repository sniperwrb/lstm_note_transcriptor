fn='btg2';
[x,fs]=audioread([fn,'.wav']);
x=mean(x,2);

is_soprano = 1;
if (is_soprano)
    fs=fs/2;
end

hparams;

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