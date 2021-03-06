%% ALL Setup
% Fred liu 2022.3.1
% 2022.5.17 update

%% Setup
addpath('src_main');
addpath('src_input');
addpath('src_fun');
addpath('label');
addpath('model');
addpath('Img');

%% Load gTruth and change path
% 選擇要載入的標記檔案，可以使用物件偵測與語意分割
num = 2;
switch(num)
    % Object Detection（物件偵測）
    % 這裡更改你的資料路徑 Change your data path
    case 1
        NewPath = 'D:\Fred\MATLAB_Library(Github)\RabbitDetect\Rabbit_myself_608\';
        T_gTruth = Change_gTruthPath(NewPath);

    % Semantic segmentation（語意分割）
    case 2
        SourceData = 'D:\Fred\MATLAB_Library(Github)\RabbitDetect\Rabbit_myself_608\';
        LabelData = 'D:\Fred\MATLAB_Library(Github)\RabbitDetect\label\PixelLabelData\';
        [imds,pxds]  = Change_gTruthPath_Seg(SourceData,LabelData);
end
%% readme

% DataSet : Rabbit_myself_608.zip , Rabbit_myself_416.zip
% Label Data : label/Rabbit_myself_608.mat
% Model : models/Modeldownload
% Json Label input : src_input/Jsoninput.m
% XML Label input : src_input/XMLinput.m
% Algorithm : src_main\~~~

% ====================================================
% Object Detection algorithm
% FasterRCNN: SP_FasterRCNN.m
% SSD:        SP_SSD.m
% YOLOv2:     SP_YOLOv2.m
% YOLOv3:     SP_YOLOv3.m
% YOLOv4:     SP_YOLOv4.m
% ====================================================

% ====================================================
% Semantic Segmentation algorithm
% DeepLabv3+: SP_DeepLabv3.m
% Unet:       SP_Unet.m(not yet)
% ====================================================

% ====================================================
% instance Segmentation algorithm
% MaskRCNN:  SP_MaskRCNN.m(not yet)
% ====================================================





