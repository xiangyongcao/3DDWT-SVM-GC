function [TrainLabels, TrainData, TestLabels, TestData,...
    MapLabels, MapData, TrainingMap, TestMap,TrainIndex,TestIndex] = DataDivideNew(Data_scaled,Label,n)

[H, W, B] = size(Data_scaled);

ind_clas = unique(Label(:));
ind_clas = double(ind_clas);
ind_clas(1) = [];
nclasses = length(ind_clas);

TrainingMap = uint8(zeros(H,W));% initializing the training map
TestMap = uint8(zeros(H,W));    % initializing the test map

% data for all the pixels of training map belonging to 1- nclasses classes ,
% each pixel is represented by one row with B column data
N = sum(n);
TrainData = double(zeros(N, B));
Num_test = nnz(Label) - N;
TestData = zeros(Num_test,B);
TestLabels = zeros(Num_test,1);
currvectindex = 1;

nTest = 0;

TrainIndex = [];
TestIndex = [];
%creation of the test and the training map
for i = 1:nclasses
    n_tmp = n(i);
    currentmap = (Label == ind_clas(i));% currentmap is showing the existance of Current ind_class with value as 1 for only those pixel position where the pavia_gt becomes equal to current class,
    ind = find(currentmap==1)';
    ncurrentmap = length(ind);% ncurrentmap is an integral number,which actually represents the total number of pixels with current ind_class
    per_index = randperm(ncurrentmap);%generation of an random array (representing the pixel positions) of size of ncurrentmap
    trainindex = per_index (1:n_tmp);% taking only first n number of pixel positions
    trainindex = sort(trainindex);% sorting so as to move in the inreasing order of positions i.e left to right
    testindex = setdiff(1:ncurrentmap,trainindex);
    %     testindex  = per_index (n_tmp+1:end);
    testindex = sort(testindex);
    
    %     TrainIndex = [TrainIndex,ind(trainindex)];
    %     TestIndex = [TestIndex,ind(testindex)];
    
    currindex = 1;
    currtrainindex = 1;
    currtrainnumber = trainindex(currtrainindex);%initialization with first choosen random position
    
    for ind_height = 1:H
        for ind_width = 1:W
            if (currentmap(ind_height, ind_width) > 0)% if the pixel belongs to a particular class 1-9 as per currentmap built
                if (currindex == currtrainnumber)&&(currtrainindex<(n_tmp+1))%if a selected random postion is same as the current index and the number of pixels has not exceeded the number choosen i.e n
                    TrainingMap(ind_height, ind_width) = ind_clas(i);% current position in the map is marked as that class
                    Index_train = (ind_width-1) * H + ind_height;
                    TrainIndex = [TrainIndex,Index_train];
                    TrainData(currvectindex,:) = reshape(Data_scaled(ind_height, ind_width, :),1,B);% the data corresponding to that pixels is retrieved from the original scaled image and stored
                    currvectindex = currvectindex+1;%index incrementation for the Traindata
                    currtrainindex = currtrainindex + 1;% index incrementation in trainindex array
                    if (currtrainindex<(n_tmp+1)) currtrainnumber = trainindex(currtrainindex); end % currtrainnumber is updated
                else % then test map is created with all classed 1-9
                    TestMap(ind_height, ind_width) = ind_clas(i);
                    Index_test = (ind_width-1) * H + ind_height;
                    TestIndex = [TestIndex,Index_test];
                    nTest = nTest + 1; % recording the number of pixels marked with some class value
                    TestData(nTest,:) = reshape(Data_scaled(ind_height, ind_width, :),1,B);
                    TestLabels(nTest) = ind_clas(i);
                end %if (currindex == currtrainnumber)
                currindex = currindex + 1;% current index of te training map is updated
            end % if (currentmap(ind_height, ind_width) > 0)
        end %for ind_width = 1:W
    end % for ind_height = 1:H
end % for the classes
TestLabels = TestLabels';

% TrainIndex = [];
% TestIndex = [];
% for i = 1:nclasses
%     IndTrain = find(TrainingMap'==i)';
%     IndTest = find(TestMap'==i)';
%     TrainIndex = [TrainIndex,IndTrain];
%     TestIndex = [TestIndex,IndTest];
% end

% Training labels
TrainLabels = [];
for i = 1:nclasses
    TrainLabels = [TrainLabels;ind_clas(i)*ones(n(i),1)];
end

% %create test vectors
% TestData=double(zeros(nTest, B)); % initializing the test data matrix
% TestLabels = double(zeros(nTest,1));%initializing the test label matrix
% currTestIndex = 1;
% 
% for ind_height = 1:H
%     for ind_width = 1:W
%         if (TestMap(ind_height, ind_width) > 0)% if the pixel belongs to some class
%             % the data is retrieved and stored for that corresponsing pixel
%             TestData(currTestIndex,:) = reshape(Data_scaled(ind_height, ind_width, :),1,B);
%             TestLabels(currTestIndex) = TestMap(ind_height, ind_width);%labels are also stored corresponding to the pixel value in the testmap
%             currTestIndex = currTestIndex + 1;
%         end
%     end
% end

%map for the original data image is created (further used for the classification)
currMapIndex = 1;
% initializng the mapdata for original data image
MapData = double(zeros(H*W, B));
% initializng the maplabel for original data image
MapLabels = double(ones(H*W,1));
%creation of the map data with rows representing the number of pixels and
% their columns contain their corresponding band information.
MapData = reshape(Data_scaled,H*W,B);