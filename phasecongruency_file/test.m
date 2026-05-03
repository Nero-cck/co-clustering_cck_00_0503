img = imread('reference.bmp');
figure;
subplot(1,2,1);imshow(img,[]);
title('reference image');

img = rgb2gray(img);
pcMap = phasecong(img);
subplot(1,2,2);imshow(pcMap,[]);
title('phase congruency map');