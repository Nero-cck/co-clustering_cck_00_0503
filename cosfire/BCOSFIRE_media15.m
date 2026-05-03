function [resp,oriensmap] = BCOSFIRE_media15(image, filter1, filter2, preprocessthresh)
% Delineation of blood vessels in retinal images based on combination of BCOSFIRE filters responses.
%
% VERSION 02/09/2016
% CREATED BY: George Azzopardi (1), Nicola Strisciuglio (1,2), Mario Vento (2) and Nicolai Petkov (1)
%             1) University of Groningen, Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%             1) University of Salerno, Dept. of Information Eng., Electrical Eng. and Applied Math., MIVIA Lab
%
%   If you use this script please cite the following paper:
%   [1] "George Azzopardi, Nicola Strisciuglio, Mario Vento, Nicolai Petkov, 
%   Trainable COSFIRE filters for vessel delineation with application to retinal images, 
%   Medical Image Analysis, Volume 19 , Issue 1 , 46 - 57, ISSN 1361-8415, 
%   http://dx.doi.org/10.1016/j.media.2014.08.002"
% 
%   BCOSFIRE_media15 achieves orientation selectivity by combining the output - at certain 
%   positions with respect to the center of the COSFIRE filter - of center-on 
%   difference of Gaussians (DoG) functions by a  geometric mean. 
%   BCOSFIRE_media15通过将相对于COSFIRE滤波器中心的某些位置的输出与
%   几何平均值的高斯（DoG）函数的中心偏差相结合来实现方位选择性。
%   BCOSFIRE_media15 takes as input:
%      image -> RGB retinal fundus image
%      filter1 -> a struct defining the configuration parameters of the
%                 symmetric filter: 一个定义对称滤波器配置参数的结构                  
%                   Name                Value
%                   'sigma'             Value of the standard deviation of
%                                       the outer Gaussian funciton in the DoG
%                   'len'               The length of the filter support
%                   'sigma0'            Value of the standard deviation of
%                                       the Gaussian weigthing function
%                   'alpha'             Alpha coefficient of the weighting
%                                       function
%      filter2 -> a struct defining the configuration parameters of the
%                 asymmetric filter:   一个定义非对称滤波器配置参数的结构                 
%                   Name                Value
%                   'sigma'             Value of the standard deviation of
%                                       the outer Gaussian funciton in the DoG
%                                       DoG中外部高斯函数的标准偏差的值
%                   'len'               The length of the filter support
%                                       滤波器支持的长度
%                   'sigma0'            Value of the standard deviation of
%                                       the Gaussian weigthing function
%                   'alpha'             Alpha coefficient of the weighting
%                                       function
%      preprocessthresh -> a threshold value used in the preprocessing step
%                          (must be a float value in [0, 1])在预处理步骤中使用的阈值
%      thresh -> threshold value used to threshold the final filter
%                response (must be an integer value in [0, 255])
%用于阈值最终过滤器响应的阈值（必须是[0,255]中的整数值）
%
%   BCOSFIRE returns:
%      resp         -> response of the combination of a symmetric and an
%                   asymemtric COSFIRE filters
%     一个对称和一个不对称COSFIRE滤波器组合的响应
%      oriensmap    -> map of the orientation that gives the strongest 
%                   response for each pixel. 
%      为每个像素提供最强响应的方向图
%   The ouput parameter 'oriensmap' is optional. In case it is not
%   输出参数'oriensmap'是可选的，该算法提供了如[1]中所述的响应图像，
%   required, the algorithm provides a response image as described in [1].
%   On the contrary, the response image is computed by first summing up the
%   symmetric and asymmetric B-COSFIRE filter responses at each
%   orientation, and then superimposing such responses to achieve rotation
%   invariance. In this case, the orientation map, with information
%   about the orientation that gives the strongest response at every pixel,
%   is provided as output.
%相反，通过首先在每个方向上总结对称和不对称B-COSFIRE滤波器响应，然后叠加这样的响应以实现旋转不变性来计算响应图像。
%在这种情况下，定向贴图将提供有关在每个像素处提供最强响应的方向的信息作为输出
%   Examples: [resp] = BCOSFIRE(imread('01_test.tif'), f1, f2, 0.5, 38);
%             [resp oriensmap] = BCOSFIRE(imread('01_test.tif'), f1, f2, 0.5, 38);
%
%   The image 01_test.tif is taken from the DRIVE data set, which can be 
%   downloaded from: http://www.isi.uu.nl/Research/Databases/DRIVE/

%path(path,'./Gabor/');
path(path,'./COSFIRE/');
%path(path,'./Performance/');

%% Model configuration
% Prototype pattern 原型模式
x = 101; y = 101; % center中心
line1(:, :) = zeros(201);
line1(:, x) = 1; %prototype line

% Symmetric filter params对称滤波参数
symmfilter = cell(1);
symm_params = SystemConfig;%调用symm_params参数
% COSFIRE params
symm_params.inputfilter.DoG.sigmalist = filter1.sigma;%输入的DoG的尺度列表
symm_params.COSFIRE.rholist = 0:2:filter1.len;
symm_params.COSFIRE.sigma0 = filter1.sigma0 / 6;
symm_params.COSFIRE.alpha = filter1.alpha / 6;
% Orientations %对称的方向
numoriens = 12;
symm_params.invariance.rotation.psilist = 0:pi/numoriens:pi-pi/numoriens;%角度
% Configuration
symmfilter{1} = configureCOSFIRE(line1, round([y x]), symm_params);%line1是原型模式, round([y x])对y和x取整
% Show the structure of the COSFIRE filter
% showCOSFIREstructure(symmfilter);

% Asymmetric filter params
asymmfilter = cell(1);
asymm_params = SystemConfig;
% COSFIRE params
asymm_params.inputfilter.DoG.sigmalist = filter2.sigma;
asymm_params.COSFIRE.rholist = 0:2:filter2.len;
asymm_params.COSFIRE.sigma0 = filter2.sigma0 / 6;
asymm_params.COSFIRE.alpha = filter2.alpha / 6;
% Orientations%非对称的方向
numoriens = 24;
asymm_params.invariance.rotation.psilist = 0:2*pi/numoriens:(2*pi)-(2*pi/numoriens);
% Configuration
asymmfilter{1} = configureCOSFIRE(line1, round([y x]), asymm_params);
asymmfilter{1}.tuples(:, asymmfilter{1}.tuples(4,:) > pi) = []; % Deletion of on side of the filter
%删除滤波器的一面
% Show the structure of the COSFIRE operator
% showCOSFIREstructure(asymmfilter);

%% Filtering
[image,mask] = preprocess(image, [], preprocessthresh);
image = 1 - image;%图像取反

% Apply the symmetric B-COSFIRE to the input image
%将对称B-COSFIRE应用于输入图像
rot1 = applyCOSFIRE(image, symmfilter);

%将非对称B-COSFIRE应用于输入图像
rot2 = applyCOSFIRE(image, asymmfilter);

if nargout == 1 %输出参数只有一个
    % The code as presented in the paper 代码在论文中提出
    rot1 = max(rot1{1},[],3);
    rot2 = max(rot2{1},[],3);
    resp = rot1 + rot2;
elseif nargout == 2    %输出参数有两个
    % Modified code to also give the orientation map as output
    %修改后的代码也可以将方向图作为输出
    for i = 1:size(rot1{1},3)
        resp(:,:,i) = rot1{1}(:, :, i) + max(rot2{1}(:,:,i),rot2{1}(:,:,i+12));    
    end
    [resp,oriensmap] = max(resp, [], 3);
    oriensmap = symm_params.invariance.rotation.psilist(oriensmap);
    oriensmap = oriensmap .* mask;
end

resp = rescaleImage(resp .* mask, 0, 255);
