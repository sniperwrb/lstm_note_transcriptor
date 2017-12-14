%hyper-parameters for songs

WP=320;
n0=35;% 35=62Hz,  36=65Hz limit
n1=77;% 77=698Hz, 84=1040Hz limit
fi0=220*2^((n0-57)/12)-0.01;
WL=round(WP*2);