function Y = Matrix2tensor(X,m,n)
% X -- input matrix: mn x B
% Y -- output tensor: m x n x B

[N, B] = size(X);   % N = m x n

% Y = zeros(m,n,B);
% l = 0;
% for i = 1:m
%     for j = 1:n
%         if ind(i,j)~=0
%             l = l + 1;
%             tmp = X(l,:);
%             
%         end
%         Y(i,j,:) = tmp;
%     end
% end
Y = reshape(X,m,n,B);