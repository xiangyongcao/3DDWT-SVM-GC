function [CSaccuracy_GC,CSaccuracy,OA,AA,OA_GC,AA_GC,kappa,kappa_GC,SegMap] = computeAccuracy(nclasses,predict_label,...
    TestMap,ind_clas,GClabels,Predict_label,Label,TestLabels,nTest)

[H, W] = size(TestMap);

%% compute accuracy
CSaccuracy_GC = zeros(nclasses,1);
confmatrix_GC = zeros(nclasses,nclasses);
nTestPerClass = zeros(nclasses,1);
AA_GC = 0; OA_GC = 0;

CSaccuracy = zeros(nclasses,1);
confmatrix = zeros(nclasses,nclasses);
AA = 0; OA = 0;

seg_label = zeros(size(predict_label));
i = 0;
for ind_height = 1:H
    for ind_width = 1:W
        if (TestMap(ind_height, ind_width) > 0)% for the testmap if the pixel belongs to any class 1-9
            i = i + 1;
            tmp = TestMap(ind_height, ind_width);
            trueclass = find(tmp==ind_clas);       % then trueclass represents the orignal class of the pixel
            nTestPerClass(trueclass) = nTestPerClass(trueclass) + 1;%testperclass is incremented for that class
            seg_label(i) = GClabels(ind_height, ind_width);
            confmatrix_GC(trueclass, GClabels(ind_height, ind_width)) = confmatrix_GC(trueclass, GClabels(ind_height, ind_width)) + 1;% in the same way the confmatric_Gc is also incremented for that particular true class ,with main motivation of checking with respect to the graph cut labeling
            tmp1 = Predict_label(ind_height, ind_width);
            predictclass = find(tmp1==ind_clas);
            confmatrix(trueclass, predictclass) = confmatrix(trueclass, predictclass) + 1;%similarly as above,with main motivation of checking with respect to the svm predicted labeling           
        end
    end
end

seg_label = bestMap(TestLabels,seg_label);

SegMap = Label;
SegMap = SegMap';
TestMap = TestMap';
% SegMap(TestIndex) = seg_label;

SegMap(find(TestMap>0)) = seg_label;
SegMap = SegMap';
SegMap = reshape(SegMap,H,W);
TestMap = TestMap';

for ind_class = 1:nclasses
    CSaccuracy_GC(ind_class) = double(confmatrix_GC(ind_class, ind_class))/double(nTestPerClass(ind_class));%normalized diagonal values are extracted for graph-cut class accuracy measurements
    OA_GC = OA_GC + double(confmatrix_GC(ind_class, ind_class));
    AA_GC = AA_GC + CSaccuracy_GC(ind_class);
    
    CSaccuracy(ind_class) = double(confmatrix(ind_class, ind_class))/double(nTestPerClass(ind_class));%normalized diagonal values are extracted for prediction class accuracy measurements
    OA = OA + double(confmatrix(ind_class, ind_class));
    AA = AA + CSaccuracy(ind_class);
end

OA = OA/double(nTest);%overall accuracy of the prediction approach is estimated
AA = AA/double(nclasses);%average accuracy of the prediction approach is estimated

OA_GC = OA_GC/double(nTest);%overall accuracy of the graphcut approach is estimated
AA_GC = AA_GC/double(nclasses);%average accuracy of the graphcut approach is estimated

kappa = (sum(confmatrix(:))*sum(diag(confmatrix)) - sum(confmatrix)*sum(confmatrix,2))...
    /(sum(confmatrix(:))^2 -  sum(confmatrix)*sum(confmatrix,2));

kappa_GC = (sum(confmatrix_GC(:))*sum(diag(confmatrix_GC)) - sum(confmatrix_GC)*sum(confmatrix_GC,2))...
    /(sum(confmatrix_GC(:))^2 -  sum(confmatrix_GC)*sum(confmatrix_GC,2));

