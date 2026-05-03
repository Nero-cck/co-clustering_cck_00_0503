function [output, oriensmap] = Bcosfire_stare(img)
% Delineation of blood vessels in retinal images based on combination of BCOSFIRE filter responses
%
% Version:      v1.3 
% Author(s):    Nicola Strisciuglio (nic.strisciuglio@gmail.com)
%               George Azzopardi
% 
% Description:
% Example application for the B-COSFIRE filters for delineation of
% elongated structures in images. This example demonstrates how to
% configure different types of filters (line and line-ending detectors) and
% how to combine their responses. 
%b - cosfire过滤器的示例应用程序，用于描述图像中的细长结构。
%这个例子演示了如何配置不同类型的过滤器(线和线结束检测器)以及如何组合它们的响应
%
% Application() returns:
%      output       A struct that contains the BCOSFIRE filters response
%                   and the final segmented image. In details
%                       - output.respimage: response of the combination of a symmetric and an
%                         asymemtric COSFIRE filters
%                       - output.segmented: the binary output image after
%                         thresholding 阈值后的二进制输出图像
%      oriensmap    [optional] map of the orientation that gives the strongest 
%                   response at each pixel. 
%                   在每个像素中给出最强响应的方向图。
% If you use this software please cite the following paper:
%
% "George Azzopardi, Nicola Strisciuglio, Mario Vento, Nicolai Petkov, 
% Trainable COSFIRE filters for vessel delineation with application to retinal images, 
% Medical Image Analysis, Volume 19 , Issue 1 , 46 - 57, ISSN 1361-8415
%

% Requires the compiling of the mex-file for the fast implementation of the
% max-blurring function in case it is not compiled already
%为了快速实现最大模糊功能，需要编译mex文件，以防已经编译过


if ~exist('./cosfire/COSFIRE/dilate')
    BeforeUsing();
end


% Example with an image from DRIVE data set
%来自DRIVE数据集的图像示例
image = double(img) ./ 255;%对图片进行归一化

%专门写出来是为了测试数据方便，原文有介绍对于stare数据库用几个参数需要修改
%% Symmetric filter params   
symmfilter = struct();
symmfilter.sigma     = 2.4;
symmfilter.len       = 12;
symmfilter.sigma0    = 1;
symmfilter.alpha     = 0.3;

%% Asymmetric filter params
asymmfilter = struct();
asymmfilter.sigma     = 1.8;
asymmfilter.len       = 24;
asymmfilter.sigma0    = 1;
asymmfilter.alpha     = 0.1;

%% Filters responses
% Tresholds values
% DRIVE -> preprocessthresh = 0.5, thresh = 37
% STARE -> preprocessthresh = 0.5, thresh = 40
% CHASE_DB1 -> preprocessthresh = 0.1, thresh = 38
output = struct();
if nargout == 1 || nargout == 0
    [output.respimage] = BCOSFIRE_media15(image, symmfilter, asymmfilter, 0.5);
elseif nargout == 2
    [output.respimage, oriensmap] = BCOSFIRE_media15(image, symmfilter, asymmfilter, 0.5);
else
    error('ERROR: too many output arguments.');
end

output.segmented = (output.respimage > 37);

if nargout == 0
    figure; imagesc(output.respimage); colormap(gray); axis off; axis image; title('B-COSFIRE response image');
    figure; imagesc(output.segmented); colormap(gray); axis off; axis image; title('B-COSFIRE segmented image');
end