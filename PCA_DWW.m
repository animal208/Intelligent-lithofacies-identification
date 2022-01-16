


function [DATA_OUT] =PCA_DWW(SIGN, DATA_IN, NUM_DIM)

%% ʵ��PCA��ά����
%   ���룺
%         SIGN:PCAʵ�ַ�����־������
%         DATA_IN������ά���ݾ���M*N��MΪ������������NΪ����ά�ȣ�
%         NUM_DIM��Ŀ��ά��
%   �����
%         DATA_OUT����ά�����ݾ���


switch SIGN
    case 1
        %% ����һ��ʹ��Matlab������princomp����ʵ��PCA

         [COEFF SCORE latent]=princomp(DATA_IN);
         DATA_OUT =SCORE(:,1:NUM_DIM);   %ȡǰk�����ɷ�
    case 2
        %% ���������Ա����ʵ��PCA
        [Row Col]=size(DATA_IN);
        covX=cov(DATA_IN);                                    %��������Э�������ɢ���������(n-1)��ΪЭ�������
        [V D]=eigs(covX);                               %��Э������������ֵD����������V
        meanX=mean(DATA_IN);                                  %������ֵm
        %��������X��ȥ������ֵm���ٳ���Э�������ɢ�����󣩵���������V����Ϊ���������ɷ�SCORE
        tempX= repmat(meanX,Row,1);
        SCORE2=(DATA_IN-tempX)*V ;                             %���ɷݣ�SCORE
        DATA_OUT=SCORE2(:,1:NUM_DIM);
    case 3
        
        %% ��������ʹ�ÿ���PCA�㷨ʵ��PCA
         [DATA_OUT COEFF3] = fastPCA(DATA_IN, NUM_DIM );
end
        
        
        

















