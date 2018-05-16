load names
load names1
n0=38;% 35=62Hz,  36=65Hz limit
n1_YIN=84;% 77=698Hz, 84=1040Hz limit
n1_FFT=96;
fi0=220*2^((n0-57)/12)-0.01;

for h=1033:-1:1
    if (h<=1000)
        [x,fs]=audioread(['D:\MIR-1K\Wavfile\',names{h},'.wav']);
    else
        [x,fs]=audioread(['D:\mirexdata\',names1{h-1000},'.wav']);
    end
    if (h==1000)
        WP=320;
        WL=WP*2;
    end
    if (h==1020)
        WP=256;
        WL=WP*2;
    end
    if (h==1033)
        WP=441;
        WL=WP*2;
    end
    x=mean(x,2);

    ds=pitchtest(x,fs,WP,fi0); %YIN
    N=size(ds,2);
    a=zeros(n1_YIN,N);
    for i=n0:n1_YIN
        fi=220*2^((i-57)/12);%37+12*log2(i/220);
        n=fs/fi+1;
        ni=floor(n);
        p=n-ni;
        a(i,:)=(p*ds(ni+1,:)+(1-p)*ds(ni,:));
    end
    yin_res=1-a(n0:n1_YIN,:);

    A=constqm(fs,[],1,n1_FFT,-1); %-0.5;
    X=cqgram(x,fs,WP,A)/WL;
    fft_res=X(n0:n1_FFT,:);
    fft_res=log(fft_res*1000+1);

    if (size(yin_res,2)<size(fft_res,2))
        fft_res=fft_res(:,1:size(yin_res,2));
    end
    if (size(yin_res,2)>size(fft_res,2))
        yin_res=yin_res(:,1:size(fft_res,2));
    end
    allres=[yin_res;fft_res];
    if (h<=1000)
        save(['D:\atlas\pitch\mirres\',names{h},'.mat'],'allres');
    else
        save(['D:\atlas\pitch\mirres\',names1{h-1000},'.mat'],'allres');
    end
    clc
    h
end