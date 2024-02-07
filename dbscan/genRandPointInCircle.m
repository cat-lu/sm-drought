function [ pt ] = genRandPointInCircle( x, y, radius, num, t1)
% ����x y ΪԲ�ģ�radiusΪ�뾶��Բ������num������� �ǿռ�����ȫ������Ϊt1
% ÿ�����ݽṹ���£�
% pt(x, y, t1, cluster_label, type)
% x, y: position
% t1 : non-spatial data
% cluster_label :������ 0:NAN  -1:noise  1~N ��ͨ�Ĵر��
rrand = radius * rand(num, 1);
rtheta = 180 * rand(num, 1);
pt = zeros(num, 4);
pt(:, 1) = x + rrand .* sin(rtheta);
pt(:, 2) = y + rrand .* cos(rtheta);
pt(:, 3) = t1;
pt(:, 4) = 0;
end

