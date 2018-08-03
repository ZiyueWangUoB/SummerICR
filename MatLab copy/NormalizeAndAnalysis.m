%Ziyue Wang 2018 Summer ICR

%This script is made to normalize the data and adjust for the minimum time
%and intensity parameters. 

%Must first have Intensity_PI loaded into workspace, ideally after using
%the TIC plot.m code. Check if there sis a 0 value in Intensity_PI,
%manually adjust

%We need to delete the first value of both t and Intensity_PI otherwise the
%0 causes issues
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

%% Plotting and later fitting
figure
scatter(t_Unadjusted,IntensityNormalizedWWIT,'h', 'g')
hold on

AdjustedTimeFitting = AdjustedTime;

if skipFit == 0 
SelectRegion = questdlg('Do you want to select a specific region to fit?','Fit Region', 'Yes', 'No', 'No');

%{
switch SelectRegion
    case 'Yes'
        warndlg({'Keep in mind that the initial point where the model fits the curve'...
            'is predetermined automatically, so you should only select the point where'...
            'you want the model to stop fitting (I.E somewhere just after the first peak).','Press enter after your selection is made.'}, 'Warning','modal');
        [xEnd,yEnd] = getpts;               %Gets user inputs
        xEndRounded = round(xEnd,1);        %Rounds to nearest .1
        xLimit = xEndRounded - MinTime;     %Finds the limit to fit model to by finding difference between cutoff (initial) nd cutoff (final)#
        xLimitFrame = round(xLimit * 10)          %Scales to find last frame for models to compare with
        totalFrames = length(AdjustedTime);         %Find's total number of frames
        AdjustedTimeFitting(:,[xLimitFrame:totalFrames]) = [];          %Deletes all the frames onwards
    case 'No'
end

%}
xStartFrame = 1;
xEndFrame = length(IntensityNormalized);

switch SelectRegion
    case 'Yes'
        warndlg({'Alpha testing fit, use other uncommented code if this is janky'},'warning','modal');
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
end

end


%% Lognormal least squares

% The logic between each fit is the same, so I shall only comment one of
% them.


if plotLogN == 1
maxError = 9999999999;      %A  max error, so that iterations will have a start point
Error = 0;                  %Initializing the rest of the variables
chiSqTot = 0;
muOptimal = 0;
sigmaOptimal = 0;
maxChiSq = 999999999;


for mu = 1:500
    for sigma = 1:200
        Error = 0;      %Resetting variables
        chiSqTot = 0;
        Lognormal = lognpdf(AdjustedTime,mu/100,sigma/100);
        for i = xStartFrame:xEndFrame
            residualSq = (Lognormal(i)-IntensityNormalized(i))^2;       %Calculates residual of that loop
            Error = Error + residualSq;                                 %Sums the residual
            if Lognormal(i) > 1e-10                         %To prevent for very small numbers skewing chi squared
                chiSq = residualSq/Lognormal(i);
            else
                chiSq = 0;
            end
            chiSqTot = chiSqTot + chiSq;                %Calulating the chiSq for this loop
            if Error > maxError                         %This is here to speed up computation
                continue
            end
        end
        if Error <= maxError                               %if larger just replace all variables 
            maxError = Error;
            maxChiSq = chiSqTot;
            muOptimal = mu/100;
            sigmaOptimal = sigma/100;
        end
        
    end
end

LogNormalVariables = [muOptimal sigmaOptimal maxError maxChiSq]         %Outputs key variables into workspace

logplot = lognpdf(AdjustedTime,muOptimal,sigmaOptimal);
plot(AdjustedTime+MinTime,logplot, 'r')

end

%% Gamme Variate model
if plotGammaV == 1
    
maxError = 9999999999;
maxChiSq = 999999999;
Error = 0;
alphaOptimal = 0;
betaOptimal = 0;


for alpha = 0:100
    for beta = 0:200
        Error = 0;
        chiSqTot = 0;
        GammaV = gampdf(AdjustedTime,alpha/10,beta/10);
        for i = xStartFrame:xEndFrame
            residualSq = (GammaV(i) - IntensityNormalized(i))^2;
            Error = Error + residualSq;
            if GammaV(i) > 1e-10
                chiSq = residualSq/GammaV(i);
            else
                chiSq = 0;
            end
                      
            chiSqTot = chiSqTot + chiSq; 
            if Error > maxError
                continue
            end
        end
        if Error <= maxError
            maxError = Error;
            maxChiSq = chiSqTot;
            alphaOptimal = alpha/10;
            betaOptimal = beta/10;
        end
    end
end

GammaValues = [alphaOptimal betaOptimal maxError maxChiSq]

Gammadist = gampdf(AdjustedTime,alphaOptimal, betaOptimal);

plot(AdjustedTime+MinTime,Gammadist,'k')
hold on 

end

%% LDRW model
if plotLDRW == 1
maxError = 99999;
maxChiSq = 999999999;


for nu = 1:500
    for lambda = 1:80
        LDRWV = LDRW(AdjustedTime,nu/10,lambda/10);
        residualSqArray = zeros(1,length(AdjustedTimeFitting));
        chiSqArray = zeros(1,length(AdjustedTimeFitting));
        for i = xStartFrame:xEndFrame
            residualSqArray(i) = (LDRWV(i) - IntensityNormalized(i))^2;     %This loop is slightly different as NaN will be calculated sometimes

            if LDRWV(i) > 1e-10
                chiSqArray(i) = residualSqArray(i)/LDRWV(i);
            end
        end
        Error = nansum(residualSqArray);                                    %because of the NaNs, I store everything into an array
        chiSq = nansum(chiSqArray);                                         %and then sum it at the end. However, this is obviously
        if Error < maxError                                                 %computational costly.
            maxError = Error;
            maxChiSq = chiSq;
            nuOptimal = nu/10;
            lambdaOptimal = lambda/10;
        end
    end
end

LDRWVariables = [nuOptimal lambdaOptimal maxError maxChiSq]

LDRWdist = LDRW(AdjustedTime,nuOptimal,lambdaOptimal);

plot(AdjustedTime+MinTime,LDRWdist,'b')
end
%title('TIC of 0.4ml sonazoid in phantom.')
title('Standard ROI, first peak fitted')
legend('Data', 'Lognormal pdf', 'Gamma Variate pdf','LDRW model') 
xlabel('Time (s)')
ylabel('Intensity (Normalized, AUC = 1)')


%% Plotting legends e.t.c
%{
dim = [0.15 .6 .12 .25];
str1 = ['Lognormal Variables: \mu = ', num2str(LogNormalVariables(1)) ' \sigma = ' num2str(LogNormalVariables(2)) ' \chi ^2 = ' num2str(LogNormalVariables(3))];
str2 = ['Gamma variate Variables: \alpha = ', num2str(GammaValues(1)) ' \beta = ' num2str(GammaValues(2)) ' \chi ^2 = ' num2str(GammaValues(3))];
str3 = ['LDRW Variables: \mu = ', num2str(LDRWVariables(1)) ' \lambda = ' num2str(LDRWVariables(2)) ' \chi ^2 = ' num2str(LDRWVariables(3))];


set(gca,'fontsize',24)
textb = annotation('textbox',dim,'String',{str1, str2, str3});
size = textb.FontSize;
textb.FontSize = 20;

%}
