tic
%将需要调用的文件添加到路径
 addpath(genpath('co-clustering_cck_file')); 
 addpath(genpath('cosfire')); 
 addpath(genpath('phasecongruency_file')); 
 addpath(genpath('result_file')); 

for i=1:1
%% 提取图像
disp(['DRIVE test',num2str(i,'%02d')]);
img0 = imread(['DRIVE\test\images\',num2str(i,'%02d'),'_test.tif']);
mask = imread(['DRIVE\test\mask\',num2str(i,'%02d'),'_test_mask.gif']);
man = imread(['DRIVE\test\2nd_manual\',num2str(i,'%02d'),'_manual2.gif']);

% 确保 man 是灰度图像
if size(man,3) == 3
    man = rgb2gray(man);
end

%% 预处理
[img_pre,mask] = preProcessing(img0,mask);
% img_pre(mask_pre == 0) =0;

%% 特征提取

%% B-cosfire
RGBimg=img0;
[output, ~] = Bcosfire(RGBimg);
output.respimage(mask==0)=0;
respimage=normalize(output.respimage,mask);
% respimage=output.respimage;
[r,c]=size(respimage);
n=r.*c;
respimage1=reshape(respimage,1,n);
% figure,
% imshow(respimage,[]);title('Bcosfier');

%% 相位一致性
% img_fake = fakepad(img_pre,mask_pre);
[M, ~ , ~ , ~ , ~, ~]=phasecong(img_pre);
M(mask==0)=0;
M=normalize(M,mask);
[r,c]=size(M); 
n=r.*c;
M1=reshape(M,1,n);
% figure,
% imshow(M);title('相位一致性');

% N=5;
% [m,n] = size(img_pre);
% mm = m-N;
% nn = n-N;
% for k = 1:1:m
%     for j = 1:1:n
%         if  ( k < mm ) && ( j < nn  ) && ( k > (N-1)/2 ) && ( j > (N-1)/2 )           
%             Block1 = respimage(k-(N-1)/2:k+(N-1)/2,j-(N-1)/2:j+(N-1)/2);%需要对Block处理的下面可以操作
%             Block2 = M(k-(N-1)/2:k+(N-1)/2,j-(N-1)/2:j+(N-1)/2);
%             a(k,j)=mean(mean(corr(Block1,Block2)));
%             if a(k,j)<0
%                 a(k,j) = -a(k,j);
%             end
%          else
%             a(k,j)=0;
%         end
%     end
% end
% a(isnan(a))=0;
% [r,c]=size(a); 
% n=r.*c; 
% aa=reshape(a,1,n);

features=[respimage1;M1]';

 %% 聚类
 %特征融合
features=double(features);
cluster_n =2;
out_img = final(img_pre,features,cluster_n ,respimage,M);
 
%% 后处理
bw2_img = renovesmallarea(out_img,20,4);
bw2_img(mask==0)=0;
figure,
subplot(121);imshow(bw2_img);
subplot(122);imshow(man, []);  % 原来是 imshow(man);


%% 性能测试

%% 性能评估
man_eval = man;
man_eval(man_eval==255) = 1;
mask_eval = mask;
mask_eval(mask_eval~=0) = 1;
[acc(i),sn(i),sp(i),F1(i),MCC(i)]=evolution(bw2_img,man_eval,mask_eval);
end
toc
save('result_file\Drive\Drive1\performance.mat','acc','sn','sp');
%%ii=3;
disp(['平均准确度：',num2str(acc(1))]);
disp(['平均灵敏度：',num2str(sn(1))]);
disp(['平均特异性：',num2str(sp(1))]);
disp(['平均F1度量：',num2str(F1(1))]);
disp(['平均MCC：',num2str(MCC(1))]);
disp(['平均准确度：',num2str(mean(acc))]);
disp(['平均灵敏度：',num2str(mean(sn))]);
disp(['平均特异性：',num2str(mean(sp))]);
disp(['平均F1度量：',num2str(mean(F1))]);
disp(['平均MCC：',num2str(mean(MCC))]);

