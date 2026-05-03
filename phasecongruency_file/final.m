function [ out_img ] = final(img, features,cluster_n ,respimage,M)
%[ out_img ] = final( features )
%featuers是特征向量组
%%cfcm和fcm聚类
     [U1,U2] = CFCMcck(features, cluster_n, 2 ,respimage,M);
    % [~, U, ~] =fcm(features, cluster_n);
[R,C]=size(img);
% count=1;
% if(U1(1,584)>U1(2,584))
%     a=0;
%     b=255;
%  else
%      a=255;                                                                 
%     b=0;
%  end
% for i=1:C
%     for j=1:R
%        
%       if(U1(1,count)>U1(2,count))
%          out_img1 (i,j)=a;
%       else
%           out_img1 (i,j)=b;
%       end
%       count=count+1;
%     end
% end
%  count=1;
% if(U2(1,584)>U2(2,584))
%     a=0;
%     b=255;
%  else
%      a=255;                                                                 
%     b=0;
%  end
% for i=1:C
%     for j=1:R
%        
%       if(U2(1,count)>U2(2,count))
%          out_img2 (i,j)=a;
%       else
%           out_img2 (i,j)=b;
%       end
%       count=count+1;
%     end
% end
%  out_img= out_img1 | out_img2;
%  
U = sqrt(U1.*U2);

% Adaptive vessel cluster selection with polarity self-check.
prior = mat2gray(double(respimage)) * 0.6 + mat2gray(double(M)) * 0.4;
priorVec = prior(:);
vesselScore = U * priorVec;
[~, vesselCls] = max(vesselScore);

if vesselCls == 1
    vesselMask = reshape(U(1,:)>U(2,:), size(respimage));
else
    vesselMask = reshape(U(2,:)>U(1,:), size(respimage));
end

% Polarity correction: vessels should align with higher structural prior.
fgScore = mean(prior(vesselMask));
bgScore = mean(prior(~vesselMask));
if fgScore < bgScore
    vesselMask = ~vesselMask;
end

out_img = uint8(vesselMask) * 255;

%% kmeans
% U = kmeans(features, cluster_n);
% [R,C]=size(img);
% count=1;
% if(U(584) == 1)
%     a=0;
%     b=255;
%  else
%      a=255;                                                                 
%     b=0;
%  end
% for i=1:C
%     for j=1:R
%       if(U(count) == 1)
%          out_img (i,j)=a;
%       else
%           out_img (i,j)=b;
%       end
%       count=count+1;
%     end
% end


% figure,imshow(out_img );title('FCM结果图');


end