count = 1;
degs = 0.1:0.1:360;
length(degs)
hold on
xVals = zeros(3600);
yVals = zeros(3600);
for ii = 0:0.0139:5
    xVals(count) = ii * cos(degs(count));
    yVals(count) = ii * sin(degs(count));
    count = count + 1;
end

plot(xVals, yVals)
