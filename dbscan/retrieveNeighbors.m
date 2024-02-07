function [ neighbors ] = retrieveNeighbors( data, currentIndex, eps1, eps2, clusterLabel)
%��������ֱ���ܶȿɴ�㣨ֻ���ǿռ䲻�������ԣ�
x = data(currentIndex, 1);
y = data(currentIndex, 2);
t1 = data(currentIndex, 3);

neighbors = [];
for i=1:length(data)
    % �����Χ�㻹û�б�ǹ������Ѿ����Ϊ��ǰ�ػ�������������������Ч�ĵ�
    if (data(i, 4) ==0 || data(i, 4) == clusterLabel || data(i,4)==-1  ) && i ~= currentIndex
        dis1 = sqrt((data(i, 1) - x)^2 + (data(i, 2) - y)^2);
        dis2 = abs(data(i, 3) - t1);
        if dis1 <= eps1 && dis2 <= eps2
            neighbors = [neighbors, i];
        end
    else
        continue ;
    end
end

end

