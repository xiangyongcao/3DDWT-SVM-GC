function [data, label] = ChooseArea(Data,Label,Row_index,Col_index)

data = Data(Row_index,Col_index,:);
label = Label(Row_index,Col_index);
% % subplot(1,2,2); imagesc(label); axis image; colorbar
% [m, n] = size(label);
% ind = ones(m,n);
% data = Tensor2matrix(data,ind);
% label = label';
% label = label(:);

