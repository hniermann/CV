% Read in video 1
vid1 = VideoReader('OG2.MOV');
vid1.CurrentTime = 102;
currAxes = axes;
num = 1;
% Iterate and look for end. Then get 10 frames between 1 and num
while hasFrame(vid1)
    vidFrame = readFrame(vid1);
    image(vidFrame, 'Parent', currAxes);
    currAxes.Visible = 'off';
    pause(1/vid1.FrameRate);
    display(num);
    pause;
    num = num + 1;
end