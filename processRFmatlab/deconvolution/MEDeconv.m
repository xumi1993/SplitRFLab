function [hz,hr,ht]=MEDeconv(RM,TM,ZM,c)
%subroutine for maximum entropy deconvolution ref:Qingju Wu,2003,µØÕðÑ§±¨
%[hz,hr,ht]=MEDeconv(RM,TM,ZM,c)
npts=length(RM);
a1=zeros(npts,1);a2=a1;a1(1)=1.0;auto0=0.0;crossr0=0.0;crosst0=0.0;
hz=zeros(npts,1);
hr=hz;ht=hz;
for i1=1:npts
    auto0=auto0+ZM(i1)*ZM(i1);
    crossr0=crossr0+RM(i1)*ZM(i1);
    crosst0=crosst0+TM(i1)*ZM(i1);
end
%preliminary forward and backward predective error
ef=ZM;eb=ZM;
stable=c*auto0;

%firtst order receiver function value
hz(1)=1.0;hr(1)=crossr0/auto0;ht(1)=crosst0/auto0;

%preliminary filter residual 
sz=ZM-hz(1)*ZM;sr=RM-hr(1)*ZM;st=TM-ht(1)*ZM;
%begin the Levinson Iterations
for i=2:npts
    %calculate the k+1 order reflection coefficient rk from k order
    %E.Q.(33)
    top=0.0;bot=0.0;
    for j=i:npts
        bot=bot+ef(j)^2+eb(j-i+1)^2;
        top=top+eb(j-i+1)*ef(j);
    end
    bot =bot+stable;
    rk=2.0*top/bot;
    %calculate the k+1 order predective error filter factor a2(j) from k order
    %E.Q.(29)
    a1(i)=0.0;
    for j=1:i
        a2(j)=a1(j)-rk*a1(i-j+1);
    end
    %calculate the k+1 order forward and backward predective error ef(j) and eb(j) from k order
    %E.Q.(30)
    for j=i:npts
        tmp=ef(j);
        ef(j)=ef(j)-rk*eb(j-i+1);
        eb(j-i+1)=eb(j-i+1)-rk*tmp;
    end
    a1=a2;
    %calculate the k+1 order reflection coefficient(rz,rr,rt) about receiver function from k order
    %E.Q.(38)
    bot=0.0;ztop=0.0;rtop=0.0;ttop=0.0;
    for j=i:npts
        bot=bot+eb(j-i+1)^2;
        ztop=ztop+sz(j)*eb(j-i+1);
        rtop=rtop+sr(j)*eb(j-i+1);
        ttop=ttop+st(j)*eb(j-i+1);
    end
    bot=bot+0.5*stable;
    rz=ztop/bot;rr=rtop/bot;rt=ttop/bot;
    %computer the receiver functions
    for j=1:i
        hz(j)=hz(j)+rz*a1(i-j+1);
        hr(j)=hr(j)+rr*a1(i-j+1);
        ht(j)=ht(j)+rt*a1(i-j+1);
    end
    %computer the next filter residual
    for j=i:npts
        sz(j)=sz(j)-rz*eb(j-i+1);
        sr(j)=sr(j)-rr*eb(j-i+1);
        st(j)=st(j)-rt*eb(j-i+1);
    end 
end
end