function [acc,sn,sp,F1,MCC]=evolution(img,Ans,mask)
if nargin < 3
    tp = sum(img == 1 & Ans == 1 );
    fn = sum(img == 0 & Ans == 1 );
    tn = sum(img == 0 & Ans == 0 );
    fp = sum(img == 1 & Ans == 0 );
    acc= (tp+tn)/(tp+fn+tn+fp);
    sn = tp/(tp+fn);
    sp = tn/(tn+fp);
else
    mask(mask == 255) = 1;
    tp = sum(img == 1 & Ans == 1 & mask == 1);
    fn = sum(img == 0 & Ans == 1 & mask == 1);
    tn = sum(img == 0 & Ans == 0 & mask == 1);
    fp = sum(img == 1 & Ans == 0 & mask == 1);
    acc= (tp+tn)/(tp+fn+tn+fp);
    sn = tp/(tp+fn);
    sp = tn/(tn+fp);
    F1 = (2*tp)/(2*tp+fp+fn);
    MCC = (tp.*tn-fp.*fn)/((tp+fp).*(tp+fn).*(tn+fp).*(tn+fn)).^0.5;
end
