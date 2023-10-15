%% 碳交易机制下考虑需求响应的综合能源系统优化运行——魏震波
%场景 2: 碳交易机制下考虑需求响应
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

%% 需求侧定义变量
Z=zeros(24,24); %需求弹性矩阵
e_W1=0.5;e_W2=0.3;e_W3=0.15;e_W4=0.05;%约束：固定、可转移、可消减、可替代负荷占比50%，30%，15%，5% %这里进行4. 2. 2 需求响应灵敏度分析
h_W1=0.5;h_W2=0.2;h_W3=0.2;h_W4=0.1;%约束：固定、可转移、可消减、可替代负荷占比50%，30%，15%，5%  %这里进行4. 2. 2 需求响应灵敏度分析
Psl_e=zeros(1,24);%转移电负荷量
Pcl_e=zeros(1,24);%消减电负荷量
Prl_e=zeros(1,24);%电负荷被替代量
Psl_h=zeros(1,24);%转移热负荷量
Pcl_h=zeros(1,24);%消减热负荷量
Prl_h=zeros(1,24);%热负荷被替代量
P2H=1.83; %电转热系数
OP_load_e=zeros(1,24);%优化后的电负荷
OP_load_h=zeros(1,24);%优化后的热负荷
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
%% DR-需求侧响应优化
Z_e=ElasticityMatrix(pe_a); %电价需求弹性矩阵
Z_e_CL=diag(diag(Z_e)); %消减电负荷弹性矩阵,对角阵
Z_e_SL=Z_e-Z_e_CL; %转移电负荷弹性矩阵

Z_h=ElasticityMatrix(ph_a); %热价需求弹性矩阵
Z_h_CL=diag(diag(Z_h)); %消减热负荷弹性矩阵,对角阵
Z_h_SL=Z_h-Z_h_CL; %转移热负荷弹性矩阵

%价格型需求响应
[Psl_e,Pcl_e]=IBDR(Z_e_SL,Z_e_CL,load_e,pe_a,pe_b,e_W2,e_W3);%（转移电负荷弹性矩阵，削减电负荷弹性矩阵，初始电负荷，需求响应电价，需求响应前电价，可转移电负荷比例，可削减电负荷比例）
[Psl_h,Pcl_h]=IBDR(Z_h_SL,Z_h_CL,load_h,ph_a,ph_b,h_W2,h_W3);%（转移热负荷弹性矩阵，削减热负荷弹性矩阵，初始热负荷，需求响应热价，需求响应前热价，可转移热负荷比例，可削减热负荷比例）
%替代型需求响应
[Prl_e,Prl_h]=RBDR(pe_a,ph_a,e_W4,h_W4);%（需求响应电价，需求响应热价，可替代电负荷占比，可替代热负荷占比）

OP_load_e=load_e+Psl_e+Pcl_e-Prl_e+Prl_h/P2H;%优化后的电负荷（初始电负荷，转移电负荷，削减电负荷，电负荷被替代量，热负荷被替代量）
OP_load_h=load_h+Psl_h+Pcl_h-Prl_h+Prl_e*P2H;%优化后的热负荷（初始热负荷，转移热负荷，削减热负荷，热负荷被替代量，电负荷被替代量）
%%  IES供应侧储能约束     
ES_start=80;
HS_start=50;  %电储能和热储能的初始能量
for i=1:24
    ES(1,i)=ES_start+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %储电初始容量约束
    ES_start=ES(1,i);
end
for i=1:23
    ES(1,i+1)= ES(1,i)*(1-ES_loss)+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %储电容量约束
end
ES_start=ES(1,24);

for i=1:24
    EH(1,i)=HS_start+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %储热初始容量约束
    HS_start=EH(1,i);
end
for i=1:23
    EH(1,i+1)= EH(1,i)*(1-HS_loss)+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %储热容量约束
end
HS_start=EH(1,24);

%% IES供应侧优化
% 约束条件
C=[];
%%电储能设备运行约束
 for i=1:24  %运行约束
     C=[C,0<=ES_char(1,i)<=250*ES_char_sign(1,i)];
     C=[C,0<=ES_dischar(1,i)<=250*(1-ES_char_sign(1,i))];
 end
 
 for i=1:24 %余量约束
     C=[C,0<=ES(1,i)<=400];
 end
     
 %热储能设备运行约束
 for i=1:24  %运行约束
     C=[C,0<=HS_char(1,i)<=250*HS_char_sign(1,i)];
     C=[C,0<=HS_dischar(1,i)<=250*(1-HS_char_sign(1,i))];
 end
 for i=1:24 %余量约束
     C=[C,0<=EH(1,i)<=400];
 end
     
 a=0.5; %这里进行4. 2. 3 GT 产热分配比例的影响
%各个机组约束
for i=1:24   
    C = [C,0<=P_GT(i)<=4000];%燃气轮机上下限约束
    C = [C,0<=P_GB(i)<=1000];%燃气锅炉上下限约束 
    C = [C,0<=P_HP(i)<400];%热泵上下限约束
    C = [C,0<=P_ORC(i)<=400];%ORC上下限约束
    C = [C,P_GT(i)*h_GT*r_WHB*a<=P_WHB(i)];%余热回收分配公式，a为分配系数
    C = [C,P_GT(i)*h_GT*r_ORC*(1-a)<=P_ORC(i)];
    
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
%收入收入，供应侧考虑用户侧需求响应时会被给与经济补贴以鼓励社会责任
Income=pe_a*OP_load_e'+ph_a*OP_load_h'+6000; %向用户卖电卖热
%包含系统运维成本、购售成本、碳交易成本，三部分构成成本
% RIES运维成本
GT=0.04;%燃气轮机单位运维成本
WHB=0.025;%余热锅炉单位运维成本
HP=0.025;%热泵单位运维成本
PV=0.016;%光伏单位运维成本
WT=0.018;%风机单位运维成本
ES=0.018;%电储能单位运维成本
HS=0.016;%热储能单位运维成本
C_om=0;%运维成本
for i=1:24
C_om=C_om+P_GT(i)*GT+P_WHB(i)*WHB++P_HP(i)*HP+P_WT(i)*WT+P_PV(i)*PV+ES*(ES_char(1,i)+ES_dischar(1,i))+HS*(HS_char(1,i)+HS_dischar(1,i));
end

H_gas=9.88;%天然气热值
C_buy=0;%购能成本
for i=1:24
C_buy=C_buy+B_grid(i)*price_buy_grid(i)-S_grid(i)*price_sell_grid(i)+2.55*(P_GT(i)/e_GT/H_gas+P_GB(i)/h_GB/H_gas);                              
end

C_carbon_trade=0;%碳交易成本
PP=2.53;%电量的折算系数
for i=1:24
C_carbon_trade=C_carbon_trade+0.5*(0.57-0.6101)*(PP*e_GT*P_GT(i)+h_GT*P_GT(i)+P_GB(i)); %0.50yuan/t
%这里进行4. 2. 4 碳交易价格对系统运行的影响                             
end


%目标函数

f=C_om+C_buy+C_carbon_trade;
op = sdpsettings('solver','cplex', 'verbose', 0);

optimize(C,f,op)
CC=value(f) %总成本
F=Income-CC%利润
om=value(C_om);
grid=value(C_buy);
car=value(C_carbon_trade);
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

b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
ee=value([B_grid;ES_dischar;(e_GT*P_GT+P_ORC);P_WT;P_PV;b;b]);
ee1=value([b;b;b;b;b;-ES_char;-P_HP;-S_grid]);
figure(5)
bar(ee','stack');
legend('购电量','ES放电','CHP产电','风电出力','光伏出力','ES充电','HP耗电','卖电量');
hold on
bar(ee1','stack');
plot(x,OP_load_e,'-gs');
title('电负荷平衡');
xlabel('时段');ylabel('功率/kW');


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

  