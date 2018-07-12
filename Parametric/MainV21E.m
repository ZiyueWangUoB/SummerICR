%%MainV21E - using an larger array (matrix) to see if it reduces. Works
%%for Elahe's old data
%%computational time. 

%% User Data 
%tic
%file = uigetfile;
%load(file);
%toc

radius = str2double(inputdlg('Enter radius of ROI'));
maxFrames = length(ImgData{1,1}(1,1,1,:));

%% Get inputs and split into individual pixels 
yLength = length(ImgData{1,1}(1,:,1,1));        %Finds the length of the image. Basically the x and the y region
xLength = length(ImgData{1,1}(:,1,1,1));        %of the image. 

PixelMap = zeros(xLength+2*radius,yLength+2*radius,maxFrames);     % 800 for old data, 850 for new data

tic
for y = 1:yLength
    for x = 1:xLength
        
        PixelMap(x+radius,y+radius,1:ImgLastFrame_PI) = ImgData{2,1}(x,y,1,maxFrames-ImgLastFrame_PI+1:maxFrames);
        PixelMap(x+radius,y+radius,ImgLastFrame_PI+1:maxFrames) = ImgData{2,1}(x,y,1,1:maxFrames-ImgLastFrame_PI);      
       
    end
end
toc
%% Calculating TIC for each pixel ROI

%TICMap(xLength,yLength) = PixelVector(1,1,1);
TICMap = zeros(xLength+2*radius,yLength+2*radius,maxFrames);

tic
for y = 1+radius:yLength+radius
    for x = 1+radius:xLength+radius
        %IntensitySum = PixelMap(x,y,:);
        %totalArea = (2*radius+1)^2;          %1 per pixel
        if radius > 0  
            k = mean(PixelMap(x-radius:x+radius,y-radius:y+radius,:));  
            TICMap(x,y,:) = mean(k(1,:,:),2);
        else
            TICMap(x,y,:) = PixelMap(x,y,:);
        end
        
    end
end
toc

%% Alternative for dumb checking - Create an array large enough for all the radius, an map of zeros.



%% Calculates WIT and PI for each small pixel


%gradientIntensity = gradient(TICMap(50,100).intensity);        %Find's the gradient at each point of the curve


%threshold = 20;             %This should be done by inspection analysis. Assumed to be 20 for my results so far.
%index = find(gradientIntensity>threshold,1);



% peak intensity first cuz that's easier

%PIMap(xLength,yLength) = PixelVector(1,1,1);
PIMap = zeros(xLength,yLength);
WITMap = zeros(xLength,yLength);
ATMap = zeros(xLength,yLength);
MTTMap = zeros(xLength,yLength);

tic 
for x = 1:xLength
    for y = 1:yLength
          %findMax = max(TICMap(x,y).intensity);
          findMax = max(TICMap(x+radius,y+radius,:));
          if findMax > 0
          %index = find(TICMap(x,y).intensity == findMax);
          index = find(TICMap(x+radius,y+radius,:) == findMax);
          timeStamp = (index-1)/10;     %Matlab index starts at 1, so 0.0 second is actually 1st frame.
          
          
          r = reshape(TICMap(100+radius,100+radius,:),[1,maxFrames]);
          gk = diff(r,2);
          
          maxNoise = max(gk(1:80));
          ATIndex = find(gk > maxNoise,1);          % Index - 1 would be the time but im lazy sorry
          
          MTTEndIntensity = 0.65*findMax;
          MTTEndIndex = find(r > MTTEndIntensity,1,'last');
          
          
          
          WITMap(x,y) = timeStamp;
          PIMap(x,y) = findMax;
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

%%






