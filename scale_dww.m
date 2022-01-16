%% ���ݹ�һ������
% ���ߣ�weiwu dong                     2020.12.7
% �Ծ���data�ġ����С����й�һ������
% ����˵����
%         1��data��data_scale����һ��ǰ������ݾ���
%         2��sign=1���Զ�ѡȡ���������Сֵ��
%            sign=2����Ϊָ�����������Сֵ,ÿ�е����
%                    ��Сֵ��maxdww��mindww�������θ�����
%         3�����ݹ�һ����Χ��[ymin,ymax].




function [data_scale]=scale_dww(data,sign,ymin,ymax,mindww,maxdww)


%%
if sign==1
    data_min=min(data);
    data_max=max(data);
elseif sign==2
    data_min=mindww;
    data_max=maxdww;
else
    error('sign error!!!!\n')
end

%%
[n,m]=size(data);
for j=1:1:m
    for i=1:1:n
        data_temp(i,j)=(data(i,j)-data_min(j))/(data_max(j)-data_min(j));
        if data_temp(i,j)<0
           data_temp(i,j)=0;
        end
        if data_temp(i,j)>1
           data_temp(i,j)=1;
        end
        
        data_scale(i,j)=(ymax-ymin)*data_temp(i,j)+ymin;
        if data_scale(i,j)<ymin
           data_scale(i,j)=ymin;
        end
        if data_scale(i,j)>ymax
           data_scale(i,j)=ymax;
        end
    end 
end


end





