load names
n1=38;
n2=84;
for i=1:1000
    x=load(['D:\MIR-1K\PitchLabel\',names{i},'.pv']);
    l=length(x);
    pv=zeros(n2-n1+2,l);
    for j=1:l
        if (x(j)<n1)
            pv(1,j)=1;
        else
            % pv(j,round(x(j))-n1+2)=1;
            fx=floor(x(j));
            pv(fx-n1+2,j)=pv(fx-n1+2,j)+1-(x(j)-fx);
            pv(fx-n1+3,j)=pv(fx-n1+3,j)+(x(j)-fx);
        end
    end
    save(['D:\atlas\pitch\mirpv\',names{i},'.mat'],'pv');
    pv0=pv(1,:);
    pv=pv(2:end,:);
    save(['D:\atlas\pitch\mirpv1\',names{i},'.mat'],'pv');
    pv=[pv0;1-pv0];
    save(['D:\atlas\pitch\miruv\',names{i},'.mat'],'pv');
    clc
    i
end