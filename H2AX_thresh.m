


close all; clear variables; clc

% *** DEFINE FILE EXTENSION OF IMAGE FILES FOR PROCESSING ***
fileext = '.tif';
% *** DEFINE THRESHOLD VALUE ***
thresh_level = 0;
% *** DEFINE MINIMUM OBJECT SIZE ***
min_object_size = 150;

%% *** ASK WHETHER SHOULD USE DEFAULT PARAMETERS ***
usedefault = questdlg(strcat('Use default settings (thresh_level = ',num2str(thresh_level),...
    ', min_object_size = ', num2str(min_object_size), 'px, fileext = ', fileext,'?)'),'Settings','Yes','No','Yes');

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

%% Setting and creating directories

currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

% contains information on the cell borders
H2AX = [filedir, '/H2AX/'];
cd(H2AX)
img_files = dir('*.tif');


% creating main result directory
if exist([filedir, '/H2AX_binary'],'dir') == 0
    mkdir(filedir,'/H2AX_binary');
end
H2AX_binary = [filedir, '/H2AX_binary'];

for g=1:numel(img_files)
	cd(H2AX);
	I = [num2str(g),'.tif'];
	I_im = imread(I);
    BW = imbinarize(I_im, adaptthresh (I_im, thresh_level));  
%     BW = imbinarize(I_im, 0.9); figure, imshow(BW)
    J = medfilt2(BW); imshow(J)
    BW2 = bwareaopen(J, min_object_size);  
	I_holes = imfill(BW2, 'holes');
    I_holes = im2double(I_holes); imshow(I_holes)
	cd(H2AX_binary);
	imwrite(I_holes, [num2str(g),'.tif'], 'Compression', 'none');
	dlmwrite('parameters.txt',[thresh_level, min_object_size])
end


