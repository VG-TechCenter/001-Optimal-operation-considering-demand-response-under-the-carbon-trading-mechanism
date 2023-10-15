function [Z]=ElasticityMatrix(P)
%%%�ܣ��û������Ծ��󣨷֣��������·ֳ�SL�������Ծ���CL�������Ծ��󣨶Խ��󣩣�
%ʱ��  %��   %ƽ    %��
%��   -0.1   0.01   0.012
%ƽ   0.01   -0.1   0.016
%��   0.012  0.016  -0.1  %%������Դ���������Ӧ����ģ����Ӧ���о�_������
%���������Ծ���
for i=1:24
    if P(i)==min(P)%��
        for j=1:24
           if P(j)==min(P)%��  
               Z(i,j)=-0.1; 
           elseif P(j)==max(P)%��
               Z(i,j)=0.012;
           elseif min(P)<P(j)<max(P)%ƽ 
               Z(i,j)=0.01;
           else%ƽ
               Z(i,j)=0.01;
           end
        end
    elseif P(i)==max(P)%��
        for j=1:24
           if P(j)==min(P)%�� 
               Z(i,j)=0.012; 
            elseif P(j)==max(P)%��
                Z(i,j)=-0.1;
           elseif min(P)<P(j)< max(P)%ƽ
               Z(i,j)=0.016;
           else%ƽ
               Z(i,j)=0.016;
           end
        end
    else%ƽ
         for j=1:24
           if P(j)==min(P)%��  
               Z(i,j)=0.01; 
            elseif P(j)==max(P)%��  
                Z(i,j)=0.016;
            elseif min(P)<P(j)< max(P)%ƽ
                Z(i,j)=-0.1;
           else%ƽ 
                Z(i,j)=-0.1;
           end
         end  
    end
end  