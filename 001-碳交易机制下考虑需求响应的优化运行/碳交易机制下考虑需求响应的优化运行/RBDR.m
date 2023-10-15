function [Prl_e,Prl_h]=RBDR(pe_a,ph_a,e_W4,h_W4)

%替代型需求响应
%与文章不同，转换后成本较低方可发生替代
P2H=1.83; %电转热系数
%读取数据
shuju=xlsread('carbon+DR数据.xlsx'); %把一天划分为24小时
load_e=shuju(2,:); %初始电负荷
load_h=shuju(3,:); %初始热负荷
Prl_e=zeros(1,24);%电负荷被替代量
Prl_h=zeros(1,24);%热负荷被替代量
for i=1:24
    if pe_a(i)<P2H*ph_a(i)  %转换后价格成本较低则替换
      Prl_e(i)=0;
    else
      Prl_e(i)=e_W4*load_e(i);
    end
end
for i=1:24
    if pe_a(i)/P2H<ph_a(i) %转换后价格成本较低则替换
      Prl_h(i)=0;
    else
      Prl_h(i)=h_W4*load_h(i);
    end
end