function drawlin(XLIM0,YLIM0,Y1)

    figure1 = figure;

    axes1 = axes('Parent',figure1);
    hold(axes1,'on');

    plot(Y1,'Marker','.');

    XLIM=zeros(1,2);
    if (length(XLIM0)==2)
        XLIM0=[XLIM0(1),16,XLIM0(2)];
    end
    XLIM(1)=floor(XLIM0(1)/XLIM0(2))*XLIM0(2)+0.5;
    XLIM(2)=floor(XLIM0(3)/XLIM0(2)+1)*XLIM0(2)+0.5;
    xlim(axes1,XLIM);
    Xs=XLIM(1):XLIM0(2):XLIM(2);
    XTs=cell(1,length(Xs));
    for i=1:length(Xs)
        XTs{i}=num2str(i-1);
    end
    
    YLIM=YLIM0(1:2);
    if (length(YLIM0)>2)
        Yx=mod(YLIM0(3)+4,12);
    else
        Yx=4;
    end
    ylim(axes1,YLIM);
    Ys_s=ceil((YLIM(1)-Yx+0.5)/12)*12+Yx;
    Ys_t=floor((YLIM(2)-Yx+0.5)/12)*12+Yx;
    Ys=Ys_s:12:Ys_t;
    set(axes1,'XGrid','on','XTick',Xs,'XTickLabel',XTs);
    set(axes1,'YGrid','on','YTick',Ys);
end
