function [ ] = drawCircle( x, y, r, color)
% ��Բ��x y���뾶r��Բ���ߵ���ɫΪcolor 
    leftBottomPos = [x - r, y - r, 2*r, 2*r];
    rectangle('Position',leftBottomPos,'Curvature',[1 1],'EdgeColor', color)
end

