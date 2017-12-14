function draw3d(xdata1, ydata1, zdata1, clim)
    figure1 = figure;
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    if (nargin<3)
        surf(xdata1,'Parent',axes1,'EdgeAlpha',0);
        if (nargin>1)
            set(axes1,'CLim',ydata1);
        end
    else
        if (isempty(xdata1))
            xdata1=1:size(zdata1,1);
        end
        if (isempty(ydata1))
            ydata1=1:size(zdata1,2);
        end
        surf(xdata1,ydata1,zdata1,'Parent',axes1,'EdgeAlpha',0);
        if (nargin>3)
            set(axes1,'CLim',clim);
        end
    end
    view(axes1,[-0.38 90]);
    grid(axes1,'on');
end
