% Create MEI
N = 12;
for i=1:N
    filename = sprintf('v1d2/f%d.jpg', i); % if starts with 1
    Im(:,:,i) = rgb2gray(imread(filename));
end

motion = zeros(size(Im(:,:,1),1),size(Im(:,:,1),2));
part2motion = zeros(size(Im(:,:,1),1),size(Im(:,:,1),2));
mei = zeros(size(Im(:,:,1),1),size(Im(:,:,1),2), 11);
steps = zeros(size(Im(:,:,1),1),size(Im(:,:,1),2), 11);
% Make new image, and also store stages for MHI.
threshold = 30;
currImage = Im(:,:,1);
for i = 2 : N
    nextImage = Im(:,:,i);
    for j = 1 : size(motion,1)
        for k = 1 : size(motion,2)
            if abs(nextImage(j,k)-currImage(j,k)) > threshold
                motion(j,k) = 1;
                part2motion(j,k) = i;
            end
        end
    end
    currImage = nextImage;
    steps(:,:,i-1) = part2motion;
    mei(:,:,i-1) = motion;
end

threshold = 0.1;
for i = 1 : size(steps,3)
    c = steps(:,:,i);
    for j = 1 : size(motion,1)
        for k = 1 : size(motion,2)
            if c(j,k) < i-threshold
                c(j,k) = 0;
            end
            c(j,k) = max(0, (c(j,k)-1.0)/11.0);
        end
    end
    steps(:,:,i) = c;
end

% Read old MHI data and add to it
for i = 1 : size(steps,3)
    c = steps(:,:,i);
    name = sprintf('mhi%d.txt',i);
    existing = readmatrix(name);
%     existing = existing + c;
%     writematrix(existing,name);
imagesc(existing);
    axis('image');
    colormap('gray');
    pause;
end