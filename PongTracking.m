%% Work with first video first
vid = VideoReader("OG1.MOV");
vid.CurrentTime = 11.3333;
currAxes = axes;
%frames from 11 sec timestamp, ideal patch is 10 frames out
frameCount = 0;
%patchFrame = read(vid, 10);
%imshow(patchFrame);
frameTest = readFrame(vid);
image(frameTest, "Parent", currAxes);
patch = frameTest(360:380,260:275,:);
imshow(patch);
arr1 = 1:568;
arr2 = 1:320;
[xPos, yPos] = meshgrid(arr2, arr1);
frameTestUse = double(frameTest);
modelIm = cat(3, xPos, yPos,frameTestUse);
%calculate patch model covariance from manually selected patch
patchUse = double(patch);
pArr1 = 1:21;
pArr2 = 1:16;
[xPatchPos, yPatchPos] = meshgrid(pArr2, pArr1);
modelPatch = cat(3, xPatchPos, yPatchPos, patchUse);
%flatten matrix values
flatPatch = reshape(modelPatch, [], 5);
modelCovMatrix = cov(flatPatch,1);
% while hasFrame(vid)
%     frame = readFrame(vid);
%     frameCount = frameCount + 1;
%     usableFrame = double(frame);
%     image(frame, 'Parent', currAxes);
%     whos frame
%     patch = frame(360:380,260:275,:);
%     imshow(patch);
%     
% end
pRow = 21;
pCol = 16;

%distances = [];
bestCovDist = 100000000;
bestCol = 0;
bestRow = 0;
for row = 1:568-pRow
    for col = 1:320-pCol
        newPatch = modelIm(row:row+pRow-1, col:col+pCol-1, :);
        newPatch = reshape(newPatch, [], 5);
        newPatchCov = cov(newPatch, 1);
        genEigs = eig(modelCovMatrix, newPatchCov);
        covDist = sqrt(sum(log(genEigs).^2, "all"));
        if covDist <= bestCovDist
            bestCovDist = covDist;
            bestRow = row;
            bestCol = col;
        end
    end
end

fprintf("Best Distance: %f\n", bestCovDist);
fprintf("Best row, col: %d, %d\n", bestRow, bestCol);
imshow(frameTest)
rectangle("Position",[bestCol bestRow pCol pRow], "EdgeColor",'g');
axis('on', 'image');

%% try on different frame
vid2 = VideoReader("OG2.MOV");
baseFrame = readFrame(vid2);
imshow(baseFrame);

vid2.CurrentTime = 13;

newFrame = readFrame(vid2);
imshow(newFrame);
%newFrameUse = cat(3, xPos, yPos, newFrame);
croppedFrame = newFrame(260:410,:,:);
imshow(croppedFrame);

%background sub test
backSub1 = double(rgb2gray(baseFrame));
backSub2 = double(rgb2gray(newFrame));
diff = abs(imsubtract(backSub2, backSub1));
imagesc(diff);
% thresh = 10;
% newDiff = diff > thresh;
% imagesc(newDiff);

covarianceTrack(modelCovMatrix,croppedFrame);

%% Optic Flow
xSobel = [-1,0,1;-2,0,2;-1,0,1]/8;
ySobel = transpose(xSobel);
avgMask = ones(3,3)/9;

vid3 = VideoReader("OG3.MOV");
vid3.CurrentTime = 9.7;
frame1 = readFrame(vid3);
imshow(frame1);
frame2 = readFrame(vid3);
imshow(frame2);
frame3 = readFrame(vid3);
imshow(frame3);
%background sub
gIm1 = double(rgb2gray(frame1));
gIm2 = double(rgb2gray(frame2));
gIm3 = double(rgb2gray(frame3));

gImDiff = abs(imsubtract(gIm2, gIm1));
imagesc(gImDiff);
gImDiff2 = abs(imsubtract(gIm3, gIm2));
imagesc(gImDiff2);

%calculate Ft from im1 to im2
Ft = imfilter(gIm2, avgMask) - imfilter(gIm1, avgMask);
Fx = imfilter(gIm2, xSobel);
Fy = imfilter(gIm2, ySobel);

%Use Fx, Fy, Ft to calculate and scale vectors
denominator = sqrt(Fx.^2 + Fy.^2);
directionVectorX = (Fx ./ denominator);
directionVectorY = (Fy ./ denominator);
scaleVect = (-1.*(Ft))./ denominator;

%plot vector with scale on the box
xBox = (1:size(gIm1,1));
yBox = (1:size(gIm1,2));
[X,Y] = meshgrid(yBox,xBox);
imagesc(frame1);
hold on;
motionMap = quiver(X,Y,directionVectorX.*scaleVect, directionVectorY.* scaleVect, 'm');
hold off;

%test with another shot at different arc point
vid3.CurrentTime = 65.8;
shot2_1 = readFrame(vid3);
imshow(shot2_1);
shot2_2 = readFrame(vid3);
opticFlow(shot2_1, shot2_2);

function [bestRow, bestCol] = covarianceTrack(modelPatchCov, im)
    arr1 = 1:size(im, 1);
    arr2 = 1:size(im, 2);
    [xPos, yPos] = meshgrid(arr2, arr1);    
    newFrameUse = cat(3, xPos, yPos, double(im));
    pRow = 21;
    pCol = 16;
    bestCovDist = 100000000;
    bestCol = 0;
    bestRow = 0;
    for row = 1:size(im,1)-pRow
        for col = 1:size(im,2)-pCol
            newPatch = newFrameUse(row:row+pRow-1, col:col+pCol-1, :);
            newPatch = reshape(newPatch, [], 5);
            newPatchCov = cov(newPatch, 1);
            genEigs = eig(modelPatchCov, newPatchCov);
            covDist = sqrt(sum(log(genEigs).^2, "all"));
            if covDist <= bestCovDist
                bestCovDist = covDist;
                bestRow = row;
                bestCol = col;
            end
        end
    end
    
    fprintf("Best Distance: %f\n", bestCovDist);
    fprintf("Best row, col: %d, %d\n", bestRow, bestCol);
    imshow(im)
    rectangle("Position",[bestCol bestRow pCol pRow], "EdgeColor",'g');
    axis('on', 'image');
end

function opticFlow(im1, im2)
    xSobel = [-1,0,1;-2,0,2;-1,0,1]/8;
    ySobel = transpose(xSobel);
    avgMask = ones(3,3)/9;

    gIm1 = double(rgb2gray(im1));
    gIm2 = double(rgb2gray(im2));

    gImDiff = abs(imsubtract(gIm2, gIm1));

    %calculate Ft from im1 to im2
    Ft = imfilter(gIm2, avgMask) - imfilter(gIm1, avgMask);
    Fx = imfilter(gIm2, xSobel);
    Fy = imfilter(gIm2, ySobel);
    
    %Use Fx, Fy, Ft to calculate and scale vectors
    denominator = sqrt(Fx.^2 + Fy.^2);
    directionVectorX = (Fx ./ denominator);
    directionVectorY = (Fy ./ denominator);
    scaleVect = (-1.*(Ft))./ denominator;
    
    %plot vector with scale on the box
    xBox = (1:size(gIm1,1));
    yBox = (1:size(gIm1,2));
    [X,Y] = meshgrid(yBox,xBox);
    imagesc(gImDiff);
    hold on;
    motionMap = quiver(X,Y,directionVectorX.*scaleVect, directionVectorY.* scaleVect, 'm');
    hold off;
end