%% SVM������������libsvm-3.1-[FarutoUltimate3.1Mcode]�������ڲ⾮���Ի���

% ʹ��ʱ����libsvm-3.1-[FarutoUltimate3.1Mcode]�ļ��мӵ�path·����
% ���ߣ���ά��                               2018.8.15

% ��������train.txt������BOUND.DAT��������ʽ��
% ��ʼ���  ��ֹ���  �������  ��������1  ��������2  .....

% ��������predict.txt������ZONE.DAT��������ʽ��
% ��ʼ���  ��ֹ���  1   ��������1  ��������2  .....
% predict.txt�а���train.txt����Ԥ�������а�����ѵ������

% ���룺1��sign_scale�����ݹ�һ������ѡ���־������scale����
%                     sign_scale=1���Զ�ѡȡ���������Сֵ��
%                     sign_scale=2����Ϊָ�����������Сֵ��
%                     sign_scale=3��������һ������
%                     
%       2��mindww,maxdww����Ϊָ���Ĵ���һ�����ݸ��������Сֵ������������                    
%       3��sign_drm�����ݽ�ά������ѡ���־����(dimension reduction method)��
%                     sign_drm=1��PCA��ά����
%                     sign_drm=2��FASTICA��ά����
%                     sign_drm=3��������ά����
%       4��sign_pom��c��g������ѡ����ѡ���־����(parameter optimization method)��
%                     sign_pom=1����������Ż���c��g����
%                     sign_pom=2��GA�����Ż���c��g����
%                     sign_pom=3��PSO�㷨�����Ż���c��g����
%                     sign_pom=4���˹�ѡȡ������c��g����
%       5��sign_data: ��ģ����ѡ���־������
%                     sign_data=1����ȫ���������ݷ�Ϊѵ�����ݺͲ������ݣ��ֱ����ڽ�ģ�Ͳ��ԣ�
%                     sign_data=2����ȫ���������ݶ����ڽ�ģ�����ԡ�

%     ���� [model]=svm_dww(1,0,1,[],[],3,1,1)  
%          [model]=svm_dww(2,0,1,[1 55 240 70],[20 230 600 430],3,1,1)

function [model,TYPE2]=SVM_Class_Func(labels,data,stdep,endep,data_predict,...
    sign_scale,sign_scale_save,min_scale,max_scale,mindww,maxdww,sign_drm,sign_drm_save,sign_pom,sign_pso,...
    sign_data,sign_data_save,k_fold,sign_rescale,net_option,ga_option,pso_option,cost,gamma,TYPE_name,svm_option)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                 1����������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %clear;
% fulldata_train=textread('train.txt');
% labels=fulldata_train(:,3);
% data=fulldata_train(:,4:end);%������
% 
% fulldata_predict=textread('predict.txt');
% stdep=fulldata_predict(:,1);
% endep=fulldata_predict(:,2);
% data_predict=fulldata_predict(:,4:end);%�������ݼ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2����һ��Ԥ�����������ʹ������ݼ�Ҫ������ͬ�Ĺ�һ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  ����һ���Զ�ѡȡ���������Сֵ��
if sign_scale==1
    
    [data_scale,data_predict_scale] = scaleForSVM(data,data_predict,min_scale,max_scale);
    % �����ӿڣ�[train_scale,test_scale,ps]=scaleForSVM(train_data,test_data,ymin,ymax)
    


%  ����������Ϊָ�����������Сֵ,ÿ�е������Сֵ��maxdww��mindww�������θ�����    
elseif sign_scale==2
    
    
    [data_scale]=scale_dww(data,2,min_scale,max_scale,mindww,maxdww);
    [data_predict_scale]=scale_dww(data_predict,2,min_scale,max_scale,mindww,maxdww);
    % �����ӿڣ�[data_scale]=scale_dww(data,sign,ymin,ymax,mindww,maxdww)
    
%  ������һ������
elseif sign_scale==3
    data_scale=data;
    data_predict_scale=data_predict;
else
    msgbox('sign_scale error!!!!');

end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����淶��������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sign_scale_save==1
    [mmm1 nnn1]=size(data_scale);
    [mmm2 nnn2]=size(data_predict_scale);
    fp1=fopen('data_train_scale.txt','w');
    fp2=fopen('data_predict_scale.txt','w');
    for i=1:1:mmm1
        fprintf(fp1,'%2d  ',labels(i));
        for j=1:1:nnn1
            fprintf(fp1,'%f  ',data_scale(i,j));
        end
        fprintf(fp1,'\n');
    end

    for i=1:1:mmm2
        fprintf(fp2,'%f  %f  ',stdep(i),endep(i));
        for j=1:1:nnn2
            fprintf(fp2,'%f  ',data_predict_scale(i,j));
        end
        fprintf(fp2,'\n');
    end

    fclose(fp1);
    fclose(fp2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                3����άԤ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ����һ��PCA
if sign_drm==1
    [data_drm,data_predict_drm] = pcaForSVM(data_scale,data_predict_scale,90);
    
    %�Խ�ά����������½��й�һ������
    if sign_rescale==1
        [data_drm,data_predict_drm] = scaleForSVM(data_drm,data_predict_drm,min_scale,max_scale);
    end

    % �����ӿڣ�[train_pca,test_pca] = pcaForSVM(train,test,threshold)
    % ���룺 
    %     train_data��ѵ��������ʽҪ����svmtrain��ͬ�� 
    %     test_data�����Լ�����ʽҪ����svmtrain��ͬ�� 
    %     threshold����ԭʼ�����Ľ��ͳ̶ȣ�[0��100]֮���һ������ ��ͨ������ֵ��
    %     ��ѡȡ�����ɷ֣��ò������Բ����룬Ĭ��Ϊ90����ѡȡ�����ɷ�Ĭ�Ͽ���
    %     �ﵽ��ԭʼ�����ﵽ 90%�Ľ��ͳ̶ȡ� 
    % ����� 
    %     train_pca������ pca ��άԤ������ѵ������ 
    %     test_pca������ pca ��άԤ�����Ĳ��Լ���


% ��������FASTICA
elseif sign_drm==2
    [data_drm,data_predict_drm] = fasticaForSVM(data_scale,data_predict_scale);
    
    %�Խ�ά����������½��й�һ������
    if sign_rescale==1
           [data_drm,data_predict_drm] = scaleForSVM(data_drm,data_predict_drm,min_scale,max_scale);
    end
    
%  ������ά����
elseif sign_drm==3
    data_drm=data_scale;
    data_predict_drm=data_predict_scale;

else
    msgbox('sign_drm error����������');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���潵ά���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sign_drm_save==1
    [mmm1 nnn1]=size(data_drm);
    [mmm2 nnn2]=size(data_predict_drm);
    fp1=fopen('data_train_drm.txt','w');
    fp2=fopen('data_predict_drm.txt','w');
    for i=1:1:mmm1
        fprintf(fp1,'%2d  ',labels(i));
        for j=1:1:nnn1
            fprintf(fp1,'%f  ',data_drm(i,j));
        end
        fprintf(fp1,'\n');
    end


    for i=1:1:mmm2
        fprintf(fp2,'%f  %f  ',stdep(i),endep(i));
        for j=1:1:nnn2
            fprintf(fp2,'%f  ',data_predict_drm(i,j));
        end
        fprintf(fp2,'\n');
    end

    fclose(fp1);
    fclose(fp2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4������������������飬һ�����ڲ��ԣ������������ѵ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sign_data==1      %��ȫ���������ݷ�Ϊѵ�����ݺͲ������ݣ��ֱ����ڽ�ģ�Ͳ��ԣ�
    N=length(labels);
    indices=crossvalind('Kfold',N,k_fold);
    j=1;
    k=1;
    for i=1:1:N
        if indices(i)==1
            test_labels(j)=labels(i);
            test_data(j,:)=data_drm(i,:);
            j=j+1;
        else
            train_labels(k)=labels(i);
            train_data(k,:)=data_drm(i,:);
            k=k+1;
        end
    end
    test_labels=test_labels';
    train_labels=train_labels';
%     m=length(train_labels);
%     n=length(test_labels);
%     dlmwrite('temp1.txt',train_labels);%�洢ѵ���������ݣ������Ŵ��㷨�м�����Ӧ�Ⱥ���
%     dlmwrite('temp2.txt',train_data);
    
elseif sign_data==2       %��ȫ���������ݶ����ڽ�ģ�����ԡ�
    train_labels=labels;
    test_labels=labels;
    train_data=data_drm;
    test_data=data_drm;
    
    
%     dlmwrite('temp1.txt',labels);%�洢ѵ���������ݣ������Ŵ��㷨�м�����Ӧ�Ⱥ���
%     dlmwrite('temp2.txt',data);
    
else
    msgbox('sign_data error����������');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ѵ��������PSOt_DWW�㷨����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save PSOt_DWW_data.mat train_labels train_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ѵ�����Ͳ��Լ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sign_data_save==1
    [mmm1 nnn1]=size(train_data);
    [mmm2 nnn2]=size(test_data);
    fp1=fopen('train_data.txt','w');
    fp2=fopen('test_data.txt','w');
    for i=1:1:mmm1
        fprintf(fp1,'%2d  ',train_labels(i));
        for j=1:1:nnn1
            fprintf(fp1,'%f  ',train_data(i,j));
        end
        fprintf(fp1,'\n');
    end


    for i=1:1:mmm2
        fprintf(fp2,'%2  ',test_labels(i));
        for j=1:1:nnn2
            fprintf(fp2,'%f  ',test_data(i,j));
        end
        fprintf(fp2,'\n');
    end

    fclose(fp1);
    fclose(fp2);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                5������c��g��ѡ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%  ����һ���������������Ż���c��g��

if sign_pom==1
    
    cmin=net_option.cmin;
    cmax=net_option.cmax;
    gmin=net_option.gmin;
    gmax=net_option.gmax;
    v=net_option.v;
    cstep=net_option.cstep;
    gstep=net_option.gstep;
    accstep=net_option.accstep;
    
    
    
    [bestacc,bestc,bestg]=SVMcgForClass(train_labels,train_data,cmin,cmax,...
    gmin,gmax,v,cstep,gstep,accstep,svm_option);
    
%     [bestacc,bestc,bestg]=SVMcgForClass(train_labels,train_data,-10,10,...
%     -10,10,5,1,1,4.5);


%�����ӿڣ�[bestacc,bestc,bestg]=SVMcgForClass(train_label,train,cmin,cmax,...
%           gmin,gmax,v,cstep,gstep,accstep)
%
%     ���룺 
%         train_label��ѵ�����ı�ǩ����ʽҪ���� svmtrain��ͬ�� 
%         train��ѵ��������ʽҪ����svmtrain��ͬ�� 
%         cmin��cmax���ͷ����� c �ı仯��Χ������[2^cmin��2^cmax]��Χ��Ѱ����
%         �ѵĲ��� c��Ĭ��ֵΪ cmin=-8��cmax=8����Ĭ�ϳͷ����� c �ķ�Χ��[2^(-8)��
%         2^8]�� 
%         gmin��gmax��RBF�˲��� g �ı仯��Χ������[2^gmin��2^gmax]��Χ��Ѱ��
%         ��ѵ� RBF �˲��� g��Ĭ��ֵΪ gmin=-8��gmax=8����Ĭ�� RBF �˲��� g �ķ�
%         Χ��[2^(-8)��2^8]�� 
%         v������ Cross Validation �����еĲ���������ѵ�������� v-fold Cross 
%         Validation��Ĭ��Ϊ3����Ĭ�Ͻ��� 3 �� CV ���̡� 
%         cstep��gstep�����в���Ѱ���� c �� g �Ĳ�����С���� c ��ȡֵΪ 2^cmin��
%         2^(cmin+cstep)�� ���� 2^cmax�� �� g ��ȡֵΪ 2^gmin�� 2^(gmin+gstep)�� ���� 2^gmax��
%         Ĭ��ȡֵΪ cstep=1��gstep=1�� 
%         accstep�� ������ѡ����ͼ��׼ȷ����ɢ����ʾ�Ĳ��������С ��[0�� 100]
%         ֮���һ��������Ĭ��Ϊ4.5�� 
%      ����� 
%         bestCVaccuracy������CV�����µ���ѷ���׼ȷ�ʡ� 
%         bestc����ѵĲ���c�� 
%         bestg����ѵĲ���g��


%%  ��������GA�㷨�����Ż���c��g��

elseif sign_pom==2
    

%     ga_option.maxgen = 100;
%     ga_option.sizepop = 20; 
%     ga_option.pCrossover = 0.4;
%     ga_option.pMutation = 0.01;
%     ga_option.cbound = [0.1,100];
%     ga_option.gbound = [0.1,100];
%     ga_option.v = 10;  
%     ga_option.ggap = 0.9;
 
    [bestacc,bestc,bestg,ga_option]= gaSVMcgForClass(train_labels,train_data,ga_option,svm_option);
 

%�����ӿڣ�[bestCVaccuracy,bestc,bestg,ga_option]= gaSVMcgForClass(train_label,
%           train,ga_option) 
%
%         ���룺 
%             train_label��ѵ�����ı�ǩ����ʽҪ����svmtrain��ͬ�� 
%             train��ѵ��������ʽҪ����svmtrain��ͬ�� 
%             ga_option��GA�е�һЩ�������ã��ɲ����룬��Ĭ��ֵ����ϸ�뿴����İ���˵����
%          
%         ����� 
%             bestCVaccuracy������ CV�����µ���ѷ���׼ȷ�ʡ� 
%             bestc����ѵĲ���c�� 
%             bestg����ѵĲ���g�� 
%             ga_option����¼ GA�е�һЩ������
%
%         ga_option�����ṹ�壺
%             maxgen:���Ľ�������,Ĭ��Ϊ100,һ��ȡֵ��ΧΪ[100,500]
%             sizepop:��Ⱥ�������,Ĭ��Ϊ20,һ��ȡֵ��ΧΪ[20,100]
%             pCrossover:�������,Ĭ��Ϊ0.4,һ��ȡֵ��ΧΪ[0.4,0.99]
%             pMutation:�������,Ĭ��Ϊ0.01,һ��ȡֵ��ΧΪ[0.001,0.1]
%             cbound = [cmin,cmax],����c�ı仯��Χ,Ĭ��Ϊ[0.1,100]
%             gbound = [gmin,gmax],����g�ı仯��Χ,Ĭ��Ϊ[0.01,1000]
%             v:SVM Cross Validation����,Ĭ��Ϊ3

 

%%  ��������PSO�㷨�����Ż���c��g��

elseif sign_pom==3

%     pso_option.c1 = 1.5;
%     pso_option.c2 = 1.7;
%     pso_option.maxgen = 100;
%     pso_option.sizepop = 20;
%     pso_option.k = 0.6;
%     pso_option.wV = 1;
%     pso_option.wP = 1;
%     pso_option.v = 3;
%     pso_option.popcmax = 100;
%     pso_option.popcmin = 0.1;
%     pso_option.popgmax = 100;
%     pso_option.popgmin = 0.1;
    
    if sign_pso==0
        [bestacc,bestc,bestg] = psoSVMcgForClass(train_labels,train_data,pso_option,svm_option);
    else
        h=figure;
        chgicon(h,'2.jpg');  % ����ͼ��
        set(h,'name','����Ⱥ��̬�ֲ�','Numbertitle','off');        
        c_range=[pso_option.popcmin,pso_option.popcmax];
        g_range=[pso_option.popgmin,pso_option.popgmax];
        range = [c_range;g_range];
        Max_V = 0.2*(range(:,2)-range(:,1));  %����ٶ�ȡ��Χ��10%~20%
        n=2;
        psoparams=[1 pso_option.maxgen pso_option.sizepop 2 2 0.9 0.4 1500 1e-8 250 NaN 0 0];
        
        out=pso_Trelea_vectorized('PSOt_DWW_func',n,Max_V,range,1,psoparams);
        bestc=out(1);
        bestg=out(2);
    end
        



%   �����ӿڣ�[bestCVaccuracy,bestc,bestg,pso_option]= psoSVMcgForClass(train_label,...
%             train,pso_option) 
%     ���룺 
%          train_label��ѵ�����ı�ǩ����ʽҪ����svmtrain��ͬ�� 
%          train��ѵ��������ʽҪ����svmtrain��ͬ�� 
%          pso_option��PSO �е�һЩ�������ã��ɲ����룬��Ĭ��ֵ����ϸ�뿴����İ���˵����
%      
%     ����� 
%          bestCVaccuracy������ CV�����µ���ѷ���׼ȷ�ʡ� 
%          bestc����ѵĲ���c�� 
%          bestg����ѵĲ���g��
%          pso_option����¼ PSO�е�һЩ������
%
%     pso_option�����ṹ�壺
%          c1:��ʼΪ1.5,pso�����ֲ���������
%          c2:��ʼΪ1.7,pso����ȫ����������
%          maxgen:��ʼΪ200,����������
%          sizepop:��ʼΪ20,��Ⱥ�������
%          k:��ʼΪ0.6(k belongs to [0.1,1.0]),���ʺ�x�Ĺ�ϵ(V = kX)
%          wV:��ʼΪ1(wV best belongs to [0.8,1.2]),���ʸ��¹�ʽ���ٶ�ǰ��ĵ���ϵ��
%          wP:��ʼΪ1,��Ⱥ���¹�ʽ���ٶ�ǰ��ĵ���ϵ��
%          v:��ʼΪ3,SVM Cross Validation����
%          popcmax:��ʼΪ100,SVM ����c�ı仯�����ֵ.
%          popcmin:��ʼΪ0.1,SVM ����c�ı仯����Сֵ.
%          popgmax:��ʼΪ1000,SVM ����g�ı仯�����ֵ.
%          popgmin:��ʼΪ0.01,SVM ����c�ı仯����Сֵ.



%% �����ģ��˹�ѡȡ������c��g��

elseif sign_pom==4
    bestc=cost;
    bestg=gamma;
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%             6����ģ�����Լ�����Ԥ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



svm_type=num2str(svm_option.svm_type);
kernel_type=num2str(svm_option.kernel_type);
degree=num2str(svm_option.degree);
coef0=num2str(svm_option.coef0);
nu=num2str(svm_option.nu);
epsilon=num2str(svm_option.epsilon);
cachesize=num2str(svm_option.cachesize);
eps=num2str(svm_option.eps);
weight=num2str(svm_option.weight);
shrinking=num2str(svm_option.shrinking);
probability_estimates=num2str(svm_option.probability_estimates);

%  ��ģ

cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg),' -s ',svm_type,' -t ',kernel_type,' -d ',degree,' -r ',coef0,' -n ',nu,' -p ',epsilon,' -m ',cachesize,' -e ',eps,' -wi ',weight,' -h ',shrinking,' -b ',probability_estimates];
%    cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg),' -s ',svm_type,' -t ',kernel_type];
% cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];


model = svmtrain(train_labels, train_data,cmd);
% assignin('base','model',model)
%  ����
fprintf('����:');
[train_predict_labels, train_accuracy] = svmpredict(train_labels, train_data, model);
% train_accuracy(1)

%  ����
fprintf('����:');
[test_predict_labels, test_accuracy] = svmpredict(test_labels, test_data, model);
% test_accuracy(1)

%  Ԥ��
fprintf('Ԥ��:\n');
for i=1:1:20
    unknown_labels=ones(length(stdep),1)*i;
    fprintf('%2d:',i);[predict_labels] = svmpredict(unknown_labels, data_predict_drm, model);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%���������ֵ�����н��
%%%%%%%%%%%%%%%%%%%%%%%%%



for i=1:1:20
    count(i)=0;
end

mm=length(stdep);
for i=1:1:mm
    for j=1:1:20
        if predict_labels(i)==j
            count(j)=count(j)+1;
        end 
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         7�����ݵ�������������������ļ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fp=fopen('SVM_identification_results.txt','w');
rlev=0.125;
nn=(endep(end)-stdep(1))/rlev+1;
dep=stdep(1):rlev:endep(end);


type1='TYP1, TYP2, TYP3, TYP4, TYP5, TYP6, TYP7, TYP8, TYP9, TY10, TY11, TY12, TY13, TY14, TY15, TY16, TY17, TY18, TY19, TY20, TYPC'; 
type2='DEPTH       TYP1    TYP2     TYP3     TYP4     TYP5     TYP6     TYP7     TYP8     TYP9     TY10';        
type3='TY11     TY12     TY13     TY14     TY15     TY16     TY17     TY18     TY19     TY20     TYPC';
fprintf(fp,'%s\n',type1);
fprintf(fp,'%s   %s\n',type2,type3);

for i=1:1:nn
    for j=1:1:20
        TYPE1(i,j)=0;
    end
end
for i=1:1:nn
    for j=1:1:length(stdep)
        if dep(i)>=stdep(j)&&dep(i)<endep(j)
            TYPE1(i,predict_labels(j))=predict_labels(j);
        end
    end
end

typc=sum(TYPE1')';
TYPE2(:,1)=dep;
TYPE2(:,2:21)=TYPE1;
TYPE2(:,22)=typc;


for i=1:1:nn
    fprintf(fp,'%7.3f   %6.3f   %6.3f   %6.3f   %6.3f    %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f  %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f   %6.3f\n',TYPE2(i,:));
end


fclose(fp);



end


