bb = imcrop(respimage,[240 515 8 8]);figure;imshow(bb)
cc = imcrop(M,[240 515 8 8]);figure;imshow(cc)
bbb=bb-mean(mean(bb))*ones(15);
ccc=cc-mean(mean(cc))*ones(15);
mean(mean(aaa))




N=7;
[m,n] = size(I);
mm = m-N;
nn = n-N;
for i = 1:1:mm
    for j = 1:1:nn
        Block1 = respimage(i:i+N,j:j+N);%需要对Block处理的下面可以操作
        Block2 = M(i:i+N,j:j+N);
        a(i,j)=mean(mean(corr(Block1,Block2)));
       if(((i+N) >= m)||((j+N) >= n))
          break;
       end
    end
end


