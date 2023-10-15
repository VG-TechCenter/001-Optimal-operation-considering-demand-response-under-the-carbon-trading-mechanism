%% ̼���׻����¿���������Ӧ���ۺ���Դϵͳ�Ż����С���κ��
%���� 4: ��̼���׻��ƣ���������Ӧ

clc;clear;close all;% �����ʼ��
%% ��ȡ����
shuju=xlsread('carbon+DR����.xlsx'); %��һ�컮��Ϊ24Сʱ
load_e=shuju(2,:); %��ʼ�縺��
load_h=shuju(3,:); %��ʼ�ȸ���
P_PV=shuju(4,:);    %���Ԥ��
P_WT=shuju(5,:);    %���Ԥ��
pe_b=shuju(6,:); %������Ӧǰ���
pe_a=shuju(7,:); %������Ӧ���
ph_b=shuju(8,:); %������Ӧǰ�ȼ�
ph_a=shuju(9,:); %������Ӧ�ȼ�

OP_load_e=zeros(1,24);%�Ż���ĵ縺��
OP_load_h=zeros(1,24);%�Ż�����ȸ���
OP_load_e=load_e; %ֻ����̼���ף��Ż���ĸ��ɼ�Ϊ��ʼ�縺��
OP_load_h=load_h; %ֻ����̼���ף��Ż���ĸ��ɼ�Ϊ��ʼ�ȸ���
%% IES�����������
price_buy_grid=shuju(7,:); %����������
price_sell_grid=shuju(10,:); %������۵��
%% ��Ӧ�ⶨ��������
%CHP
P_GT=sdpvar(1,24,'full');%ȼ���ֻ��������
e_GT=0.3;%ȼ���ֻ�����Ч��
h_GT=0.4;%ȼ���ֻ�����Ч��
P_WHB=sdpvar(1,24,'full');%���ȹ�¯�������
r_WHB=0.80;%�Ȼ���Ч��
P_ORC=sdpvar(1,24,'full');%ORC�������
r_ORC=0.80;%ORCЧ��

P_GB=sdpvar(1,24,'full');%ȼ����¯�������
h_GB=0.9;%ȼ����¯����Ч��

P_HP=sdpvar(1,24,'full');%�ȱ����빦��
COP_HP=4.4;%���������ϵ��

B_grid=sdpvar(1,24,'full');%�������
S_grid=sdpvar(1,24,'full');%�۵����
B_grid_sign=binvar(1,24,'full'); %�����־

ES_char=sdpvar(1,24,'full');%����ϵͳ���
ES_dischar=sdpvar(1,24,'full');%����ϵͳ�ŵ�
ES_char_sign=binvar(1,24,'full');%����ϵͳ����־
ES_max=400; ES_loss=0.01;ES_c_char=0.95;ES_c_discharge=0.9;%�索���������������ϵ�����䡢����Ч��

HS_char=sdpvar(1,24,'full');%����ϵͳ����
HS_dischar=sdpvar(1,24,'full');%����ϵͳ����
HS_char_sign=binvar(1,24,'full'); %����ϵͳ���ȱ�־
HS_max=400; HS_loss=0.01;HS_c_char=0.95;HS_c_discharge=0.9;%�ȴ����������������ϵ�����䡢����Ч��;ԭ��0.8

%%  IES��Ӧ�ഢ��Լ��     
% ES_start=80;
% HS_start=50;  %�索�ܺ��ȴ��ܵĳ�ʼ����
% for i=1:24
%     ES(1,i)=ES_start+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %�����ʼ����Լ��
%     ES_start=ES(1,i);
% end
% for i=1:23
%     ES(1,i+1)= ES(1,i)*(1-ES_loss)+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %��������Լ��
% end
% ES_start=ES(1,24);
% 
% for i=1:24
%     EH(1,i)=HS_start+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %���ȳ�ʼ����Լ��
%     HS_start=EH(1,i);
% end
% for i=1:23
%     EH(1,i+1)= EH(1,i)*(1-HS_loss)+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %��������Լ��
% end
% HS_start=EH(1,24);
ES_start=sdpvar(1,24);
HS_start=sdpvar(1,24);
%% IES��Ӧ���Ż�
% Լ������
%�������ڵ�һƪ�Ļ����϶Դ��ܲ��ֽ����˸Ľ�������������ֱ�ۣ�100-113��Ϊ�Ľ����룬81-99ΪԴ���롣
%ע����ⴢ�ܺͳ�ŵ���������������ԭ�д����һЩ�Ǳ�����˸�д��ע�����
C=[];
C=[C,
%��������Լ��
0<=ES_start<=400,
0<=HS_start<=400,
%��ʼ����
ES_start(1)==80,
HS_start(1)==50,
%ʼĩ�����غ�
ES_start(1)==ES_start(24),
ES_start(1)==ES_start(24),
%���������仯
ES_start(2:24)==ES_start(1:23)+0.95*ES_char(2:24)-ES_dischar(2:24)/0.95,
HS_start(2:24)==HS_start(1:23)+0.95*HS_char(2:24)-HS_dischar(2:24)/0.95,
%��ŵ�״̬Ψһ
%����Ź���Լ��
%       0<=ES_char<=ES_char_sign*250,
%       0<=ES_dischar<=(1-ES_char_sign)*250,
%       0<=HS_char<=HS_char_sign*250,
%       0<=HS_dischar<=(1-HS_char_sign)*250,
];
%�索���豸����Լ��
 for i=1:24  %����Լ��
     C=[C,0<=ES_char(1,i)<=250*ES_char_sign(1,i)];
     C=[C,0<=ES_dischar(1,i)<=250*(1-ES_char_sign(1,i))];
 end
 
%  for i=1:24 %����Լ��
%      C=[C,0<=ES_start(1,i)<=400];
%  end
     
 %�ȴ����豸����Լ��
 for i=1:24  %����Լ��
     C=[C,0<=HS_char(1,i)<=250*HS_char_sign(1,i)];
     C=[C,0<=HS_dischar(1,i)<=250*(1-HS_char_sign(1,i))];
 end
 
%  for i=1:24 %����Լ��
%      C=[C,0<=ES_start(1,i)<=400];
%  end
     
 a=0.5; 
%��������Լ��
for i=1:24   
    C = [C,0<=P_GT(i)<=4000];%ȼ���ֻ�������Լ��
    C = [C,0<=P_WHB(i)<=1000];%���ȹ�¯������Լ��
    C = [C,0<=P_GB(i)<=1000];%ȼ����¯������Լ�� 
    C = [C,0<=P_HP(i)<400];%�ȱ�������Լ��
    C = [C,0<=P_ORC(i)<=400];%���ȷ���������Լ��
    C = [C,P_GT(i)*h_GT*r_WHB*a==P_WHB(i)];%���Ȼ��շ��乫ʽ��aΪ����ϵ��
    C = [C,P_GT(i)*h_GT*r_ORC*(1-a)==P_ORC(i)];   
    C = [C, 0<= B_grid(i)<= B_grid_sign*1500];
    C = [C, 0<= S_grid(i)<=(1-B_grid_sign)*1500]; %�ⲿ����������Լ��
end

%����ƽ��Լ��
for i=1:24       
C = [C,B_grid(i)-S_grid(i)+P_WT(i)+P_PV(i)+e_GT*P_GT(i)+P_ORC(i)-P_HP(i)-ES_char(1,i)+ES_dischar(1,i)==OP_load_e(i)]; %��ƽ��
C = [C,P_WHB(i)+P_GB(i)+COP_HP*P_HP(i)-HS_char(1,i)+HS_dischar(1,i)==OP_load_h(i)];%��ƽ��Լ��
end

%% Ŀ�꺯��
%̼���׻����¿���������Ӧ���ۺ���Դϵͳ��ϵͳ���������ΪĿ�꺯��������ԭ�Ĳ�ͬ��
%����
Income=pe_a*OP_load_e'+ph_a*OP_load_h';
%����ϵͳ��ά�ɱ������۳ɱ���̼���׳ɱ��������ֹ��ɳɱ�
% RIES��ά�ɱ�
GT=0.04;%ȼ���ֻ���λ��ά�ɱ�
WHB=0.025;%���ȹ�¯��λ��ά�ɱ�
HP=0.025;%�ȱõ�λ��ά�ɱ�
PV=0.016;%�����λ��ά�ɱ�
WT=0.018;%�����λ��ά�ɱ�
ES_start=0.018;%�索�ܵ�λ��ά�ɱ�
HS=0.016;%�ȴ��ܵ�λ��ά�ɱ�
C_om=0;%��ά�ɱ�
for i=1:24
C_om=C_om+P_GT(i)*GT+P_WHB(i)*WHB++P_HP(i)*HP+P_WT(i)*WT+P_PV(i)*PV+ES_start*(ES_char(1,i)+ES_dischar(1,i))+HS*(HS_char(1,i)+HS_dischar(1,i));
end

H_gas=9.88;%��Ȼ����ֵ
C_buy=0;%���ܳɱ�
for i=1:24
C_buy=C_buy+B_grid(i)*price_buy_grid(i)-S_grid(i)*price_sell_grid(i)+2.55*(P_GT(i)/e_GT/H_gas+P_GB(i)/h_GB/H_gas);                              
end
 PP=2.53;%����������ϵ��
%Ŀ�꺯��

f=C_om+C_buy;
op = sdpsettings('solver','cplex', 'verbose', 0);

optimize(C,f,op)
CC=value(f) %�ܳɱ�
F=Income-CC%����
om=value(C_om);
grid=value(C_buy);
% car=value(C_carbon_trade);
Q_carbon=0;%̼�ŷ��� 
 for i=1:24
Q_carbon=Q_carbon+(PP*e_GT*P_GT(i)+h_GT*P_GT(i)+P_GB(i));                              
end
value(Q_carbon);
%% huatu
x=1:24;
figure(1)
plot(x,OP_load_e,'-rs',x,load_e,'--bo');
xlabel('ʱ��/h');
ylabel('�縺��/kW');
title('������Ӧǰ��縺������');
legend('�Ż���縺��','�Ż�ǰ�縺��');
x=1:24;
figure(2)
plot(x,OP_load_h,'-rs',x,load_h,'--bo');
xlabel('ʱ��/h');
ylabel('�ȸ���/kW');
title('������Ӧǰ���ȸ�������');
legend('�Ż����ȸ���','�Ż�ǰ�ȸ���');
figure(3)
stairs(x,pe_b,'-b')
hold on
stairs(x,pe_a,'--b')
hold on
stairs(x,ph_b,'-r')
hold on
stairs(x,ph_a,'--r')
title('�۸�����');
legend('��ʼ���','��ʱ���','��ʼ�ȼ�','��ʱ�ȼ�');
x=1:24;
figure(4)
plot(x,P_PV,'-m')
hold on
plot(x,P_WT,'-c')
title('���Ԥ��');
legend('���Ԥ������','���Ԥ������');

figure(5)
plot_e=[];
for t=1:24
    plot_e(1,t)=B_grid(t);%������
    plot_e(2,t)=-S_grid(t);%������
    plot_e(3,t)=P_ORC(t);%ORC����
    plot_e(4,t)=P_GT(t)*e_GT;%GT����
    plot_e(5,t)=-P_HP(t);%HP�ĵ�
    plot_e(6,t)=P_PV(t);%�������
    plot_e(7,t)=P_WT(t);%������
    plot_e(8,t)=ES_dischar(t);%ES�ŵ�
    plot_e(9,t)=-ES_char(t);%ES���
end
bar(plot_e','stacked')
xlabel('t')
ylabel('w')
title('�繦��ʹ�����');
legend('������','������','ORC����','GT����','HP�ĵ�','�������','������','ES�ŵ�','ES���');



b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
hh=value([P_WHB;P_GB;HS_dischar;COP_HP*P_HP;b]);
hh1=value([b;b;b;b;-HS_char]);
figure(6)
bar(hh','stack');
legend('CHP����','GB����','HS����','HP����','HS����');
hold on
bar(hh1','stack');
plot(x,OP_load_h,'-rs');
title('�ȸ���ƽ��');
xlabel('ʱ��');ylabel('����/kW');