%lstm trainer along with dev

itermax=10;
tot_length=1033; %1000;
%initialize params
%bsize=1;

hparams;
clip=0;
lr_0=-1; %learning rate
t_max=100;
d=100; %hidden size
alp=1; %sigmoid alpha
issoftmax=0;
islogloss=0;
nx=106;
ny=48;
load names
load names1
names=[names;names1];

%initialize network
W=randn(4*d,nx+d)*(1/d);
Wc=W(1:d,1:nx);
Wi=W(d+1:2*d,1:nx);
Wf=W(2*d+1:3*d,1:nx);
Wo=W(3*d+1:4*d,1:nx);
Uc=W(1:d,nx+1:nx+d);
Ui=W(d+1:2*d,nx+1:nx+d);
Uf=W(2*d+1:3*d,nx+1:nx+d);
Uo=W(3*d+1:4*d,nx+1:nx+d);
Why=randn(ny,d)*(1/d);
mW=zeros(size(W));
mWhy=zeros(size(Why));

trains=1:tot_length; % 1:2:1000 for train-dev
ltrain=length(trains);
devs=1:10:1000;
ldev=length(devs);
%se=zeros(itermax*length(trains),1);

se_train=zeros(ltrain,1);
se_dev=zeros(ldev,1);
se_large=zeros(itermax,2);
perm=trains(randperm(ltrain));
%perm=ones(size(perm)); %for instance only
en=0;

for iter=1:itermax
    lr=lr_0*min(2/iter,iter/2);
    perm=trains(randperm(ltrain));
    en=0;
    for dataid=1:ltrain
        %lr=lr_0*min(1400/en,en/1400);
        %initialize input
        load(['D:\atlas\pitch\mirres\',names{perm(dataid)},'.mat']);
        load(['D:\atlas\pitch\mirpv\',names{perm(dataid)},'.mat']);
        sres=size(allres);
        spv=size(pv);
        % nx=sres(1);
        % ny=spv(1);
        lres=sres(2);
        lpv=spv(2);
        if (lres>lpv)
            allres=allres(:,1:lpv);
            lres=lpv;
        end
        if (lres<lpv)
            pv=pv(:,1:lres);
            lpv=lres;
        end
        %tmax=max(sx(2),sy(2))+1;
        %x=[zeros(nx,1),x];
        %yt=[zeros(ny,1),yt];
        bsize=ceil(lres/t_max);
        
        sn=0;
        en=en+1;
        for b=1:bsize
            %initialize input here
            p=(b-1)*t_max+1;
            q=min(b*t_max,lres);
            tmax=q-p+2;
            x=[zeros(nx,1),allres(:,p:q)];
            yt=[zeros(ny,1),pv(:,p:q)];
            % x, yt, tmax
            h=randn(d,1);
            c=zeros(d,1);

            %initialize recorder
            A=zeros(d,tmax);
            I=zeros(d,tmax);
            F=zeros(d,tmax);
            O=zeros(d,tmax);
            C=zeros(d,tmax);
            H=zeros(d,tmax);
            H(:,1)=h;
            Y=zeros(ny,tmax);
            E=zeros(1,tmax);

            % Forward
            for t=2:tmax
                %forward
                a=tanh(Wc*x(:,t)+Uc*h);
                i=sigmf(Wi*x(:,t)+Ui*h,[alp,0]);
                f=sigmf(Wf*x(:,t)+Uf*h,[alp,0]);
                o=sigmf(Wo*x(:,t)+Uo*h,[alp,0]);
                c=i.*a+f.*c;
                h=o.*tanh(c);
                y=Why*h;
                if (issoftmax==1)
                    y=y-max(y);
                    y=exp(y);
                    y=y/sum(y);
                end
                if (islogloss==1)
                    e=-sum(yt(:,t).*log(y));
                else
                    e=sum((y-yt(:,t)).^2);
                end
                %record
                A(:,t)=a;
                I(:,t)=i;
                F(:,t)=f;
                O(:,t)=o;
                C(:,t)=c;
                H(:,t)=h;
                Y(:,t)=y;
                E(t)=e;
                se_train(en)=se_train(en)+e;
                sn=sn+1;
            end

            % Backword
            dc1=zeros(size(h));
            dh1=zeros(size(h));
            c1=C(:,tmax);
            h1=H(:,tmax);
            for t=tmax:-1:2
                %extract record
                a=A(:,t);
                i=I(:,t);
                f=F(:,t);
                o=O(:,t);
                c=c1;
                h=h1;
                y=Y(:,t);
                c1=C(:,t-1);
                h1=H(:,t-1);
                J=[x(:,t);h1];
                %backward part 1
                if (islogloss==1)
                    dy=-yt(:,t)./y;
                else
                    dy=y-yt(:,t);
                end
                if (issoftmax==1)
                    Ja=diag(y)-y*y';
                    dy=Ja*dy;
                end
                dWhy=dy*h';
                dh=dh1+Why'*dy;
                do=dh.*tanh(c);
                dc=dc1+dh.*o.*(1-(tanh(c)).^2);
                di=dc.*a;
                da=dc.*i;
                df=dc.*c1;
                dc1=dc.*f;
                %backward part 2
                da2=da.*(1-(tanh(a)).^2);
                di2=di.*i.*(1-i);
                df2=df.*f.*(1-f);
                do2=do.*o.*(1-o);
                dz=[da2;di2;df2;do2];
                dJ=W'*dz;
                dh1=dJ(nx+1:nx+d);
                dW=dz*J';
                %clip
                if (clip>0)
                    dW=dW.*(abs(dW)<clip)+clip*(dW>=clip)-clip*(dW<=-clip);
                    dWhy=dWhy.*(abs(dWhy)<clip)+clip*(dWhy>=clip)-clip*(dWhy<=-clip);
                end
                %record
                mW=mW+dW;
                mWhy=mWhy+dWhy;
            end
        end
        %update
        W=W+lr*mW/sn;
        Why=Why+lr*mWhy/sn;
        mW=zeros(size(W));
        mWhy=zeros(size(Why));
        Wc=W(1:d,1:nx);
        Wi=W(d+1:2*d,1:nx);
        Wf=W(2*d+1:3*d,1:nx);
        Wo=W(3*d+1:4*d,1:nx);
        Uc=W(1:d,nx+1:nx+d);
        Ui=W(d+1:2*d,nx+1:nx+d);
        Uf=W(2*d+1:3*d,nx+1:nx+d);
        Uo=W(3*d+1:4*d,nx+1:nx+d);
        se_train(en)=se_train(en)/sn;
        clc
        iter
        dataid
    end
    se_large(iter,1)=mean(se_train);
    save(['savs/pitch_lstm_',num2str(iter),'.mat'],'Wc','Wi','Wf','Wo',...
        'Uc','Ui','Uf','Uo','Why','issoftmax','islogloss','alp','se_large');
    
    %  DDDDD   EEEEEE  VV  VV
    %  DD  DD  EE      VV  VV
    %  DD  DD  EEEEEE  VV  VV
    %  DD  DD  EE       VVVV 
    %  DDDDD   EEEEEE    VV  
    perm=devs(randperm(ldev));
    en=0;
    for dataid=1:ldev
        %initialize input
        load(['D:\atlas\pitch\mirres\',names{perm(dataid)},'.mat']);
        load(['D:\atlas\pitch\mirpv\',names{perm(dataid)},'.mat']);
        sres=size(allres);
        spv=size(pv);
        % nx=sres(1);
        % ny=spv(1);
        lres=sres(2);
        lpv=spv(2);
        if (lres>lpv)
            allres=allres(:,1:lpv);
            lres=lpv;
        end
        if (lres<lpv)
            pv=pv(:,1:lres);
            lpv=lres;
        end
        %tmax=max(sx(2),sy(2))+1;
        %x=[zeros(nx,1),x];
        %yt=[zeros(ny,1),yt];
        
        sn=0;
        en=en+1;
        %initialize input here
        tmax=lres+1;
        x=[zeros(nx,1),allres];
        yt=[zeros(ny,1),pv];
        % x, yt, tmax
        h=randn(d,1);
        c=zeros(d,1);
        
        %initialize recorder
        A=zeros(d,tmax);
        I=zeros(d,tmax);
        F=zeros(d,tmax);
        O=zeros(d,tmax);
        C=zeros(d,tmax);
        H=zeros(d,tmax);
        H(:,1)=h;
        Y=zeros(ny,tmax);
        E=zeros(1,tmax);
        
        % Forward
        for t=2:tmax
            %forward
            a=tanh(Wc*x(:,t)+Uc*h);
            i=sigmf(Wi*x(:,t)+Ui*h,[alp,0]);
            f=sigmf(Wf*x(:,t)+Uf*h,[alp,0]);
            o=sigmf(Wo*x(:,t)+Uo*h,[alp,0]);
            c=i.*a+f.*c;
            h=o.*tanh(c);
            y=Why*h;
            if (issoftmax==1)
                y=y-max(y);
                y=exp(y);
                y=y/sum(y);
            end
            if (islogloss==1)
                e=-sum(yt(:,t).*log(y));
            else
                e=sum((y-yt(:,t)).^2);
            end
            %record
            A(:,t)=a;
            I(:,t)=i;
            F(:,t)=f;
            O(:,t)=o;
            C(:,t)=c;
            H(:,t)=h;
            Y(:,t)=y;
            E(t)=e;
            se_dev(en)=se_dev(en)+e;
            sn=sn+1;
        end
        
        % No Backword
        % No update
        se_dev(en)=se_dev(en)/sn;
        clc
        iter
        ltrain+dataid
    end
    se_large(iter,2)=mean(se_dev);
    plot(1:iter,log(se_large(1:iter,:)));
    xlabel('songs trained');
    ylabel('log error');
    legend('train','dev','Location','NorthEast');
    drawnow;
end

save('pitch_lstm.mat','Wc','Wi','Wf','Wo','Uc','Ui','Uf','Uo','Why',...
    'issoftmax','islogloss','alp','se_large');