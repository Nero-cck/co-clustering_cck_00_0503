tic
% MATLAB uses lowercase logical literals.
% Define aliases so accidental Python-style True/False won't break runs.
True = true; %#ok<NASGU>
False = false; %#ok<NASGU>

%将需要调用的文件添加到路径
addpath(genpath('co-clustering_cck_file')); 
addpath(genpath('cosfire')); 
addpath(genpath('phasecongruency_file')); 
addpath(genpath('result_file')); 

for i=7:7
%% 提取图像
disp(['STARE',num2str(i,'%02d')]);
img0 = imread(['STARE\images\',num2str(i,'%02d'),'.ppm']);
mask = im2uint8(createretinamaskcolored(img0));
man = imread(['STARE\ah\',num2str(i,'%02d'),'.ah.ppm']);

%% 预处理
img_pre = preProcessing(img0,mask);
%img_pre(mask_pre == 0) =0;

%% 特征提取

%% B-cosfire
RGBimg=img0;
[output, ~] = Bcosfire_stare(RGBimg);
output.respimage(mask==0)=0;
respimage=normalize(output.respimage,mask);
[r,c]=size(respimage);
n=r.*c;
 respimage1=reshape(respimage,1,n);
% figure,
% imshow(respimage,[]);title('Bcosfier');

params = struct();
params.lambda_cont = 0.12;
params.lambda_branch = 0.02;
params.use_auto_lambda = false;
if params.use_auto_lambda
    [params.lambda_cont, params.lambda_branch, stats] = generate_cocluster_lambdas(img_pre, respimage, M, mask);
    disp(['auto lambda | lc=', num2str(params.lambda_cont, '%.4f'), ...
          ' lb=', num2str(params.lambda_branch, '%.4f'), ...
          ' | C=', num2str(stats.C, '%.4f'), ' N=', num2str(stats.N, '%.4f'), ...
          ' V=', num2str(stats.V, '%.4f'), ' B=', num2str(stats.B, '%.4f')]);
end
out_img = final(img_pre,features,cluster_n,respimage,M, params);
%img_fake = fakepad(double(img_pre),mask_pre);
[M, ~ , ~ , ~ , ~, ~]=phasecong_stare(img_pre);
M(mask==0)=0;
M=normalize(M,mask);
[r,c]=size(M);
n=r.*c;
M1=reshape(M,1,n);
% figure,
% imshow(M);title('相位一致性');

features=[respimage1;M1]';

 %% 聚类
 %特征融合
features=double(features);
cluster_n =2;
out_img = final(img_pre,features,cluster_n,respimage,M);
 
%% 后处理
bw2_img = renovesmallarea(out_img,20,4);
bw2_img(mask==0)=0;
figure,
subplot(121);imshow(bw2_img);
subplot(122);imshow(man);


%% 性能测试

    man(man==255) = 1;
    mask(mask~=0) = 1;
   [acc(i),sn(i),sp(i),F1(i),MCC(i)]=evolution(bw2_img,man,mask);
    %[acc(i),sn(i),sp(i)]=evolution(bw2_img,man,mask);
end
toc
save('result_file\STARE\data\performance_stare.mat','acc','sn','sp');
ii=7;
disp(['平均准确度：',num2str(acc(ii))]);
disp(['平均灵敏度：',num2str(sn(ii))]);
disp(['平均特异性：',num2str(sp(ii))]);
disp(['平均F1度量：',num2str(F1(ii))]);
disp(['平均MCC：',num2str(MCC(ii))]);
disp(['平均准确度：',num2str(mean(acc))]);
disp(['平均灵敏度：',num2str(mean(sn))]);
disp(['平均特异性：',num2str(mean(sp))]);
disp(['平均F1度量：',num2str(mean(F1))]);
disp(['平均MCC：',num2str(mean(MCC))]);
