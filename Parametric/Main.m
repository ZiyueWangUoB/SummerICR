%%Main

%% User Data 
file = uigetfile;
load(file);

radius = str2double(inputdlg('Enter radius of ROI'));


%% Get inputs and split into individual pixels 
yLength = length(ImgData{2,1}(1,:,1,1));        %Finds the length of the image. Basically the x and the y region
xLength = length(ImgData{2,1}(:,1,1,1));        %of the image. 

PixelMap(xLength,yLength) = PixelVector(1,1,2);
%pixel = [1:xLength*yLength];

for x = 1:xLength
    for y = 1:yLength
        intensity = [];
        for i = 1:ImgLastFrame_PI
            intensity(i) = ImgData{2,1}(x,y,1,i);
        end
        %PixelMap(x,y) = PixelVector(x,y,intensity);
        PixelMap(x,y).xCoord = x;
        PixelMap(x,y).yCoord = y;
        PixelMap(x,y).intensity = intensity;
    end
end

%% Calculating TIC for each pixel ROI

TICMap(xLength,yLength) = PixelVector(1,1,1);

for x = 1:xLength
    for y = 1:yLength
        IntensitySum = PixelMap(x,y).intensity;
        totalArea = (2*radius+1)^2;          %1 per pixel
        dgLeft = 0;dgUp = 0; dgRight = 0; dgDown = 0;
        leftLimit = radius; rightLimit = radius; upLimit = radius; downLimit = radius;
        
        
        %Up right down left first. Checks if they're available
        if x-radius >= 1
            IntensitySum = IntensitySum + PixelMap(x-radius,y).intensity;
        else
            dgLeft = 1;
            leftLimit = x-1;
        end
        if x+radius <= xLength
            IntensitySum = IntensitySum + PixelMap(x+radius,y).intensity;
        else
            dgRight = 1;
            rightLimit = xLength-x;
        end
        if y-radius >= 1
            IntensitySum = IntensitySum + PixelMap(x,y-radius).intensity;
        else
            dgUp = 1;
            upLimit = y-1;
        end
        if y+radius <= yLength
            IntensitySum = IntensitySum + PixelMap(x,y+radius).intensity;
        else
            dgDown = 1;
            downLimit = yLength-y;
        end
        
        
        %Iterating through the left + up, down + left combinations e.t.c
        for u = 1:leftLimit
            for v = 1:upLimit
                %Left and up    
                IntensitySum = IntensitySum + PixelMap(x-u,y-v).intensity;
            end
        end
        
        for u = 1:rightLimit
            for v = 1:upLimit
                %Left and up    
                IntensitySum = IntensitySum + PixelMap(x+u,y-v).intensity;
            end
        end
        
        for u = 1:leftLimit
            for v = 1:downLimit
                %Left and up    
                IntensitySum = IntensitySum + PixelMap(x-u,y+v).intensity;
            end
        end
        
        for u = 1:rightLimit
            for v = 1:downLimit
                %Left and up    
                IntensitySum = IntensitySum + PixelMap(x+u,y+v).intensity;
            end
        end
        
        TICMap(x,y).xCoord = x;
        TICMap(x,y).yCoord = y;
        TICMap(x,y).intensity = IntensitySum/totalArea;
    end
end


%% Calculates WIT and PI for each small pixel






gradientIntensity = gradient(TICMap(5,5).intensity);        %Find's the gradient at each point of the curve


%threshold = 20;             %This should be done by inspection analysis. Assumed to be 20 for my results so far.
%index = find(gradientIntensity>threshold,1);








