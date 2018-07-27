% load ('C:\Users\emoghimirad\Desktop\contrast experiments\mine\0.2_10s.mat')
% load ('C:\Users\emoghimirad\Desktop\contrast experiments\voltage_test\1.6_3v_2s.mat')
% load ('1st.mat')
% load ('mask_1st_center.mat')
%frame 3-9
%load('mask_200618.mat')
Intensity_PI = [];              %Pulse inversion
Intensity_BM = [];              %Bmode
for i=[ImgLastFrame_PI+1:850 1:ImgLastFrame_PI]
    BM_image = ImgData{1,1}(:,:,1,i);
    PI_image = ImgData{2,1}(:,:,1,i);
    Intensity_BM = [Intensity_BM mean(BM_image(find(mask_ROI==1)))];
    Intensity_PI = [Intensity_PI mean(PI_image(find(mask_ROI==1)))];
    
end

%plot(Intensity_PI)

%Fits go here


t = [0.1:0.1:85];
% hold on;plot(t, Intensity_BM./10,'.b')
hold on;
plot(t, Intensity_PI,'sk')
% legend('PW-5v','LBL-2v','PW-4v')
xlabel('Time (Sec)','FontSize',24); ylabel('Intensity (a.u.)','FontSize',24);
title('TIC curve','FontSize',24)
set(gca,'FontSize',24)
%figure;h_im = imagesc(ImgData{1,1}(:,:,1,1)+1000000*mask_ROI)
%% creating Mask
figure
 h_im = imagesc(ImgData{2,1}(:,:,1,1))
 BW = impoly();
 %BW = imellipse();
 
 
 %mask_ROILeft = createMask(BW,h_im);           %May or may not use theseﬂ
 %two
 %mask_ROIRight = createMask(BW,h_im);
 
 %%mask_ROIFull = createMask(BW,h_im);
 %%mask_ROISTD = createMask(BW,h_im);
 mask_ROIUpper = createMask(BW,h_im);
 %mask_ROILower = createMask(BW,h_im);
 %%mask_ROIMiddleSmall = createMask(BW,h_im);
 %%mask_ROIMiddleBig = createMask(BW,h_im);
 %%mask_ROIMiddleMed = createMask(BW,h_im);
 mask_ROI = mask_ROIMiddleSmall;
%% 
legend('Full','Standard','Upper', 'Lower','Middle (small)')
%legend('Big','Medium','Small')
%legend('Left','Right')
title('TIC curve with multiple ROIs - Plane wave','FontSize',24)
%legend('Run 1', 'Run 2', 'Run 3')