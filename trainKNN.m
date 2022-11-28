% Creates data for the KNN to train and for testing
for i = 1 : 11
    filename = sprintf("mhi%d.txt",i);
    mhi = readmatrix(filename);
    nums = [];
    % If the value hit, didHit = 1, 0 otherwize
    didHit = 0
    for j = 1 : size(mhi,1)
        for k = 1 : size(mhi,1)
            if mhi(j,k) ~= 0
                nums = [nums; j, k, didHit];
            end
        end
    end
    outname = sprintf("KNN%d.txt",i);
    writematrix(nums,outname);
end
