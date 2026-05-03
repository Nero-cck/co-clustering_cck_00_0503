function [U1,U2] = CFCMcck(data, cluster_n, num ,respimage,M)

C = cluster_n;      %聚类数目
P =num;      %样本子集的个数
bb=0.8;
beta = bb*ones(P,P);    %参数beta，协同系数
Y=data;
X=[];
[N,d]=size(Y);
count=0;
%for num=1:1:10
%clearvars -except X Y C P N beta num count RepeatResualt;
%把原始样本划分为P个样本子集
% X{1} = Y(:,[2,1,3]);
% X{2} = Y(:,[2,3,4]);
% X{1}=Y(:,[1,3,4,5,6,7,9,10,12,13]);
% X{2}=Y(:,[1,2,3,6,7,8,9,11,12]);

for i=1:P
    X{i} = Y(:,[i]);
    L{i} = size(X{i},2);   %样本子集的维数
end

%分别对P个样本子集进行FCM聚类
for i=1:P
    [V{i},U{i},obj{i}] = fcm(X{i},C);
end

%对P个样本子集的隶属度矩阵调整顺序，使得所有子集的隶属度矩阵顺序保持一致
for a= 1:P-1
    for i = 1:C
        D = zeros(1,C);
        for j = 1:C
            D(j) = sum((U{a}(j,:) - U{a+1}(i,:)).^2);
        end
        [minvalue,index] = min(D);
        U{P+1}(index,:) = U{a+1}(i,:);
        V{P+1}(index,:) = V{a+1}(i,:);
    end
U{a+1} = U{P+1};
V{a+1} = V{P+1};
end

% aa = coefficient(U{1},U{2}, respimage, M, 5);
%     [H,W]=size(respimage);
%     m=2;
%     cNum=2;
%     winSize=3;
%     UU=reshape(U{2}',H,W, 2);
%     g =FLICM11( H, W, UU, m, cNum, winSize);
%     g = reshape(g,H*W, 2);
%     aa=g';
%     bbb(1,:)=aa(1,:)./(max(aa(1,:))-min(aa(1,:)));
%     bbb(2,:)=aa(2,:)./(max(aa(2,:))-min(aa(2,:)));
%     
%     [H,W]=size(respimage);
%     m=2;
%     cNum=2;
%     winSize=9;
%     UU=reshape(U{1}',H,W, 2);
%     g =FLICM11( H, W, UU, m, cNum, winSize);
%     g = reshape(g,H*W, 2);
%     aa=g';
%     aaa(1,:)=aa(1,:)./(max(aa(1,:))-min(aa(1,:)));
%     aaa(2,:)=aa(2,:)./(max(aa(2,:))-min(aa(2,:)));
    
%     I = respimage;
%     width=13;                 %设置窗函数的大小
%     %窗函数的位置信息
%     [neipos,wid]=fneighbor(I,width);
%     %参数初始化
%     cluster_n=2;                    %聚类类别数
%     G2=myfcmstep(neipos,wid,U{1},cluster_n,2);%调用FCM函数
% %     if(U{2}(1,1)>U{2}(2,1))
% %         aaa=G2(2,:)./(max(G2(2,:))-min(G2(2,:)));
% %     else
% %         aaa=G2(1,:)./(max(G2(1,:))-min(G2(1,:)));
% %     end
%     aaa(1,:)=G2(1,:)./(max(G2(1,:))-min(G2(1,:)));
%     aaa(2,:)=G2(2,:)./(max(G2(2,:))-min(G2(2,:)));
%     
%     I = M;
%     width=3;                 %设置窗函数的大小
%     %窗函数的位置信息
%     [neipos,wid]=fneighbor(I,width);
%     %参数初始化
%     cluster_n=2;                    %聚类类别数
%     G2=myfcmstep(neipos,wid,U{2},cluster_n,2);%调用FCM函数
% %     if(U{1}(1,1)>U{1}(2,1))
% %         bbb=G2(2,:)./(max(G2(2,:))-min(G2(2,:)));
% %     else
% %         bbb=G2(1,:)./(max(G2(1,:))-min(G2(1,:)));
% %     end
%     bbb(1,:)=G2(1,:)./(max(G2(1,:))-min(G2(1,:)));
%     bbb(2,:)=G2(2,:)./(max(G2(2,:))-min(G2(2,:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%主循环%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SSIGMA = 0;
for iteration = 1:100   
     iteration
%     k=abs(U{1}-U{2});
%     k=max(k);
%     [row col]=find(k<=0.0002);
    I = respimage;
    width=15;                 %设置窗函数的大小
    %width=15;                 %设置窗函数的大小
    [neipos,wid]=fneighbor(I,width);
        %参数初始化
    cluster_n=2;                    %聚类类别数
    G1=myfcmstep(neipos,wid,U{1},cluster_n,2);%调用FCM函数
%     aaa(1,:)=(G1(1,:)-min(G1(1,:)))./(max(G1(1,:))-min(G1(1,:)));
%     aaa(2,:)=(G1(2,:)-min(G1(2,:)))./(max(G1(2,:))-min(G1(2,:)));
%      aaa(1,:)=G1(2,:);
%      aaa(2,:)=G1(1,:);
    
    I = M;
    %width=7;                 %设置窗函数的大小
    width=7;                 %设置窗函数的大小
        %窗函数的位置信息
    [neipos,wid]=fneighbor(I,width);
    %参数初始化
    cluster_n=2;                    %聚类类别数
    G2=myfcmstep(neipos,wid,U{2},cluster_n,2);%调用FCM函数
%      bbb(1,:)=1-(G2(1,:)-min(G2(1,:)))./(max(G2(1,:))-min(G2(1,:)));
%      bbb(2,:)=1-(G2(2,:)-min(G2(2,:)))./(max(G2(2,:))-min(G2(2,:)));
%      bbb(1,:)=G2(2,:);
%      bbb(2,:)=G2(1,:);
    for ii = 1:P       
%         计算第ii个子集的隶属度矩阵
%         if(ii == 1)
%             aa=bbb;
%         else
%             aa=aaa;
%         end
        if(ii == 1)
            aa=G2;
        else
            aa=G1;
        end
        for k = 1:N
%             if find(col == k)
%                 b=0;
%             else
%                 b=1;
%             end
            for i = 1:C
                temp1 = 0;
                temp2 = 0;
                %计算FAI和PSI
                for jj = 1:P
                    if jj ~= ii
                        temp1 = temp1 + aa(i,k)*U{jj}(i,k);
                        temp2 = temp2 + aa(i,k);
                    end
                end
                %计算第一项分母
                temp3 = 0;
                for j = 1:C
                    temp3 = temp3 + (GetDistance(X{ii}(k,:),V{ii}(i,:)).^2)/(GetDistance(X{ii}(k,:),V{ii}(j,:)).^2);
                end
                %第一项分子右边项
                temp4 = 0;
                for j = 1:C
                    temp = 0;
                    for jj = 1:P
                        if jj ~= ii
                            temp = temp + aa(i,k)*U{jj}(j,k);
                        end
                    end
                    
                    temp4 = temp4 + temp/(1 + temp2);
                end
                %可以直接计算隶属度啦
                U{ii}(i,k) = temp1/(1 + temp2) + (1 - temp4)/temp3;
            end
             %归一化隶属度
            U{ii}(:,k) = U{ii}(:,k)/sum(U{ii}(:,k));   
        end
        
        %计算第ii个子集的聚类中心
        for i = 1:C
            for l = 1:L{ii}
                temp1 = 0;
                temp2 = 0;
                temp3 = 0;
                temp4 = 0;
                for k = 1:N
                    temp1 = temp1 + U{ii}(i,k)^2*X{ii}(k,l);
                    temp2 = temp2 + U{ii}(i,k)^2;
                    for jj = 1:P
                        if jj ~= ii
                            temp3 = temp3 + aa(i,k)*(U{ii}(i,k) - U{jj}(i,k))^2*X{ii}(k,l);
                            temp4 = temp4 + aa(i,k)*(U{ii}(i,k) - U{jj}(i,k))^2;
                        end
                    end
                end
                V{ii}(i,l) = (temp1 + temp3)/(temp2 + temp4);
            end
        end
        

    end 
   SIGMA(iteration) = sum(sum(abs(U{1} - U{2})))/(N*C);
   %SIGMA(iteration) = sum(sum((abs(U{1} ).^2).*(distfcm(V{1},X{1}).^2)))+sum(sum(bb.*(abs(U{1} - U{2} ).^2).*(distfcm(V{1},X{1}).^2)));    %1.6修改
    if abs(SSIGMA - SIGMA(iteration)) < 1e-5
        break;
    else
        SSIGMA = SIGMA(iteration);
    end    
end

[maxU,index] = max(U{1});
U1=U{1};
U2=U{2};
% U0=zeros(C,N);
% for i=1:120
%     U0(1,i)=1;
% end
% for i=121:150
%     U0(2,i)=1;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% U_new=zeros(C,N);
% for i=1:size(U_new,1)
%     for j=1:size(U_new,2)
%         if U(i,j)==max(U(:,j))
%             U_new(i,j)=1;
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NMI=computeNMI(U0,U_new)
%Entropy=computeEntropy(U0,U_new)
%FMeasure=computeFMeasure(U0,U_new)
%RandIndex=computeRandIndex(U0,U_new)
%count=count+1;
%RepeatResualt(count,:)=[num NMI  Entropy FMeasure RandIndex];

%save('result.dat','RepeatResualt','-ASCII')
% load('result.dat');
%LL=mean(result)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%X=X{1};
% V=V{1};
%    X1=[];
%    X2=[];
%for i=1:N
%    if index(i)==2
%        X1=[X1;X(i,:)];end
%    if index(i)==1
%        X2=[X2;X(i,:)];end

%end
%plot(X1(:,1),X1(:,2),'bo');
%hold on;
%plot(X2(:,1),X2(:,2),'r*');
%hold on;
%plot(V(:,1),V(:,2),'ks','markerfacecolor','k');
end

%% distfcm子函数
function out = distfcm(center, data)
% 计算样本点距离聚类中心的距离
% 输入：
% center ---- 聚类中心
% data ---- 样本点
% 输出：
% out ---- 距离
out = zeros(size(center, 1), size(data, 1));
for k = 1:size(center, 1) % 对每一个聚类中心
% 每一次循环求得所有样本点到一个聚类中心的距离
out(k, :) = sqrt(sum(((data-ones(size(data,1),1)*center(k,:)).^2)',1));
end
end