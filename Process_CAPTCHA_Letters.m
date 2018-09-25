% This is a matlab file that processes a captcha letter created by
% Make_Captcha_Letters.m
% The ouput of this file is the blur portion of our matrix in a csv file
% The Image Plots have been commented out to improve efficiency
% We use these csv files to create our character bank, however we
% concatenated the rows for ease of storage

% Load our captcha (tif file) and convert to grayscale
captcha=rgb2gray(imread('Letter_M.tif'));

% Plot our image and compute the size
% ImagePlot(captcha)
[rows cols]=size(captcha);

% A for loop to check every pixel value that matches 127, which corresponds
% to the captcha text
% Inputs chosen matrix corrdinates in a 2 column matrix called points
points=zeros(1,2);
for i=1:rows
    for j=1:cols
        if captcha(i,j) == 127
            points=[points; [i,j]];
        end
    end
end

% Delete the first entry needed to initialize our points vector
points(1,:)=[];

% Calculate size of points vector
[A,B] = size(points);

% Find the maximum and minimum pixel locations for each entry
% These will be used to shift the pixel locations to the left and up so
% that we can get rid of most of the black space
minrow = min(points(:,1));
maxrow = max(points(:,1));
mincol = min(points(:,2));
maxcol = max(points(:,2));

% Initialize a matrix to contain the "shifted" pixel locations
% The constants create some wiggle room of black at the edges
Captchamat = zeros(maxrow-minrow ,maxcol-mincol);

% A for loop to input each "shifted" pixel location into Captchamat
for i=1: A
    k = points(i,1);
    j = points(i,2);
    Captchamat(k-minrow+1,j-mincol+1) = 255;
end

% Plot Captchamat
% figure;
% ImagePlot(Captchamat)

%We need to get the number of rows to 64 (a power of 2)
% This while loop will put a row of zeros at the bottom of the matrix to do so
[A,B] = size(Captchamat);
Zero_rvector = zeros(1,B);
while A < 64
    Captchamat = [Captchamat; Zero_rvector];
    [A,B] = size(Captchamat);
end

% We need to get the number of columns to 64 (a power of 2)
% This while loop will put a column of zeros at the right of the matrix to do so
[A,B] = size(Captchamat);
Zero_rvector = zeros(A,1);
while B < 64
    Captchamat = [Captchamat, Zero_rvector];
    [A,B] = size(Captchamat);
end

% Plot Captchamat
% figure;
% ImagePlot(Captchamat);

% Compute the HWT on Captchamat
its = 3;    % Number of iterations of the transform
h = sqrt(2)*Haar();
Number1T = WT2D(Captchamat, h, its);
%WaveletDensityPlot(Number1T, its, 'DivideLinesThickness', [2 1 2 2], 'Title', 'The HWT');

%Write blur portion of HWT to a csv file
csvwrite('Number_9.csv',Number1T(1:8,1:8))

