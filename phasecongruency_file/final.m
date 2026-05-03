function [ out_img ] = final(img, features,cluster_n ,respimage,M, params)
%[ out_img ] = final( features )
     if nargin < 6
    params = struct();
end
[U1,U2] = CFCMcck(features, cluster_n, 2 ,respimage,M, params);
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

  count=1;
if(U(1,584)>U(2,584))
    a=0;
    b=255;
 else
     a=255;                                                                 
    b=0;
 end
for i=1:C
    for j=1:R
       
      if(U(1,count)>U(2,count))
         out_img (i,j)=a;
      else
          out_img (i,j)=b;
      end
      count=count+1;
    end
end
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


out_img =out_img';
% figure,imshow(out_img );title('FCM结果图');


end