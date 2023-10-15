%% ̼���׻����¿���������Ӧ���ۺ���Դϵͳ�Ż����С���κ��
%���� 2: ̼���׻����¿���������Ӧ
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

%% ����ඨ�����
Z=zeros(24,24); %�����Ծ���
e_W1=0.5;e_W2=0.3;e_W3=0.15;e_W4=0.05;%Լ�����̶�����ת�ơ������������������ռ��50%��30%��15%��5% %�������4. 2. 2 ������Ӧ�����ȷ���
h_W1=0.5;h_W2=0.2;h_W3=0.2;h_W4=0.1;%Լ�����̶�����ת�ơ������������������ռ��50%��30%��15%��5%  %�������4. 2. 2 ������Ӧ�����ȷ���
Psl_e=zeros(1,24);%ת�Ƶ縺����
Pcl_e=zeros(1,24);%�����縺����
Prl_e=zeros(1,24);%�縺�ɱ������
Psl_h=zeros(1,24);%ת���ȸ�����
Pcl_h=zeros(1,24);%�����ȸ�����
Prl_h=zeros(1,24);%�ȸ��ɱ������
P2H=1.83; %��ת��ϵ��
OP_load_e=zeros(1,24);%�Ż���ĵ縺��
OP_load_h=zeros(1,24);%�Ż�����ȸ���
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
%% DR-�������Ӧ�Ż�
Z_e=ElasticityMatrix(pe_a); %��������Ծ���
Z_e_CL=diag(diag(Z_e)); %�����縺�ɵ��Ծ���,�Խ���
Z_e_SL=Z_e-Z_e_CL; %ת�Ƶ縺�ɵ��Ծ���

Z_h=ElasticityMatrix(ph_a); %�ȼ������Ծ���
Z_h_CL=diag(diag(Z_h)); %�����ȸ��ɵ��Ծ���,�Խ���
Z_h_SL=Z_h-Z_h_CL; %ת���ȸ��ɵ��Ծ���

%�۸���������Ӧ
[Psl_e,Pcl_e]=IBDR(Z_e_SL,Z_e_CL,load_e,pe_a,pe_b,e_W2,e_W3);%��ת�Ƶ縺�ɵ��Ծ��������縺�ɵ��Ծ��󣬳�ʼ�縺�ɣ�������Ӧ��ۣ�������Ӧǰ��ۣ���ת�Ƶ縺�ɱ������������縺�ɱ�����
[Psl_h,Pcl_h]=IBDR(Z_h_SL,Z_h_CL,load_h,ph_a,ph_b,h_W2,h_W3);%��ת���ȸ��ɵ��Ծ��������ȸ��ɵ��Ծ��󣬳�ʼ�ȸ��ɣ�������Ӧ�ȼۣ�������Ӧǰ�ȼۣ���ת���ȸ��ɱ������������ȸ��ɱ�����
%�����������Ӧ
[Prl_e,Prl_h]=RBDR(pe_a,ph_a,e_W4,h_W4);%��������Ӧ��ۣ�������Ӧ�ȼۣ�������縺��ռ�ȣ�������ȸ���ռ�ȣ�

OP_load_e=load_e+Psl_e+Pcl_e-Prl_e+Prl_h/P2H;%�Ż���ĵ縺�ɣ���ʼ�縺�ɣ�ת�Ƶ縺�ɣ������縺�ɣ��縺�ɱ���������ȸ��ɱ��������
OP_load_h=load_h+Psl_h+Pcl_h-Prl_h+Prl_e*P2H;%�Ż�����ȸ��ɣ���ʼ�ȸ��ɣ�ת���ȸ��ɣ������ȸ��ɣ��ȸ��ɱ���������縺�ɱ��������
%%  IES��Ӧ�ഢ��Լ��     
ES_start=80;
HS_start=50;  %�索�ܺ��ȴ��ܵĳ�ʼ����
for i=1:24
    ES(1,i)=ES_start+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %�����ʼ����Լ��
    ES_start=ES(1,i);
end
for i=1:23
    ES(1,i+1)= ES(1,i)*(1-ES_loss)+ES_char(1,i)*ES_c_char-ES_dischar(1,i)/ES_c_discharge; %��������Լ��
end
ES_start=ES(1,24);

for i=1:24
    EH(1,i)=HS_start+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %���ȳ�ʼ����Լ��
    HS_start=EH(1,i);
end
for i=1:23
    EH(1,i+1)= EH(1,i)*(1-HS_loss)+HS_char(1,i)*HS_c_char-HS_dischar(1,i)/HS_c_discharge; %��������Լ��
end
HS_start=EH(1,24);

%% IES��Ӧ���Ż�
% Լ������
C=[];
%%�索���豸����Լ��
 for i=1:24  %����Լ��
     C=[C,0<=ES_char(1,i)<=250*ES_char_sign(1,i)];
     C=[C,0<=ES_dischar(1,i)<=250*(1-ES_char_sign(1,i))];
 end
 
 for i=1:24 %����Լ��
     C=[C,0<=ES(1,i)<=400];
 end
     
 %�ȴ����豸����Լ��
 for i=1:24  %����Լ��
     C=[C,0<=HS_char(1,i)<=250*HS_char_sign(1,i)];
     C=[C,0<=HS_dischar(1,i)<=250*(1-HS_char_sign(1,i))];
 end
 for i=1:24 %����Լ��
     C=[C,0<=EH(1,i)<=400];
 end
     
 a=0.5; %�������4. 2. 3 GT ���ȷ��������Ӱ��
%��������Լ��
for i=1:24   
    C = [C,0<=P_GT(i)<=4000];%ȼ���ֻ�������Լ��
    C = [C,0<=P_GB(i)<=1000];%ȼ����¯������Լ�� 
    C = [C,0<=P_HP(i)<400];%�ȱ�������Լ��
    C = [C,0<=P_ORC(i)<=400];%ORC������Լ��
    C = [C,P_GT(i)*h_GT*r_WHB*a<=P_WHB(i)];%���Ȼ��շ��乫ʽ��aΪ����ϵ��
    C = [C,P_GT(i)*h_GT*r_ORC*(1-a)<=P_ORC(i)];
    
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
%�������룬��Ӧ�࿼���û���������Ӧʱ�ᱻ���뾭�ò����Թ����������
Income=pe_a*OP_load_e'+ph_a*OP_load_h'+6000; %���û���������
%����ϵͳ��ά�ɱ������۳ɱ���̼���׳ɱ��������ֹ��ɳɱ�
% RIES��ά�ɱ�
GT=0.04;%ȼ���ֻ���λ��ά�ɱ�
WHB=0.025;%���ȹ�¯��λ��ά�ɱ�
HP=0.025;%�ȱõ�λ��ά�ɱ�
PV=0.016;%�����λ��ά�ɱ�
WT=0.018;%�����λ��ά�ɱ�
ES=0.018;%�索�ܵ�λ��ά�ɱ�
HS=0.016;%�ȴ��ܵ�λ��ά�ɱ�
C_om=0;%��ά�ɱ�
for i=1:24
C_om=C_om+P_GT(i)*GT+P_WHB(i)*WHB++P_HP(i)*HP+P_WT(i)*WT+P_PV(i)*PV+ES*(ES_char(1,i)+ES_dischar(1,i))+HS*(HS_char(1,i)+HS_dischar(1,i));
end

H_gas=9.88;%��Ȼ����ֵ
C_buy=0;%���ܳɱ�
for i=1:24
C_buy=C_buy+B_grid(i)*price_buy_grid(i)-S_grid(i)*price_sell_grid(i)+2.55*(P_GT(i)/e_GT/H_gas+P_GB(i)/h_GB/H_gas);                              
end

C_carbon_trade=0;%̼���׳ɱ�
PP=2.53;%����������ϵ��
for i=1:24
C_carbon_trade=C_carbon_trade+0.5*(0.57-0.6101)*(PP*e_GT*P_GT(i)+h_GT*P_GT(i)+P_GB(i)); %0.50yuan/t
%�������4. 2. 4 ̼���׼۸��ϵͳ���е�Ӱ��                             
end


%Ŀ�꺯��

f=C_om+C_buy+C_carbon_trade;
op = sdpsettings('solver','cplex', 'verbose', 0);

optimize(C,f,op)
CC=value(f) %�ܳɱ�
F=Income-CC%����
om=value(C_om);
grid=value(C_buy);
car=value(C_carbon_trade);
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

b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
ee=value([B_grid;ES_dischar;(e_GT*P_GT+P_ORC);P_WT;P_PV;b;b]);
ee1=value([b;b;b;b;b;-ES_char;-P_HP;-S_grid]);
figure(5)
bar(ee','stack');
legend('������','ES�ŵ�','CHP����','������','�������','ES���','HP�ĵ�','������');
hold on
bar(ee1','stack');
plot(x,OP_load_e,'-gs');
title('�縺��ƽ��');
xlabel('ʱ��');ylabel('����/kW');


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

  