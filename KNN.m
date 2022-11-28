% knn time!
% We will start with the first point
train = readmatrix("KNN1.txt");
X = train(:,1:2);
test = readmatrix("t1.txt");
Y = test(:,1:2);
Idx = knnsearch(X,Y,'K',1);
correct = 0;
for i = 1:size(Idx,1)
    predlabel = train(Idx(i),3);
    actlabel = test(i,3);
    if predlabel == actlabel
        correct = correct + 1;
    end
end
display("Accuracy: ");
accuracy = correct/size(Idx,1);
