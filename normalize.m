function X = normalize(img,mask)
usedpixels = double(img(mask~=0));%FOV内的像素
minValue = min(usedpixels);%求出FOV内的像素的平均值
maxValue= max(usedpixels);  %std(x)算出x的标准偏差
usedpixels = (usedpixels - minValue) /(maxValue - minValue);
img(mask~=0)=usedpixels;
X=img;