function Break_Captcha( filename )
% This a function where the input is a .tif file created by Make_Captcha.
% Through a series of procedures, this function will output a dialog box
% with the string that the function has determined to be present in the 
% Captcha
% The plots have been deleted from this function to increase speed. If you
% would like to see intermediate plots see Process_CAPTCHA.m

% Load our captcha (tif file) and convert to grayscale
captcha=rgb2gray(imread(filename));

% Compute the size of our Captcha
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

% Create linear regression that best fits the scatter plot
regression_model=polyfit(points(:,2),points(:,1),1);
rot_ang=atan(regression_model(1));

% Construct rotation matrix
Rot_matrix = [cos(rot_ang), sin(rot_ang);
              -sin(rot_ang),  cos(rot_ang)];

% Calculate size of points vector
[A,B] = size(points);

% A for loop to rotate every row of points by rot_angle using Rot_matrix
Captchavec = zeros(1,2);
for i=1:A
    Captchavec(i,:) = round(points(i,:) * Rot_matrix);
end

% Find the maximum and minimum pixel locations for each entry
% These will be used to shift the pixel locations to the left and up in the
% matrix so that we can get rid of some black space
minrow = min(Captchavec(:,1));
maxrow = max(Captchavec(:,1));
mincol = min(Captchavec(:,2));
maxcol = max(Captchavec(:,2));

% Initialize a matrix to contain the "shifted" pixel locations
% The constants create some wiggle room of black at the edges
Captchamat = zeros(maxrow-minrow+4 ,maxcol-mincol+4);

% A for loop to input each "shifted" pixel location into Captchamat
for i=1: A
    k = Captchavec(i,1);
    j = Captchavec(i,2);
    Captchamat(k-minrow+2,j-mincol+2) = 255;
end

% If the number of rows is less than 64
% We need to get the number of rows to 64 (a power of 2)
% This while loop will put a row of zeros at the top of the matrix to do so
[A,B] = size(Captchamat);
Zero_rvector = zeros(1,B);
if A < 64
    while A < 64
        Captchamat = [Zero_rvector; Captchamat];
        [A,B] = size(Captchamat);
    end
end

% IF the number of rows is greater than 64, delete the bottom row until
% Captchamat is of size 64
if A > 64
    while A > 64
        Captchamat(A,:) = [];
        [A,B] = size(Captchamat);
    end
end

% Get rid of the black columns at the beginning of Captchamat
i = 1;
while Captchamat(:,i) == zeros(64,1)
    Captchamat(:,i) = [];
end

% We want each character to be contained in a 64x64 matrix and the
% following nested loop does this. Every 64 columns in Charmatrix will
% correspond to one character of our string
[row,col] = size(Captchamat);
Charmatrix = zeros(64,5*64);

% This is a for loop to complete the task described above
p = 1; 
j = 1;   
for i=1:col-1 % For each column
    D = Captchamat(:,i); % Take the ith column
    if D == zeros(row,1) % If the ith column is all zeros
        j = 1; % Reset j to 1
        p = p + 1; % Add one to p
        if Captchamat(:,i+1) == D % If the next column is also all zeros
            p = p - 1; % Subtract one from p
        end
    end
    for k = 1:row % For each entry in D
        if D(k) == 255 % If we find a white pixel
            Charmatrix(:,row*(p-1)+j) = Captchamat(:,i); % Put that column into Charmatrix
            j = j+1; % And add one to j, then terminate loop
            break
        end
    end
end

% Now every 64 colunms is what we shall do the HWT on
% Seperate the matrix into each corresponding letter
Letter1 = Charmatrix(:,64*0+1:64*1);
Letter2 = Charmatrix(:,64*1+1:64*2);
Letter3 = Charmatrix(:,64*2+1:64*3);
Letter4 = Charmatrix(:,64*3+1:64*4);
Letter5 = Charmatrix(:,64*4+1:64*5);

% Now we want to move all of the black rows in each letter to the bottom
[row,col] = size(Letter1);
while Letter1(1,:) == zeros(1,col)
    Letter1(1,:) = [];
    Letter1 = [Letter1 ;zeros(1,col)];
end
while Letter2(1,:) == zeros(1,col)
    Letter2(1,:) = [];
    Letter2 = [Letter2 ;zeros(1,col)];
end
while Letter3(1,:) == zeros(1,col)
    Letter3(1,:) = [];
    Letter3 = [Letter3 ;zeros(1,col)];
end
while Letter4(1,:) == zeros(1,col)
    Letter4(1,:) = [];
    Letter4 = [Letter4 ;zeros(1,col)];
end
while Letter5(1,:) == zeros(1,col)
    Letter5(1,:) = [];
    Letter5 = [Letter5 ;zeros(1,col)];
end

% Compute the HWT on Captchamat
its = 3;    % Number of iterations of the transform
h = sqrt(2)*Haar();
Letter1T = WT2D(Letter1, h, its);
Letter2T = WT2D(Letter2, h, its);
Letter3T = WT2D(Letter3, h, its);
Letter4T = WT2D(Letter4, h, its);
Letter5T = WT2D(Letter5, h, its);

% Take only the blur portion of the HWT
Letter1Blur = Letter1T(1:8,1:8);
Letter2Blur = Letter2T(1:8,1:8);
Letter3Blur = Letter3T(1:8,1:8);
Letter4Blur = Letter4T(1:8,1:8);
Letter5Blur = Letter5T(1:8,1:8);

% Import our character Bank for the comparisons
% Each row in Character_Bank.csv corresponds to the letter in order of
% {C D I L M V X 0 1 2 3 4 5 6 7 8 9}
known_characters=csvread('Character_Bank.csv');

% Compare each letter with those in our character bank
% The find_best_match function computes the values to determine the most
% likely character
Let1 = find_best_match(Letter1Blur, known_characters);
Let2 = find_best_match(Letter2Blur, known_characters);
Let3 = find_best_match(Letter3Blur, known_characters);
Let4 = find_best_match(Letter4Blur, known_characters);
Let5 = find_best_match(Letter5Blur, known_characters);

% Concatenate the "most likely" vectors into a matrix
Letters = [Let1,Let2,Let3,Let4,Let5];

% We want to find the smallest value in each columnn. Therfore we search
% each column to find the minimum value we save the row
% of the minimum value (save into characterpos)
% Initialize our vectors
characterpos = zeros(5,1);
for i = 1:5 % for each letter
  [M,I] = min(Letters(:,i));
  [I_row, I_col] = ind2sub(size(Letters(:,i)),I); % Find location of min
  characterpos(i) = I_row; % Save the row-number of minimum
end

% Our find_best_match function has issues distinguishing between L and I
% To fix this we will count the number of pixels and if the number of
% pixels is greater than 540, then the letter is and L. If the number of
% pixels is less than or equal to 540, then the letter is an I
for i = 1:5 % for each letterr
    if characterpos(i) == 3 % if computer thinks we have an I
        Letter = Charmatrix(:,64*(i-1)+1:64*i); % Take the letter
        pixels = 0;
        for j = 1:64 % Search each row and
            for k = 1:64 % Search each column
                if Letter(j,k) == 255 % If we find a white pixel
                    pixels = pixels + 1; % Add one
                end
            end
        end
        if pixels > 540 % Experimentally determined number
            characterpos(i) = 4; % We have an L
        else
            characterpos(i) = 3; % We have an I
        end 
    end
end

% We have our list of characters in alphabetical and numerical order
characters = char(['C','D','I','L','M','V','X','0','1','2','3','4','5','6','7','8','9']);

% Find the correspong entry in our character bank
% Initilize the string variable 
string = char(['A','A','A','A','A']);
for i = 1:5
    Letter = characterpos(i);
    string(i) = characters(Letter);
end

% Display string in a mesage box
Display = msgbox(string,'CAPTCHA');


end

