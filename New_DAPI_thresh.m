%% Thresholding Script DAPI
% Victor Alfred, 2020

close all; clear variables; clc

% *** DEFINE FILE EXTENSION OF IMAGE FILES FOR PROCESSING ***
fileext = '.tif';
% *** DEFINE THRESHOLD VALUE ***
thresh_level = 0.35; % first_analysis used 0.6
% *** DEFINE MINIMUM OBJECT SIZE ***
min_object_size = 2; % made obsolete by the lines below
% range of object sizes to be removed with bwareaopen
% LB = 10000; % remove objects smaller than 5000 px in area
% UB = 30000; % remove objects larger than 30000 px in area


%% *** ASK WHETHER SHOULD USE DEFAULT PARAMETERS ***
usedefault = questdlg(strcat('Use default settings (thresh_level = ',num2str(thresh_level),...
   'px, fileext = ', fileext,'?)'),'Settings','Yes','No','Yes');

if strcmp(usedefault, 'No')
    parameters = inputdlg({'Enter threshold value:', 'Enter minimum object size (in pixels)',...
     'Enter file extension:'},'Parameters',1,...
        {num2str(thresh_level),num2str(min_object_size),fileext});
    % *** REDEFINE PIXEL AREA ***
   thresh_level = str2double(parameters{1});
    % *** REDEFINE MINIMAL OBJECT SIZE IN PIXELS ***
    min_object_size = str2double(parameters{2});
    % *** REDEFINE FILE EXTENSION OF IMAGE FILES FOR PROCESSING ***
    fileext = parameters{3};
    
    parameters = parameters';
else
    parameters{1} = num2str(thresh_level);
    parameters{2} = num2str(min_object_size);
    parameters{3} = fileext;
end

% specify number of subfolders as input
% n_subfolders = inputdlg('Please enter number of subfolders: ','n_subfolders');
%  while (isnan(str2double(n_subfolders)) || str2double(n_subfolders)<0)
%      n_subfolders = inputdlg('Please enter number of subfolders: ','n_subfolders');
% end

currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);
img_files = dir('*.tif');

% contains information on the cell borders
DAPI = [filedir, '/DAPI/'];
cd(DAPI)
img_files = dir('*.tif');

% creating main result directory
if exist([filedir, '/DAPI_binary'],'dir') == 0
    mkdir(filedir,'/DAPI_binary');
end
DAPI_binary = [filedir, '/DAPI_binary'];


% Thresholding individual images in the subfolder
 for g=1:numel(img_files)
    cd(DAPI);
    I = [num2str(g),'.tif'];
    I_im = imread(I);
    BW = imbinarize(I_im, adaptthresh (I_im, thresh_level));       
    % BW2 = xor(bwareaopen(BW, LB), bwareaopen(BW, UB)); 
    BW2 = imclearborder(BW);
    BW2 = medfilt2(BW2);
    labeledImage = bwlabel(BW2);
    stats = regionprops(labeledImage,'Circularity','Area');
    minCirc = 0.6; maxCirc = 1; minArea = 1000; maxArea = 8000;
    keepMask = [stats.Circularity]>minCirc & [stats.Circularity]<maxCirc ...
    & [stats.Area] > minArea & [stats.Area] < maxArea;
    blobsToKeep = find(keepMask);
    J = ismember(labeledImage, blobsToKeep) > 0;
    I_holes = imfill(J, 'holes');
    I_holes = im2double(I_holes); figure, imshow(I_holes)
    % write binary data to subfolder
    cd(DAPI_binary)
    imwrite(I_holes, [num2str(g),'.tif'], 'Compression', 'none');
    dlmwrite('parameters.txt',[thresh_level, minCirc, minArea, maxArea])
    close all
end
    
