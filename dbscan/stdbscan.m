%% ����ģ�����ݣ��粻��Ҫ����ģ��������ע�ͱ��� ST-DBSCAN
clc;clear;
POINT_NUM = 100;     % ģ�������ܵ���
NOISE_POINT_NUM = 5; % ģ����������
pt1 = genRandPointInCircle(0, 0, 1, POINT_NUM/4, 1);
pt2 = genRandPointInCircle(0, 2, 2, POINT_NUM/2, 4);
pt3 = genRandPointInCircle(-4, 0, 1, POINT_NUM/4 - NOISE_POINT_NUM, 3);
pt4 = genRandPointInCircle(0, 0, 6, NOISE_POINT_NUM, 2);
D = [pt1; pt2; pt3; pt4];

%% ������� eps1 eps2 minpts ����
EPS1 = 1;
EPS2 = 1.2;
MINPTS = 5;
DELTA_E = 1.1;

%% ST-DBSCAN��ʼ
clusterLabelColor = ['r', 'g', 'c', 'b'];
clf;                % �������figure
clusterLabel = 0;   % ��ʼ���ر��
for i=1:length(D(:, 1))                                             	%(i)
    if D(i, 4) == 0    %�õ�û�б�����������Ǻ��ĵ��������            %(ii)
        X = retrieveNeighbors(D, i, EPS1, EPS2, 0);                 	%(iii)
        if length(X) < MINPTS  %�����������Ǻ��ĵ�
            D(i, 4) = -1;                                               %(iv)
%             showCluster(D, EPS1, clusterLabelColor);
        else                                        % construct a new cluster(v)
            clusterLabel = clusterLabel + 1;
            clusterItem = D(i, 3);       % ���ڵ������ֵΪ��ǰ���ĵ�����ֵ
            D(i ,4) = clusterLabel;     %�����ĵ���
            queue = i;        %�����ĵ�������                                         %(vi)
            
            while isempty(queue) == 0
                ptCurrent = queue(1);  % ���в��� pop
                queue(1) = [];        
                Y = retrieveNeighbors(D, ptCurrent, EPS1, EPS2, clusterLabel);
                
                if length(Y) >= MINPTS   %�����еĵ�ǰ��Ҳ�Ǻ��ĵ�
                    for j=1:length(Y)                                       %(vii)
                        % |Cluter_Ave() - o.value| < e
                        %�жϵ�ǰ����ھ��Ƿ������У�����/δ����ĵ�+���ԣ��ھ�һ�����Ͽռ�������
                        if ((D(Y(j), 4) == -1) || (D(Y(j), 4) == 0)) && abs(mean(clusterItem) - D(Y(j), 3)) < DELTA_E
                            D(Y(j), 4) = clusterLabel;          % mark o with current cluster label
                            clusterItem = [clusterItem, D(Y(j), 3)];
                            queue = [queue, Y(j)] ;             % ���в��� push
%                             showCluster(D, EPS1, clusterLabelColor);
                        end
                    end
                else % �����еĵ��Ǳ߽�㣬���¼��к�������������ͬ���Ѳ���core object�ĵ���Ϊ�߽�һ��������У������ټ�����չ
                    D(ptCurrent, 4) = clusterLabel;
                    clusterItem = [clusterItem, D(ptCurrent, 3)];
                    %showCluster(D, EPS1, clusterLabelColor);
                end
            end
        end
    end
end

showCluster(D, EPS1, clusterLabelColor);


