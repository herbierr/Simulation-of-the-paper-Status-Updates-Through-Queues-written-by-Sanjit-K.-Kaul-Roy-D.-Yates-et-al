%% 此程序为LCFS with preemption
clear all;
close all;
clc;

%% 初始化
lambda_set=0.1:0.1:3;
mu=1;
rho=lambda_set./mu;
N=1e6;
alpha=0.4;
t_arr1=zeros(1,N);
t_dep1=zeros(1,N);
%求所有到达时刻和离开时刻
for i=1:length(lambda_set)
    lambda=lambda_set(i);
    X=exprnd(1./lambda,1,N);
    S=exprnd(1./mu,1,N);
    for j=1:N
        if j==1
            t_arr1(j)=alpha.*X(j);
            t_dep1(j)=t_arr1(j)+S(j);
        else
            t_arr1(j)=t_arr1(j-1)+X(j);
            t_dep1(j)=t_arr1(j)+S(j);
        end
    end
    t=1;
    temp=t_arr1(1);%当前数据包到达时刻
    dep_temp=t_dep1(1);%当前数据包离开时刻
    t_arr=[];
    t_dep=[];
    for x=1:N-1
        if  dep_temp>t_arr1(x+1)%当前包被后一个包抢占
            temp=t_arr1(x+1);%temp表示当前数据包
            dep_temp=temp+S(x+1);%dep_temp表示当前数据包离开的时刻
        else
            t_arr(t)=temp;
            t_dep(t)=dep_temp;
            t=t+1;
            temp=t_arr1(x+1);
            dep_temp=temp+S(x+1);            
        end
    end
    for y=1:1:length(t_arr)-1
        service_time(y+1)=t_dep(y+1)-t_arr(y+1);
        Y(y+1)=t_dep(y+1)-t_dep(y);
    end
    Y(1)=t_dep(1);
    service_time(1)=t_dep(1)-t_arr(1);
    P=0;
    Q=0;
    for s=1:1:length(t_arr)-1
        Q=Q+(service_time(s).*2+Y(s+1)).*Y(s+1)./2;
        P=P+Y(s);
    end
    Delta(i)=(Q+((1-alpha).*X(1).*2+Y(1)).*Y(1)./2)./(P+Y(length(t_arr)));
    %% 理论值
    Delta_an(i)=1./lambda+1./mu;
end

%% 画图
figure;
plot(rho,Delta,'*r')
hold on
plot(rho,Delta_an,'-ok')
hold on
grid on
xlabel('\rho');
ylabel('\Delta')
legend('Simulation','analysis')