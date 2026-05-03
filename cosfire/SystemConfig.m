function params = SystemConfig
% VERSION 09/09/2014
% CREATED BY: George Azzopardi (1), Nicola Strisciuglio (1,2), Mario Vento (2) and Nicolai Petkov (1)
%             1) University of Groningen, Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%             1) University of Salerno, Dept. of Information Eng., Electrical Eng. and Applied Math., MIVIA Lab
%
% SystemConfig returns a structure of the parameters required by the
% BCOSFIRE filter
%SystemConfig返回BCOSFIRE滤波器所需参数的结构
% Use hashtable 使用散列表
params.ht                             = 1;

% The radii list of concentric circles 同心圆的半径列表
params.COSFIRE.rholist                = 0:2:8;%（0，2，4，6，8）

% Minimum distance between dominant contours lying on the same concentric circle
%主要轮廓之间的最小距离位于同一个同心圆上
params.COSFIRE.eta                    = 150*pi/180;

% Threshold parameter used to suppress the input filters responses that are less than a
% fraction t1 of the maximum
%用于抑制输入过滤器响应的阈值参数小于最大值的分数t1
params.COSFIRE.t1                     = 0;

% Threshold parameter used to select the channels of input filters that
% produce a response larger than a fraction t2 of the maximum
%阈值参数用来选择输入滤波器的通道，其产生的响应大于最大的t2
params.COSFIRE.t2                     = 0.4;

% Parameters of the Gaussian function used to blur the input filter
% responses. sigma = sigma0 + alpha*rho_i
%这是加权高斯函数的参数
params.COSFIRE.sigma0                 = 3/6;
params.COSFIRE.alpha                  = 0.8/6;

% Parameters used for the computation of the weighted geometric mean. 
%用于计算加权几何平均值的参数。

% mintupleweight is the weight assigned to the peripherial contour parts
params.COSFIRE.mintupleweight         = 0.5;
params.COSFIRE.outputfunction         = 'geometricmean'; % geometricmean OR weightedgeometricmean 
params.COSFIRE.blurringfunction       = 'max'; %max or sum

% Weights are computed from a 1D Gaussian function. weightingsigma is the
% standard deviation of this Guassian function
%权重是从一维高斯函数计算出来的。 权重是这个高斯函数的标准偏差
params.COSFIRE.weightingsigma         = sqrt(-max(params.COSFIRE.rholist)^2/(2*log(params.COSFIRE.mintupleweight)));
%该公式用于计算高斯差分函数的标准差的


% Threshold parameter used to suppress the responses of the COSFIRE filters
% that are less than a fraction t3 of the maximum response.
%阈值参数用于抑制COSFIRE滤波器的响应小于最大响应的分数t3。
params.COSFIRE.t3                     = 0;

% % Parameters of some geometric invariances
%一些几何不变性的参数
numoriens = 12;
params.invariance.rotation.psilist    = 0:pi/numoriens:(pi)-(pi/numoriens);%psi 普西
params.invariance.scale.upsilonlist   = 2.^((0)./2);	%upsilon希腊语第20个字母 宇普西龙

% Reflection invariance about the y-axis. 0 = do not use, 1 = use.
%y轴的反射不变性。0 =不使用，1 =使用。
params.invariance.reflection          = 0;

% Minimum distance allowed between detected keypoints. If the distance
% between any two pairs of detected keypoints is less than
% params.distance.mindistance then we keep only the stronger one.
%检测到的关键点之间允许的最小距离。如果两对检测到的关键点之间的距离小于参数。距离。我们只保留较强的那一种。
params.detection.mindistance          = 8;

% Parameters of the input filter. Here we use symmetric Gabor filters.
% Gabor filters are, however, not intrinsic to the method and any other
% filters can be used.
%输入滤波器的参数。这里我们使用对称的Gabor filter。
%然而，Gabor过滤器并不是该方法的固有特性，任何其他过滤器都可以使用。
params.inputfilter.name                     = 'DoG';

params.inputfilter.Gabor.thetalist          = 0:pi/8:pi-pi/8;%角度列表
params.inputfilter.Gabor.lambdalist         = 4.*(sqrt(2).^(0:2));%lambda列表
params.inputfilter.Gabor.phaseoffset        = pi;
params.inputfilter.Gabor.halfwaverect       = 0;
params.inputfilter.Gabor.bandwidth          = 2;
params.inputfilter.Gabor.aspectratio        = 0.5;
params.inputfilter.Gabor.inhibition.method  = 1;
params.inputfilter.Gabor.inhibition.alpha   = 0;
params.inputfilter.Gabor.thinning           = 0;

%DOG滤波器的参数    
params.inputfilter.DoG.polaritylist         = [1];
params.inputfilter.DoG.sigmalist            = 2.4;
params.inputfilter.DoG.sigmaratio           = 0.5;
params.inputfilter.DoG.halfwaverect         = 0;

if strcmp(params.inputfilter.name,'Gabor')
    params.inputfilter.symmetric = ismember(params.inputfilter.Gabor.phaseoffset,[0 pi]);
elseif strcmp(params.inputfilter.name,'DoG')
    params.inputfilter.symmetric = 1;
end