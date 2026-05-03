function [U1,U2] = CFCMcck(data, cluster_n, num ,respimage,M)

C = cluster_n;
P = num;
Y = double(data);
[N,~] = size(Y);

X = cell(1,P);
L = cell(1,P);
U = cell(1,P+1);
V = cell(1,P+1);

for i = 1:P
    X{i} = Y(:,i);
    L{i} = size(X{i},2);
end

for i = 1:P
    [V{i},U{i},~] = fcm(X{i},C);
end

% Align cluster order among subspaces.
for a = 1:P-1
    for i = 1:C
        D = zeros(1,C);
        for j = 1:C
            D(j) = sum((U{a}(j,:) - U{a+1}(i,:)).^2);
        end
        [~,index] = min(D);
        U{P+1}(index,:) = U{a+1}(i,:);
        V{P+1}(index,:) = V{a+1}(i,:);
    end
    U{a+1} = U{P+1};
    V{a+1} = V{P+1};
end

SSIGMA = 0;
for iteration = 1:100
    I = respimage;
    [neipos,wid] = fneighbor(I,15);
    G1 = myfcmstep(neipos,wid,U{1},2,2);

    I = M;
    [neipos,wid] = fneighbor(I,7);
    G2 = myfcmstep(neipos,wid,U{2},2,2);

    for ii = 1:P
        if ii == 1
            aa = G2;
        else
            aa = G1;
        end

        % Aggregate memberships from other subspaces.
        otherU = zeros(C,N);
        for jj = 1:P
            if jj ~= ii
                otherU = otherU + U{jj};
            end
        end

        temp2Mat = (P - 1) * aa;
        temp1Mat = aa .* otherU;

        % Distance matrix: C x N.
        Xii = X{ii}';
        Vii = V{ii};
        dist2 = zeros(C,N);
        for ci = 1:C
            delta = Xii - Vii(ci,:)';
            dist2(ci,:) = sum(delta.^2,1);
        end
        dist2 = max(dist2, eps);
        temp3Mat = dist2 .* sum(1 ./ dist2, 1);

        temp4Base = sum(otherU,1);
        temp4Mat = (aa ./ (1 + temp2Mat)) .* temp4Base;

        Uii = temp1Mat ./ (1 + temp2Mat) + (1 - temp4Mat) ./ temp3Mat;
        Uii = max(Uii, eps);
        Uii = Uii ./ max(sum(Uii,1), eps);
        U{ii} = Uii;

        % Update cluster centers.
        penalty = zeros(C,N);
        for jj = 1:P
            if jj ~= ii
                penalty = penalty + aa .* (U{ii} - U{jj}).^2;
            end
        end

        WV = U{ii}.^2 + penalty;
        denom = max(sum(WV,2), eps);

        for l = 1:L{ii}
            xrow = X{ii}(:,l)';
            V{ii}(:,l) = sum(WV .* xrow,2) ./ denom;
        end
    end

    SIGMA(iteration) = sum(sum(abs(U{1} - U{2})))/(N*C);
    if abs(SSIGMA - SIGMA(iteration)) < 1e-5
        break;
    else
        SSIGMA = SIGMA(iteration);
    end
end

U1 = U{1};
U2 = U{2};
end
