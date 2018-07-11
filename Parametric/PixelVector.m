classdef PixelVector
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xCoord;
        yCoord;
        intensity;
    end
    methods
        
        function pixel = PixelVector(x,y,int)
            if nargin > 0
            pixel.xCoord = x;
            pixel.yCoord = y;
            pixel.intensity = int;
            end
            
        end
        
        function pixel = set.xCoord(pixel,x)
            pixel.xCoord = x;
        end
        
        function pixel = set.yCoord(pixel,y)
            pixel.yCoord = y;
        end
        
        function pixel = set.intensity(pixel,i)
            pixel.intensity = i;
        end
        
        function x_coord = get.xCoord(pixel)
            x_coord = pixel.xCoord;
        end
        
        function y_coord = get.yCoord(pixel)
            y_coord = pixel.yCoord;
        end
        
        function intensities = get.intensity(pixel)
            intensities = pixel.intensity;
        end
        
        
    end
    
end

