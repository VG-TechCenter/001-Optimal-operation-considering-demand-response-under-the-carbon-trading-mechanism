function [Prl_e,Prl_h]=RBDR(pe_a,ph_a,e_W4,h_W4)

%�����������Ӧ
%�����²�ͬ��ת����ɱ��ϵͷ��ɷ������
P2H=1.83; %��ת��ϵ��
%��ȡ����
shuju=xlsread('carbon+DR����.xlsx'); %��һ�컮��Ϊ24Сʱ
load_e=shuju(2,:); %��ʼ�縺��
load_h=shuju(3,:); %��ʼ�ȸ���
Prl_e=zeros(1,24);%�縺�ɱ������
Prl_h=zeros(1,24);%�ȸ��ɱ������
for i=1:24
    if pe_a(i)<P2H*ph_a(i)  %ת����۸�ɱ��ϵ����滻
      Prl_e(i)=0;
    else
      Prl_e(i)=e_W4*load_e(i);
    end
end
for i=1:24
    if pe_a(i)/P2H<ph_a(i) %ת����۸�ɱ��ϵ����滻
      Prl_h(i)=0;
    else
      Prl_h(i)=h_W4*load_h(i);
    end
end