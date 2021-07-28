close all; clear all; clc


currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

% contains information on the cell borders
DAPI_binary = [filedir, '/DAPI_binary/'];
H2AX_binary = [filedir, '/H2AX_binary/'];

 if exist ([filedir, ['/analysis/', '/overlay'], 'dir']) == 0
    mkdir (filedir, ['/analysis/', '/overlay']);
end
overlay = [filedir, ['/analysis/', '/overlay']];

cd(DAPI_binary)
object_files = dir('*.tif');

foci_number_image = [];
foci_area_image = []; 

for kk = 1:numel(object_files)
    cd(DAPI_binary)
    Q = [num2str(kk),'.tif'];
    I = imread(Q);
    I = logical(I);
    I(:,1) = 0;
    I(:,end) = 0;
    I(1,:) = 0;
    I(end,:) = 0;
    [im_x, im_y] = size(I);
    [B,L,N,A] = bwboundaries(I,'holes');

    if exist ([filedir, ['/analysis/', 'result_sheets/', num2str(kk)], 'dir']) == 0
        mkdir (filedir, ['/analysis/', 'result_sheets/', num2str(kk)]);
    end
    results_foci = [filedir, ['/analysis/', 'result_sheets/', num2str(kk)]];

    for ww = 1:length(B)
        I_mask = imdilate(poly2mask(B{ww}(:,2),B{ww}(:,1),im_x,im_y), strel('diamond', 1));
        stat_mask = regionprops(I_mask, 'Area');
        stat_mask = stat_mask(:)
        for ii=1:length(stat_mask)
            mask_area = stat_mask(ii).Area
        end


        % read from H2AX folder
        cd(H2AX_binary)
        I_object = imread(Q);
        I_object = logical(I_object);
        ROI = I_object;
        ROI(I_mask== 0) = 0;
        ROI2 = logical(ROI); %

        im_object_data = regionprops (ROI2, 'Centroid', 'Area', 'PixelList');
        for jj=1:length(im_object_data)
            x_centroid_object(jj) = im_object_data(jj).Centroid(1);
            y_centroid_object(jj) = im_object_data(jj).Centroid(2);
            object_area(jj) = im_object_data(jj).Area(1);
        end

        if isempty(im_object_data)
           continue
            % move to next loop iteration
        end

        for jj=1:length(im_object_data)
            x_centroid_object = x_centroid_object(1:length(x_centroid_object));
            y_centroid_object = y_centroid_object(1:length(x_centroid_object));

            x_centroid_object = x_centroid_object(:);
            y_centroid_object = y_centroid_object(:);
        end

        C = imfuse(I, I_object,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

        image1 = figure('visible','off');
        imshow(C); 
        hold off
        cd(overlay)
        Output_Graph = [num2str(kk),'_overlay.tif'];
        hold off
        print(image1, '-dtiff', '-r300', Output_Graph)

        foci_number = length(im_object_data);
        % foci_number_cell(jj) = foci_number;

%         foci_number_cell(jj) = foci_number;
%         foci_number_cell_nnz = nonzeros(foci_number_cell);

        foci_area = object_area(:)

        foci_area_sum(ww) = sum(foci_area);
        foci_area_sum_nnz = foci_area_sum;
        % correct for nuclear area
        rel_foci_area_sum_nnz = foci_area_sum_nnz /mask_area
        

        % foci_area_mean(ww) = mean(foci_area);
        % foci_area_mean_nnz = nonzeros(foci_area_mean);
        
%         close all; clear mask_area foci_area_sum_nnz rel_foci_area_sum_nnz

    end
    
    rel_foci_area_sum_nnz = rel_foci_area_sum_nnz(1:(ww-1));
    % foci_area_mean_nnz = foci_area_mean_nnz(1:length(B));
    clear B
    
    cd(results_foci)
%     csvwrite(['cell' num2str(ww), '_foci_number.csv'], foci_number_cell_nnz(:))
    csvwrite([num2str(ww), '_cells' , '_relative_foci_area.csv'], rel_foci_area_sum_nnz(:))
%     csvwrite(['cell' num2str(ww), '_mean_foci_area.csv'], foci_area_mean_nnz(:))
    
    clear ww

end

clear all

