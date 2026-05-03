function bb = coefficient(U1,U2, respimage, M, N)

[m,n] = size(respimage);
aa=reshape(U2(1,:),m,n);
cc=reshape(U2(2,:),m,n);
mm = m-N;
nn = n-N;

a1 = h(aa, m, n, N ,mm ,nn);
a2 = h(cc, m, n, N ,mm ,nn);
g1 = gg(M, m, n, N ,mm ,nn,a1);
g2 = gg(M, m, n, N ,mm ,nn,a2);


% aa(isnan(aa))=0;
[r,c]=size(aa); 
n=r.*c;
bb=reshape(aa,1,n);

end

function a = gg(aa, m, n, N ,mm ,nn,a)
for k = 1:1:m
    for j = 1:1:n
        if  ( k < mm ) && ( j < nn  ) && ( k > (N-1)/2 ) && ( j > (N-1)/2 )           
            Block1 = aa(k-(N-1)/2:k+(N-1)/2,j-(N-1)/2:j+(N-1)/2);%需要对Block处理的下面可以操作
            Block2 = a(k-(N-1)/2:k+(N-1)/2,j-(N-1)/2:j+(N-1)/2);
            h=0;
            for o = 1:1:N
                for p = 1:1:N
                    if (o == (N-1)/2 ) && (p == (N-1)/2 ) 
                        continue
                    end
                    h = h + Block2(o,p)*1/(1+o*o+p*p);
                end
            end
            a(k,j)=h;
         else
            a(k,j)=0;
        end
    end
end
end

function a = h(aa, m, n, N ,mm ,nn)
for k = 1:1:m
    for j = 1:1:n
        if  ( k < mm ) && ( j < nn  ) && ( k > (N-1)/2 ) && ( j > (N-1)/2 )           
            Block1 = aa(k-(N-1)/2:k+(N-1)/2,j-(N-1)/2:j+(N-1)/2);%需要对Block处理的下面可以操作
            h=0;
            for o = 1:1:N
                for p = 1:1:N
                    if (o == (N-1)/2 ) && (p == (N-1)/2 ) 
                        continue
                    end
                    h = h+(1-Block1(o,p))^2;
                end
            end
            a(k,j)=h;
         else
            a(k,j)=0;
        end
    end
end
end