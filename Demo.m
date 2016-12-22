% Demo of 3DDWT-SVM-GC
tic;
clear;clc;

currentFolder = pwd;
addpath(genpath(currentFolder))

%load data
load('Indian_pines_corrected.mat');
load('Indian_pines_gt.mat')

Data = indian_pines_corrected;
Data = dwt3d_feature(Data); 
Data = double(Data);
Label = indian_pines_gt;
clear indian_pines_corrected indian_pines_gt;

%% Choose Area
m1 = 1; n1 = 145; m2 = 1; n2 = 145;
Row_index = m1:n1; Col_index = m2:n2;
[Data,Label] = ChooseArea(Data,Label,Row_index,Col_index);

[H, W, B] = size(Data);
imagesize = H * W; % Size of the image or the number of pixels
nPixels = H * W;
ind_clas = unique(Label(:));
ind_clas = double(ind_clas);
ind_clas(1) = [];
nclasses = length(ind_clas);
disp(['There are ',num2str(nclasses),' classes in total.']);

Num = zeros(1,nclasses);
for k = 1:nclasses
   Num(k) = length(find(Label==ind_clas(k))); 
end
disp(['The num of each class is ']);
Num'

% method 1: given the number for each class
n = 15*ones(1,nclasses);  % number of pixels taken for each class

% method 2: given the proportion for each class
% alpha = 0.05*ones(1,nclasses);
% n = ceil(Num.*alpha);

% Scaling the image where the max & the min values are 1 and -1 respectively
% Data_scaled = 2*(Data - min(Data(:)))/(max(Data(:)) - min(Data(:)))-1;
Data_scaled = Data;
data_M = Tensor2matrix(Data);
fea = data_M;
label = Label(:);

% Divide data
[~, ~, ~, ~, ~, ~, ~, ~,TrainIndex,TestIndex] = DataDivide(Data_scaled,Label,n);
nTest = length(TestIndex);

TrainData = fea(TrainIndex,:);
TrainLabels = label(TrainIndex);
TestData = fea(TestIndex,:);
TestLabels = label(TestIndex);
MapData = reshape(Data_scaled,H*W,B);
MapLabels = double(ones(H*W,1));

TrainingMap = zeros(H,W);
TrainingMap(TrainIndex) = TrainLabels;
TestMap = Label - TrainingMap;

% SVM classification
% cross validation
% [bestacc,bestc,bestg] = SVMcg(TrainLabels, TrainData,-4,4,-4,4,3,0.5,0.5,0.9);
% cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg),' -b 1'];

cmd = ['-c ',num2str(50),' -g ',num2str(0.04),' -b 1'];

% svmtrain on training data
model = svmtrain(TrainLabels, TrainData, cmd);

% svmpredict on test data
[predict_label, accuracy, prob_estimates] = svmpredict(TestLabels, TestData, model, '-b 1');

predict_label = bestMap(TestLabels,predict_label);

Predict_label = Label;
Predict_label(TestIndex) = predict_label;

% svm is using the mapdata from the original scaled image and the model created
[predict_labelM, accuracyM, prob_estimatesM] = svmpredict(MapLabels, MapData, model, '-b 1');
predict_labelM2D = reshape(predict_labelM,H,W);%reshaping the labeling in a H*W matrix

% reshaping the probablities of pixels(in H*W*9) for the 9 classes as breadth.
prob_estimatesM2 = reshape(prob_estimatesM,H,W,nclasses);

%% GraphCut
GClabels = graphcutmethod(Data_scaled,Label,prob_estimatesM);

seg_label = GClabels(TestIndex) + 1;
seg_label = bestMap(TestLabels,seg_label);
Seg_label = Label;
Seg_label(TestIndex) = seg_label;

%% Compute accuracy
[CSaccuracy_GC,CSaccuracy,OA,AA,OA_GC,AA_GC,kappa,kappa_GC,SegMap] = computeAccuracy(nclasses,predict_label,...
    TestMap,ind_clas,GClabels,Predict_label,Label,TestLabels,nTest);

% data statistics
Total_Num = zeros(nclasses,3);
Total_Num(:,1) = Num';
Total_Num(:,2) = n';
Total_Num(:,3) = (Num - n)';
disp(['The summary of the data is '])
Total_Num

% accuracy
Acc_Specific = zeros(nclasses,2);
Acc_Specific(:,1) = CSaccuracy;
Acc_Specific(:,2) = CSaccuracy_GC;
disp(['Accuracy for each class is']);
Acc_Specific

OA_AA_kappa = zeros(2,3);
OA_AA_kappa(1,:) = [OA,AA,kappa];
OA_AA_kappa(2,:) = [OA_GC,AA_GC,kappa_GC];
disp(['Overall Accuracy, Average Accuracy and Kappa coefficient are']);
OA_AA_kappa

%% image show
figure; subplot(1,5,1); 
imagesc(Label);axis image;set(gca,'xtick',[],'ytick',[]);title('Groundtruth Map');

subplot(1,5,2);
imagesc(TrainingMap);axis image;set(gca,'xtick',[],'ytick',[]);title('Training Map');

subplot(1,5,3);
imagesc(TestMap);axis image; set(gca,'xtick',[],'ytick',[]);title('Test Map');

subplot(1,5,4);
imagesc(Predict_label);axis image;set(gca,'xtick',[],'ytick',[]);
accuracy(1) = accuracy(1)/100;
st = sprintf('The classification OA = %2.2f', accuracy(1));title(st,'Fontsize', 10);

% subplot(1,6,5); 
% imagesc(GClabels); axis image; set(gca,'xtick',[],'ytick',[]);title('GClabels');

subplot(1,5,5); 
imagesc(Seg_label); axis image; set(gca,'xtick',[],'ytick',[]);
st = sprintf('The segmentation OA = %2.2f', OA_GC);title(st,'Fontsize', 10);

time = toc;
disp(['Elapsed time is ',num2str(time)]);


