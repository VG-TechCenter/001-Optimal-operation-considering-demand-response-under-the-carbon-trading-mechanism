%% 碳交易机制下考虑需求响应的综合能源系统优化运行——魏震波
%场景 4: 无碳交易机制，无需求响应

clc;clear;close all;% 程序初始化
%% 读取数据
shuju=xlsread('carbon+DR数据.xlsx'); %把一天划分为24小时
load_e=shuju(2,:); %初始电负荷
load_h=shuju(3,:); %初始热负荷
P_PV=shuju(4,:);    %光电预测
P_WT=shuju(5,:);    %风电预测
pe_b=shuju(6,:); %需求响应前电价
pe_a=shuju(7,:); %需求响应电价
ph_b=shuju(8,:); %需求响应前热价
ph_a=shuju(9,:); %需求响应热价

OP_load_e=zeros(1,24);%优化后的电负荷
OP_load_h=zeros(1,24);%优化后的热负荷
OP_load_e=load_e; %只考虑碳交易，优化后的负荷即为初始电负荷
OP_load_h=load_h; %只考虑碳交易，优化后的负荷即为初始热负荷
%% IES电网交互电价
price_buy_grid=shuju(7,:); %向电网购电价
price_sell_grid=shuju(10,:); %向电网售电价
%% 供应测定义机组变量
%CHP
P_GT=sdpvar(1,24,'full');%燃气轮机输出功率
e_GT=0.3;%燃气轮机供电效率
h_GT=0.4;%燃气轮机供热效率
P_WHB=sdpvar(1,24,'full');%余热锅炉输出功率
r_WHB=0.80;%热回收效率
P_ORC=sdpvar(1,24,'full');%ORC输出功率
r_ORC=0.80;%ORC效率

P_GB=sdpvar(1,24,'full');%燃气锅炉输出功率
h_GB=0.9;%燃气锅炉供热效率

P_HP=sdpvar(1,24,'full');%热泵输入功率
COP_HP=4.4;%电制冷机冷系数

B_grid=sdpvar(1,24,'full');%购电电量
S_grid=sdpvar(1,24,'full');%售电电量
B_grid_sign=binvar(1,24,'full'); %购电标志

ES_char=sdpvar(1,24,'full');%储电系统充电
ES_dischar=sdpvar(1,24,'full');%储电系统放电
ES_char_sign=binvar(1,24,'full');%储电系统充电标志
ES_max=400; ES_loss=0.01;ES_c_char=0.95;ES_c_discharge=0.9;%电储能最大容量；自损系数；充、放能效率

HS_char=sdpvar(1,24,'full');%储热系统充热
HS_dischar=sdpvar(1,24,'full');%储热系统放热
HS_char_sign=binvar(1,24,'full'); %储热系统充热标志
HS_max=400; HS_loss=0.01;HS_c_char=0.95;HS_c_discharge=0.9;%热储能最大容量；自损系数；充、放能效率;原文0.8

%%  IES供应侧储能约束     
% ES_start=80;
% HS_start=50;  %电储能和热储能的初始能量
% for i=1:24
%     ES(1,i)=ES_start+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %储电初始容量约束
%     ES_start=ES(1,i);
% end
% for i=1:23
%     ES(1,i+1)= ES(1,i)*(1-ES_loss)+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %储电容量约束
% end
% ES_start=ES(1,24);
% 
% for i=1:24
%     EH(1,i)=HS_start+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %储热初始容量约束
%     HS_start=EH(1,i);
% end
% for i=1:23
%     EH(1,i+1)= EH(1,i)*(1-HS_loss)+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %储热容量约束
% end
% HS_start=EH(1,24);
ES_start=sdpvar(1,24);
HS_start=sdpvar(1,24);
%% IES供应侧优化
% 约束条件
%本代码在第一篇的基础上对储能部分进行了改进，看起来更加直观，100-113行为改进代码，81-99为源代码。
%注意理解储能和充放电两个概念，本代码对原有代码的一些角标进行了改写，注意甄别。
C=[];
C=[C,
%储能容量约束
0<=ES_start<=400,
0<=HS_start<=400,
%初始容量
ES_start(1)==80,
HS_start(1)==50,
%始末容量守恒
ES_start(1)==ES_start(24),
ES_start(1)==ES_start(24),
%储能容量变化
ES_start(2:24)==ES_start(1:23)+0.95*ES_char(2:24)-ES_dischar(2:24)/0.95,
HS_start(2:24)==HS_start(1:23)+0.95*HS_char(2:24)-HS_dischar(2:24)/0.95,
%充放电状态唯一
%最大充放功率约束
%       0<=ES_char<=ES_char_sign*250,
%       0<=ES_dischar<=(1-ES_char_sign)*250,
%       0<=HS_char<=HS_char_sign*250,
%       0<=HS_dischar<=(1-HS_char_sign)*250,
];
%电储能设备运行约束
 for i=1:24  %运行约束
     C=[C,0<=ES_char(1,i)<=250*ES_char_sign(1,i)];
     C=[C,0<=ES_dischar(1,i)<=250*(1-ES_char_sign(1,i))];
 end
 
%  for i=1:24 %余量约束
%      C=[C,0<=ES_start(1,i)<=400];
%  end
     
 %热储能设备运行约束
 for i=1:24  %运行约束
     C=[C,0<=HS_char(1,i)<=250*HS_char_sign(1,i)];
     C=[C,0<=HS_dischar(1,i)<=250*(1-HS_char_sign(1,i))];
 end
 
%  for i=1:24 %余量约束
%      C=[C,0<=ES_start(1,i)<=400];
%  end
     
 a=0.5; 
%各个机组约束
for i=1:24   
    C = [C,0<=P_GT(i)<=4000];%燃气轮机上下限约束
    C = [C,0<=P_WHB(i)<=1000];%余热锅炉上下限约束
    C = [C,0<=P_GB(i)<=1000];%燃气锅炉上下限约束 
    C = [C,0<=P_HP(i)<400];%热泵上下限约束
    C = [C,0<=P_ORC(i)<=400];%余热发电上下限约束
    C = [C,P_GT(i)*h_GT*r_WHB*a==P_WHB(i)];%余热回收分配公式，a为分配系数
    C = [C,P_GT(i)*h_GT*r_ORC*(1-a)==P_ORC(i)];   
    C = [C, 0<= B_grid(i)<= B_grid_sign*1500];
    C = [C, 0<= S_grid(i)<=(1-B_grid_sign)*1500]; %外部电网联络线约束
end

%功率平衡约束
for i=1:24       
C = [C,B_grid(i)-S_grid(i)+P_WT(i)+P_PV(i)+e_GT*P_GT(i)+P_ORC(i)-P_HP(i)-ES_char(1,i)+ES_dischar(1,i)==OP_load_e(i)]; %电平衡
C = [C,P_WHB(i)+P_GB(i)+COP_HP*P_HP(i)-HS_char(1,i)+HS_dischar(1,i)==OP_load_h(i)];%热平衡约束
end

%% 目标函数
%碳交易机制下考虑需求响应的综合能源系统以系统总收益最大为目标函数。（与原文不同）
%收入
Income=pe_a*OP_load_e'+ph_a*OP_load_h';
%包含系统运维成本、购售成本、碳交易成本，三部分构成成本
% RIES运维成本
GT=0.04;%燃气轮机单位运维成本
WHB=0.025;%余热锅炉单位运维成本
HP=0.025;%热泵单位运维成本
PV=0.016;%光伏单位运维成本
WT=0.018;%风机单位运维成本
ES_start=0.018;%电储能单位运维成本
HS=0.016;%热储能单位运维成本
C_om=0;%运维成本
for i=1:24
C_om=C_om+P_GT(i)*GT+P_WHB(i)*WHB++P_HP(i)*HP+P_WT(i)*WT+P_PV(i)*PV+ES_start*(ES_char(1,i)+ES_dischar(1,i))+HS*(HS_char(1,i)+HS_dischar(1,i));
end

H_gas=9.88;%天然气热值
C_buy=0;%购能成本
for i=1:24
C_buy=C_buy+B_grid(i)*price_buy_grid(i)-S_grid(i)*price_sell_grid(i)+2.55*(P_GT(i)/e_GT/H_gas+P_GB(i)/h_GB/H_gas);                              
end
 PP=2.53;%电量的折算系数
%目标函数

f=C_om+C_buy;
op = sdpsettings('solver','cplex', 'verbose', 0);

optimize(C,f,op)
CC=value(f) %总成本
F=Income-CC%利润
om=value(C_om);
grid=value(C_buy);
% car=value(C_carbon_trade);
Q_carbon=0;%碳排放量 
 for i=1:24
Q_carbon=Q_carbon+(PP*e_GT*P_GT(i)+h_GT*P_GT(i)+P_GB(i));                              
end
value(Q_carbon);
%% huatu
x=1:24;
figure(1)
plot(x,OP_load_e,'-rs',x,load_e,'--bo');
xlabel('时间/h');
ylabel('电负荷/kW');
title('需求响应前后电负荷曲线');
legend('优化后电负荷','优化前电负荷');
x=1:24;
figure(2)
plot(x,OP_load_h,'-rs',x,load_h,'--bo');
xlabel('时间/h');
ylabel('热负荷/kW');
title('需求响应前后热负荷曲线');
legend('优化后热负荷','优化前热负荷');
figure(3)
stairs(x,pe_b,'-b')
hold on
stairs(x,pe_a,'--b')
hold on
stairs(x,ph_b,'-r')
hold on
stairs(x,ph_a,'--r')
title('价格曲线');
legend('初始电价','分时电价','初始热价','分时热价');
x=1:24;
figure(4)
plot(x,P_PV,'-m')
hold on
plot(x,P_WT,'-c')
title('风光预测');
legend('光伏预测曲线','风机预测曲线');

figure(5)
plot_e=[];
for t=1:24
    plot_e(1,t)=B_grid(t);%购电量
    plot_e(2,t)=-S_grid(t);%卖电量
    plot_e(3,t)=P_ORC(t);%ORC产电
    plot_e(4,t)=P_GT(t)*e_GT;%GT产电
    plot_e(5,t)=-P_HP(t);%HP耗电
    plot_e(6,t)=P_PV(t);%光伏出力
    plot_e(7,t)=P_WT(t);%风电出力
    plot_e(8,t)=ES_dischar(t);%ES放电
    plot_e(9,t)=-ES_char(t);%ES充电
end
bar(plot_e','stacked')
xlabel('t')
ylabel('w')
title('电功率使用情况');
legend('购电量','卖电量','ORC产电','GT产电','HP耗电','光伏出力','风电出力','ES放电','ES充电');



b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
hh=value([P_WHB;P_GB;HS_dischar;COP_HP*P_HP;b]);
hh1=value([b;b;b;b;-HS_char]);
figure(6)
bar(hh','stack');
legend('CHP产热','GB产热','HS放热','HP产热','HS充热');
hold on
bar(hh1','stack');
plot(x,OP_load_h,'-rs');
title('热负荷平衡');
xlabel('时段');ylabel('功率/kW');