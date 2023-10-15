function [Psl,Pcl]=IBDR(Z_SL,Z_CL,load,p_a,p_b,W2,W3)
Psl=zeros(1,24);%����������
Pcl=zeros(1,24); %ת�Ƹ�����
%�۸���������Ӧ
for i=1:24
    sum1=0;
    for j=1:24
    sum1=sum1+(Z_SL(i,j)*((p_a(j)-p_b(j))/p_b(j))); %��ת��ϵ��
    end
    Psl(i)=W2*load(i)*sum1;
end
 
for i=1:24
    sum2=0;
    for j=1:24
    sum2=sum2+(Z_CL(i,j)*((p_a(j)-p_b(j))/p_b(j))); %������ϵ��
    end
    if sum2>0 
    sum2=0; %���������ڼ۸����ǵ�ʱ��
    else
    Pcl(i)=W3*load(i)*sum2;
    end
end