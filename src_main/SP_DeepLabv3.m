%% SP_DeepLabv3
% Fred liu 2022.7.11
% DeepLabv3 Demno for RabbitData

% 2022.10.07 bug update
% class numer and class name error
%%  Build Datasotre
% you can get labeldata from gtruth or using define label(setup_readme)
%imds = imageDatastore(gTruth.DataSource.Source);
num = 15;
% Display one of the image
img = readimage(imds,num);
img = histeq(img);
figure,imshow(img)

%% Load Labeled Image
% you can get labeldata from gtruth or using define label(setup_readme)
%classes = ["rabbit","zero"];
%labelIDs = [1 2];
%pxds = pixelLabelDatastore(gTruth.LabelData.PixelLabelData,classes,labelIDs);

%% 影像與標記資料預檢視
%C = readimage(pxds,5);
pixelImg = imread(pxds.Files{num});
%pixelImg = readimage(pxds,num);

cmap = camvidColorMap;
layImg = labeloverlay(img,pixelImg,'ColorMap',cmap);
figure,imshow(layImg)
pixelLabelColorbar(cmap,[pxds.ClassNames;'other']);


%% 分割資料
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionCamVidData(imds,pxds);
numTrainingImages = numel(imdsTrain.Files);
numValImages = numel(imdsVal.Files);
numTestingImages = numel(imdsTest.Files);

%% 建立Network
imageSize = [608 608 3];

% Specify the number of classes.
numClasses = numel(pxds.ClassNames);


% Create DeepLab v3+.
lgraph = deeplabv3plusLayers(imageSize, numClasses, "resnet50");
% Semantic Segmentation With Deep Learning

%% 平衡分類權重 Balance Classes Using Class Weighting
tbl = countEachLabel(pxds)
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);

%% Training Options
% Define validation data.
dsVal = combine(imdsVal,pxdsVal);

% Define training options. 
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'MaxEpochs',100, ...  
    'MiniBatchSize',16, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',10,...
    'ValidationData',dsVal,...
    'ValidationPatience', 10,...
    'Plots','training-progress');
   
%% Data Augmentation
dsTrain = combine(imdsTrain, pxdsTrain);

 xTrans = [-10 10];
 yTrans = [-10 10];
 dsTrain = transform(dsTrain, @(data)augmentImageAndLabel(data,xTrans,yTrans));

%% Start Training
[DeepLabv3net, info] = trainNetwork(dsTrain,lgraph,options);

%% Test Single Image
I = readimage(imdsVal,2);
C = semanticseg(I, DeepLabv3net);

B = labeloverlay(I,C,'Colormap',cmap,'Transparency',0.4);
figure,imshow(B)
pixelLabelColorbar(cmap, pxds.ClassNames);

%% Test Dataset
expectedResult = readimage(pxdsTest,5);
actual = uint8(C);
expected = uint8(expectedResult);
imshowpair(actual, expected)

iou = jaccard(C,expectedResult);
table(pxds.ClassNames,iou)

pxdsResults = semanticseg(imdsTest,DeepLabv3net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',tempdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
metrics.DataSetMetrics
metrics.ClassMetrics

%% Supporting Functions
% 輔助函式

function pixelLabelColorbar(cmap, classNames)
% Add a colorbar to the current axis. The colorbar is formatted
% to display the class names with the color.

colormap(gca,cmap)

% Add colorbar to current figure.
c = colorbar('peer', gca);

% Use class names for tick marks.
c.TickLabels = classNames;
numClasses = size(cmap,1);

% Center tick labels.
c.Ticks = 1/(numClasses*2):1/numClasses:1;

% Remove tick mark.
c.TickLength = 0;
end



function data = augmentImageAndLabel(data, xTrans, yTrans)
% Augment images and pixel label images using random reflection and
% translation.

for i = 1:size(data,1)
    
    tform = randomAffine2d(...
        'XReflection',true,...
        'XTranslation', xTrans, ...
        'YTranslation', yTrans);
    
    % Center the view at the center of image in the output space while
    % allowing translation to move the output image out of view.
    rout = affineOutputView(size(data{i,1}), tform, 'BoundsStyle', 'centerOutput');
    
    % Warp the image and pixel labels using the same transform.
    data{i,1} = imwarp(data{i,1}, tform, 'OutputView', rout);
    data{i,2} = imwarp(data{i,2}, tform, 'OutputView', rout);
    
end
end