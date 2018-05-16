%hyper-parameters for songs

WP=882;
n0=38;% 35=62Hz,  36=65Hz limit
n1=84;
n1_YIN=84;% 77=698Hz, 84=1040Hz limit
n1_FFT=96;
fi0=220*2^((n0-57)/12)-0.01;
WL=round(WP*2);