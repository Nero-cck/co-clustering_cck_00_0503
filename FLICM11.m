function g =FLICM11( H, W, U, m, cNum, winSize )
%input 
%   image:0-255的double型
%output 
%   U:维度为(H,W,cNum)，0-1的double型
sStep = (winSize-1)/2; %局部窗口半径
Uold=U;%Uold下面要用
d1=zeros(cNum,1);%d1为公式（17）中的G_ki
    for i=1:H
        for j=1:W
            for k=1:cNum
                sSum=eps(0);%重置sSum
                for ii=-sStep:sStep %sStep是窗口半径，ii和jj是对局部区域计算
                    for jj=-sStep:sStep
                        x=i+ii;
                        y=j+jj;
                        dist=sqrt((x-i)^2+(y-j)^2);%局部区域中，点（x,y）和点（i,j）的距离
                        if(x >= 1 && x <= H && y >= 1 && y <= W && (ii ~= 0 || jj ~= 0))%（x,y）不能超过边界，也不能与（i,j）重合
                            sSum=sSum+1.0/(1.0+dist)*(1-Uold(x,y,k).^m);%距第k个聚类中心的距离
                        end
                    end
                end
                d1(i,j,k)=sSum;%d1为公式（17）中的G_ki
            end
%             d1(d1==0)=eps(0);%接近于0的极小值
        end
    end

g=d1;


%函数结束
end