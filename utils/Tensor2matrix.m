function X = Tensor2matrix(Y)
% Y -- input tensor: m x n x B
% ind -- indicator matrix: m x n
% X -- output matrix: mn x B
[m, n, B] = size(Y);
% if nargin<2
%     ind = ones(m,n);
% end
% NonZeroNum = length(find(ind~=0));
% X = zeros(NonZeroNum,B);
% l = 0;
% for i = 1:m
%     for j = 1:n
%         if ind(i,j)~=0
%             l = l + 1;
%             tmp = Y(i,j,:);
%         end
%         X(l,:) = tmp(:);
%     end
% end
X = reshape(Y,m*n,B);
