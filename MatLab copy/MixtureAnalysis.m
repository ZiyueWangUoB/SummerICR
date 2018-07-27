%%Double fit script - mixture models.
%A good chunk of this is copy pasted from 'NormalizeAndAnalysis.m' - refer
%back to there for comments if need be. Most of the procedures are straight
%forward anyway.


Intensity_Unadjusted = Intensity_PI;
t_Unadjusted = t;

Intensity_PI(:,1) = [];
t(:,1) = [];

minIntensity = min(Intensity_PI);      %Find's the thereshold minimum intensity
gradientIntensity = gradient(Intensity_PI);        %Find's the gradient at each point of the curve


threshold = 20;             %This should be done by inspection analysis. Assumed to be 20 for my results so far.
index = find(gradientIntensity>threshold,1);



%% To delete the initial WIT. We keep Intensity_PI because wash in time is still used. Bare in mind we've deleted the
%first element so there is 0.1s extra. 

for i = 1:8e3
  IntensityAdjT0 = Intensity_PI;
  AdjustedTime = t;
  IntensityAdjT0(:,[1:index - 10]) = [];
  AdjustedTime(:,[1:index - 10]) = [];
end

%Now t0 has been adjusted
%% Adjust time properly, shift first element of time to 0

MinTime = min(AdjustedTime);
AdjustedTime = AdjustedTime - MinTime;

%% To adjust the base Intensity to 0 (baseline) and normalise. 
IntensityAdjT0I0 = IntensityAdjT0 - minIntensity;
NormalizationConst = trapz(AdjustedTime,IntensityAdjT0I0);
IntensityNormalized = IntensityAdjT0I0./NormalizationConst;

%Adjust without cutting off the time data.
IntensityAdjustedT0I0WWIT = Intensity_Unadjusted - minIntensity;
IntensityNormalizedWWIT = IntensityAdjustedT0I0WWIT./NormalizationConst;


%% User interface for easier access
%{
FitAll = questdlg('Fit all the models or selective?', 'Fit Options', 'Fit all','Select','Fit none','Fit none');
skipFit = 0;
switch FitAll
    case 'Fit all'
        plotLogN = 1;
        plotGammaV = 1;
        plotLDRW = 1;
    case 'Select'
        plotLogN = PlotOrNot(0);
        plotGammaV = PlotOrNot(1);
        plotLDRW = PlotOrNot(2);
    case 'Fit none'
        plotLogN = 0;
        plotGammaV = 0;
        plotLDRW = 0; 
        skipFit = 1;
end
%}

%% Plotting and later fitting
figure
scatter(t_Unadjusted,IntensityNormalizedWWIT,'h', 'g')
hold on

%This chunk of code makes sure that the region of time that the models will
%fit to is in accordance with that specific region. Rectangle is used to
%drag and hence select the region. Possible problems is dragging a region
%before the minimum time. Perhaps remove minimum time all together? Or make
%minimum time an option - consider doing later.

AdjustedTimeFitting = AdjustedTime;
AdjustedTimeFitting2 = AdjustedTime;

        warndlg({'Use your mouse and draw a rectangle over the first region.'},'warning','modal');
        rectLimits = getrect;
        xStartRounded = round(rectLimits(1),1);        
        xEndRounded = round(rectLimits(1)+rectLimits(3),1);             %rectlimits 1 is starting x, 3 is width. Hence 1+3 is the end point
        xStart = xStartRounded - MinTime;
        xEnd = xEndRounded - MinTime;
        xStartFrame = round(xStart * 10);
        xEndFrame = round(xEnd * 10);
        totalFramesInRegion = xEndFrame - xStartFrame;
        totalFrames = length(AdjustedTime);
        
        AdjustedTimeFitting(:,[xEndFrame:totalFrames]) = [];

        warndlg({'Use your mouse and draw a rectangle over the second region.'},'warning','modal');
        rectLimits2 = getrect;
        xStartRounded2 = round(rectLimits2(1),1);        
        xEndRounded2 = round(rectLimits2(1)+rectLimits2(3),1);             %rectlimits 1 is starting x, 3 is width. Hence 1+3 is the end point
        xStart2 = xStartRounded2 - MinTime;
        xEnd2 = xEndRounded2 - MinTime;
        xStartFrame2 = round(xStart2 * 10);
        xEndFrame2 = round(xEnd2 * 10);
        totalFramesInRegion2 = xEndFrame2 - xStartFrame2;
        totalFrames2 = length(AdjustedTime);
        
        setStart = 1; 

%% LDRW double model
%{
maxError = 99999;
chiSq = 0;

nu1InitialLimit = 50;
nu2InitialLimit = 100;
lambda1InitialLimit = 80;
lambda2InitialLimit = 80;

for nu1 = 1:25
    for lambda1 = 1:15
        for nu2 = 10:100
            for lambda2 = 1:60
                
        LDRWV1 = LDRW(AdjustedTime,nu1,lambda1/10);
        LDRWV2 = LDRW(AdjustedTime,nu2,lambda2/10);
        %LDRWF2 = LDRW2(AdjustedTime,nu1,lambda1/10,nu2,lambda2/10);
        residualSqArray = zeros(1,length(AdjustedTimeFitting));
        chiSqArray = zeros(1,length(AdjustedTimeFitting));
        
        %This is for fitting two relatively separately. Ignore, was a test.
        %{      
        for i = xStartFrame:xEndFrame
            if (i >= xStartFrame2 && i <= xEndFrame2)
                residualSqArray(i) = (LDRWV1(i) + LDRWV2(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/(LDRWV1(i) + LDRWV2(i));
            else
                residualSqArray(i) = (LDRWV1(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/LDRWV1(i);
            end
        end
        
        for i = xStartFrame2:xEndFrame2
            if (i >= xStartFrame && i <= xEndFrame)
                residualSqArray(i) = (LDRWV1(i) + LDRWV2(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/(LDRWV1(i) + LDRWV2(i));
            else
                residualSqArray(i) = (LDRWV2(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/LDRWV2(i);
            end
        end
        %}
        
        %for i = xStartFrame:xEndFrame2
         %   residualSqArray(i) = (LDRWF2(i) - IntensityNormalized(i))^2;
         %   chiSqArray(i) = residualSqArray(i)/LDRWF2(i);
        %end
        
        for i = xStartFrame:xEndFrame2
            if i < xStartFrame2
                residualSqArray(i) = (LDRWV1(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/LDRWV1(i);
            else
                residualSqArray(i) = (LDRWV1(i) + LDRWV2(i) - IntensityNormalized(i))^2;
                chiSqArray(i) = residualSqArray(i)/(LDRWV1(i) + LDRWV2(i));
            end
        end
        

        Error = nansum(residualSqArray);
        chiSqTot = nansum(chiSqArray);
        if Error <= maxError
            residualSqArrayOptimal = residualSqArray;
            chiSq = chiSqTot;
            maxError = Error;
            nu1Optimal = nu1;
            lambda1Optimal = lambda1/10;
            nu2Optimal = nu2;
            lambda2Optimal = lambda2/10;
        end
        
        
        
        
            end
            
        end
    end
end

LDRW1Variables = [nu1Optimal lambda1Optimal]
LDRW2Variables = [nu2Optimal lambda2Optimal]
chiSq

LDRW1dist = LDRW(AdjustedTime,nu1Optimal,lambda1Optimal);
%LDRW1dist = LDRW(AdjustedTime,20,1.28);
LDRW2dist = LDRW(AdjustedTime,nu2Optimal,lambda2Optimal);

%LDRW2dist = LDRW2(AdjustedTime,nu1Optimal,lambda1Optimal,nu2Optimal,lambda2Optimal);


plot(AdjustedTime+MinTime,LDRW1dist,'b')
hold on
plot(AdjustedTime+MinTime,LDRW2dist,'r')
hold on
combine2dist = LDRW1dist + LDRW2dist;

plot(AdjustedTime+MinTime,combine2dist,'m')
%}

%% Lognormal
maxError = 9999999999;
Error = 0;
muOptimal = 0;
sigmaOptimal = 0;
mu2Optimal = 0;
sigma2Optimal = 0;


for mu = 1:500
    for sigma = 1:200
        for mu2 = 1:500
            for sigma2 = 1:200
        Error = 0;
        Lognormal = lognpdf(AdjustedTime,mu/100,sigma/100);
        Lognormal2 = lognpdf(AdjustedTime,mu2/100,sigma2/100);
        for i = xStartFrame:xEndFrame2
            if i < xStartFrame2
            residualSq = (Lognormal(i)-IntensityNormalized(i))^2;
            Error = Error + residualSq;
            if Error > maxError
                continue
            end
            else
            residualSq = (Lognormal(i)+Lognormal2(i)-IntensityNormalized(i))^2;
            Error = Error + residualSq;
            if Error > maxError
                continue
            end  
            end
        end
        if Error <= maxError
            maxError = Error;
            muOptimal = mu/100;
            sigmaOptimal = sigma/100;
            mu2Optimal = mu2/100;
            sigma2Optimal = sigma2/100;
        end
        
            end
        end
    end
end

LogNormalVariables = [muOptimal sigmaOptimal maxError]
LogNormalVariables2 = [mu2Optimal sigma2Optimal maxError]

logplot = lognpdf(AdjustedTime,muOptimal,sigmaOptimal);
plot(AdjustedTime+MinTime,logplot, 'r')
hold on

logplot2 = lognpdf(AdjustedTime,mu2Optimal,sigma2Optimal);
plot(AdjustedTime+MinTime,logplot2, 'b')
hold on

combineLognormal = logplot+logplot2;
plot(AdjustedTime+MinTime,combineLognormal,'m')

