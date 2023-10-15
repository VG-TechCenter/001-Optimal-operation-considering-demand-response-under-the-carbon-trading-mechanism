function [Z]=ElasticityMatrix(P)
%%%总：用户需求弹性矩阵（分：根据文章分成SL型需求弹性矩阵，CL型需求弹性矩阵（对角阵））
%时段  %谷   %平    %峰
%低   -0.1   0.01   0.012
%平   0.01   -0.1   0.016
%峰   0.012  0.016  -0.1  %%数据来源《需求侧响应理论模型与应用研究_曾鸣》
%构造需求弹性矩阵
for i=1:24
    if P(i)==min(P)%谷
        for j=1:24
           if P(j)==min(P)%低  
               Z(i,j)=-0.1; 
           elseif P(j)==max(P)%峰
               Z(i,j)=0.012;
           elseif min(P)<P(j)<max(P)%平 
               Z(i,j)=0.01;
           else%平
               Z(i,j)=0.01;
           end
        end
    elseif P(i)==max(P)%峰
        for j=1:24
           if P(j)==min(P)%低 
               Z(i,j)=0.012; 
            elseif P(j)==max(P)%峰
                Z(i,j)=-0.1;
           elseif min(P)<P(j)< max(P)%平
               Z(i,j)=0.016;
           else%平
               Z(i,j)=0.016;
           end
        end
    else%平
         for j=1:24
           if P(j)==min(P)%低  
               Z(i,j)=0.01; 
            elseif P(j)==max(P)%峰  
                Z(i,j)=0.016;
            elseif min(P)<P(j)< max(P)%平
                Z(i,j)=-0.1;
           else%平 
                Z(i,j)=-0.1;
           end
         end  
    end
end  