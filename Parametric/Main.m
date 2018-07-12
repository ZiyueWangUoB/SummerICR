%%Main

%% User Data 
%tic
%file = uigetfile;
%load(file);
%toc

radius = str2double(inputdlg('Enter radius of ROI'));


%% Get inputs and split into individual pixels 
yLength = length(ImgData{2,1}(1,:,1,1));        %Finds the length of the image. Basically the x and the y region
xLength = length(ImgData{2,1}(:,1,1,1));        %of the image. 

%PixelMap(xLength,yLength) = PixelVector(1,1,2);
PixelMap = zeros(xLength,yLength,850);
%pixel = [1:xLength*yLength];

tic
for y = 1:yLength
    for x = 1:xLength
        intensity = [];
        %for i = 2:849
        %    intensity(i) = ImgData{2,1}(x,y,1,i);
        %end
        
        %PixelMap(x,y).xCoord = x;
        %PixelMap(x,y).yCoord = y;
        %PixelMap(x,y).intensity = intensity;
        
        PixelMap(x,y,:) = ImgData{2,1}(x,y,1,:);
    end
end
toc
%% Calculating TIC for each pixel ROI

%TICMap(xLength,yLength) = PixelVector(1,1,1);
TICMap = zeros(xLength,yLength,850);

tic
parfor y = 1:yLength
    for x = 1:xLength
        IntensitySum = PixelMap(x,y,:);
        totalArea = (2*radius+1)^2;          %1 per pixel
        if radius > 0
        dgLeft = 0;dgUp = 0; dgRight = 0; dgDown = 0;
        leftLimit = radius; rightLimit = radius; upLimit = radius; downLimit = radius;
        
        
        %Up right down left first. Checks if they're available
        if x-radius >= 1
            %IntensitySum = IntensitySum + PixelMap(x-radius,y).intensity;
            IntensitySum = IntensitySum + PixelMap(x-radius,y,:);
        else
            dgLeft = 1;
            leftLimit = x-1;
        end
        if x+radius <= xLength
            %IntensitySum = IntensitySum + PixelMap(x+radius,y).intensity;
            IntensitySum = IntensitySum + PixelMap(x+radius,y,:);
        else
            dgRight = 1;
            rightLimit = xLength-x;
        end
        if y-radius >= 1
            %IntensitySum = IntensitySum + PixelMap(x,y-radius).intensity;
            IntensitySum = IntensitySum + PixelMap(x,y-radius,:);
        else
            dgUp = 1;
            upLimit = y-1;
        end
        if y+radius <= yLength
            %IntensitySum = IntensitySum + PixelMap(x,y+radius).intensity;
            IntensitySum = IntensitySum + PixelMap(x,y+radius,:);
        else
            dgDown = 1;
            downLimit = yLength-y;
        end
        
        
        %Iterating through the left + up, down + left combinations e.t.c
        for u = 1:leftLimit
            for v = 1:upLimit
                %Left and up    
                %IntensitySum = IntensitySum + PixelMap(x-u,y-v).intensity;
                IntensitySum = IntensitySum + PixelMap(x-u,y-v,:);
            end
        end
        
        for u = 1:rightLimit
            for v = 1:upLimit
                %Left and up    
                %IntensitySum = IntensitySum + PixelMap(x+u,y-v).intensity;
                IntensitySum = IntensitySum + PixelMap(x+u,y-v,:);
            end
        end
        
        for u = 1:leftLimit
            for v = 1:downLimit
                %Left and up    
                %IntensitySum = IntensitySum + PixelMap(x-u,y+v).intensity;
                IntensitySum = IntensitySum + PixelMap(x-u,y+v,:);
            end
        end
        
        for u = 1:rightLimit
            for v = 1:downLimit
                %Left and up    
                %IntensitySum = IntensitySum + PixelMap(x+u,y+v).intensity;
                IntensitySum = IntensitySum + PixelMap(x+u,y+v,:);
            end
        end
        end
        
        %TICMap(x,y).xCoord = x;
        %TICMap(x,y).yCoord = y;
        %TICMap(x,y).intensity = IntensitySum/totalArea;
        
        TICMap(x,y,:) = IntensitySum/totalArea;
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

tic 
for x = 1:xLength
    for y = 1:yLength
          %findMax = max(TICMap(x,y).intensity);
          findMax = max(TICMap(x,y,:));
          if findMax > 0
          %index = find(TICMap(x,y).intensity == findMax);
          index = find(TICMap(x,y,:) == findMax);
          timeStamp = (index-1)/10;     %Matlab index starts at 1, so 0.0 second is actually 1st frame. 
          
          
          %PIMap(x,y).xCoord = x;
          %PIMap(x,y).yCoord = y;
          %PIMap(x,y).intensity = timeStamp;         %Using intensity as timestamp, not a vector this time.
          
          %if ((timeStamp > 20) && (timeStamp < 60)) 
          WITMap(x,y) = timeStamp;
          PIMap(x,y) = findMax;
          %end
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

