% Ziyue Wang 2018 Summer ICR

%%MainV21E - using an larger array (matrix) to see if it reduces. Works
%%for Elahe's old data

% As of late July 2018, this is the main code used for parametric plotting.
% No differnetiation of time need to be made (recorded time, 80 or 85s).
% It's adaptive.

%% User Data 

tic
file = uigetfile;
load(file);
toc



radius = str2double(inputdlg('Enter radius of ROI'));
maxFrames = length(ImgData{1,1}(1,1,1,:));          

%% Get inputs and split into individual pixels 
yLength = length(ImgData{1,1}(1,:,1,1));        %Finds the length of the image. Basically the x and the y region
xLength = length(ImgData{1,1}(:,1,1,1));        %of the image. 

PixelMap = zeros(xLength+2*radius,yLength+2*radius,maxFrames);     % 800 for old data, 850 for new data

tic
for y = 1:yLength
    for x = 1:xLength
       
        %Takes data and stores it in PixelMap
        PixelMap(x+radius,y+radius,1:maxFrames-ImgLastFrame_PI) = ImgData{2,1}(x,y,1,ImgLastFrame_PI+1:maxFrames);
        PixelMap(x+radius,y+radius,maxFrames-ImgLastFrame_PI+1:maxFrames) = ImgData{2,1}(x,y,1,1:ImgLastFrame_PI);
        
        
    end
end
toc
%% Calculating TIC for each pixel ROI

%Idea behind this is to create a matrix large enough for the elements +
%radius to be all on one map. This way we don't need complicated rules for
%selecting which pixels to sum. The additional pixels on the outside of our
%pixelmap are just filled with 0s. Thus it doesn't mess with the actual
%data and decrease computational time at the same time. 
TICMap = zeros(xLength+2*radius,yLength+2*radius,maxFrames);


%Use parfor instead of for on high core machines for decreased computational time. Make sure to initiate
%parallel pools beforehand. 
tic
parfor y = 1+radius:yLength+radius
    for x = 1+radius:xLength+radius
        
        if radius > 0  
            k = mean(PixelMap(x-radius:x+radius,y-radius:y+radius,:));      %Takes the average of all the x coordinates for the matrix of pixels with the ROI
            TICMap(x,y,:) = mean(k(1,:,:),2);                               %Takes the average of the y values associated with the previous matrix
        else
            TICMap(x,y,:) = PixelMap(x,y,:);
        end
        
    end
end
toc

%% Calculates WIT and PI for each small pixel

%The fundamental idea is to create a matrix, where the x and y index of the
%matrix is the position of the pixel in 2D space. The value stored in that
%matrix is the parameter of interest. 


PIMap = zeros(xLength,yLength);
WITMap = zeros(xLength,yLength);
ATMap = zeros(xLength,yLength);
MTTMap = zeros(xLength,yLength);

tic 
for x = 1:xLength
    for y = 1:yLength
        
          findMax = max(TICMap(x+radius,y+radius,:));       %Find max intensity
          if findMax > 0
          index = find(TICMap(x+radius,y+radius,:) == findMax);     
          timeStamp = (index-1)/10;     %Matlab index starts at 1, so 0.0 second is actually 1st frame.
          
          
          r = reshape(TICMap(x+radius,y+radius,:),[1,maxFrames]);       %Reshapes our TIC map into a TIC curve for each pixel
          gk = diff(r,2);                                               %Second derivative of the position at each pixel
          gk(end) = [];                                                 %Second derivative goes to massive numbers at the end, so I just delete the last number
          maxGrad = max(gk(:));         
         
%           
          maxNoise = max(gk(1:150));                                    %Find's the maximum intensity within the noise of the second deriv, in the first 15 seconds. 
                                                                        %U&sed 15 as arbiatary numberr as most of the AT seemed to be around 20.
          ATIndexYeah = 0;                                              %Arbitary constant used later
          ATIndex = find(gk > maxNoise, 5);                             %Find the first 5 peaks greater than the noise found earlier
          if maxNoise < maxGrad                                         
         for j = 1:length(ATIndex)
          if ATIndex(j) < maxFrames-65                                  %Makes sure the check doens't overflow the array
          AvgRAfterIndex = mean(r(ATIndex(j):ATIndex(j)+30));          %Find's the average intensity after the supposed "intensity start"
                   
                %Following condition checks the: Timestamp of increaseis at least
                %after 5 seconds, the average intensity after the initial
                %increase is greater than that of the increase, and the
                %timestamp of increase is lower than the timestamp of the
                %peak intensity.
          if ((ATIndex(j) > 50) && (AvgRAfterIndex > r(ATIndex(j))) && (ATIndex(j) <= timeStamp*10))
              ATIndexYeah = ATIndex(j);
              break;        %If we've found our supposed arrival time, store it and break out of the for loop. 
          end
          end
          end
          end

          
          MTTEndIntensity = 0.65*findMax;       %65% of Peak intensity
          MTTEndIndex = find(r >= MTTEndIntensity,1,'last');            %finds the MTT intensity drop from the end of the array.
          
          ATMap(x,y) = (ATIndexYeah-1)/10;          %Stores everything$.
          MTTMap(x,y) = (MTTEndIndex-ATIndexYeah)/10;
          WITMap(x,y) = timeStamp;
          PIMap(x,y) = findMax;
          
                   
%           if ((x== 249) && (y==110))
%               ATIndex
%               ATIndexYeah
%               ATMap(x,y)§x
%           end
          end
    end
end

toc

%% does the parametric plotting
figure
subplot(1,2,1)
surf(PIMap)
title(['PI parametric radius ' num2str(radius)])
%xlabel('X')
ylabel('Y')
xlim([0 yLength])
ylim([0 xLength])
view(2)
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
colormap hot
colorbar
hold on

subplot(1,2,2)
surf(WITMap)
title(['WIT parametric radius ' num2str(radius)])
%xlabel('X')
ylabel('Y')
xlim([0 yLength])
ylim([0 xLength])
view(2)
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
colormap hot
colorbar

figure

subplot(1,2,1)
surf(ATMap)
title(['AT parametric radius ' num2str(radius)])
%xlabel('X')
ylabel('Y')
xlim([0 yLength])
ylim([0 xLength])
view(2)
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
colormap colorcube	
colorbar
%caxis([0 80])

subplot(1,2,2)
surf(MTTMap)
title(['MTT parametric radius ' num2str(radius)])
%xlabel('X')
ylabel('Y')
xlim([0 yLength])
ylim([0 xLength])
view(2)
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
colormap hot
colorbar

 %% Used for debugging
%           r = reshape(TICMap(x+radius,y+radius,:),[1,maxFrames]);
%           gk = diff(r,2);
%           gk(end) = [];
%           maxGrad = max(gk(:));
% 
%           figure
%           hold on
%           plot(1:maxFrames,r,'m')
%           
%           figure
%           plot(1:maxFrames-3,gk)  




