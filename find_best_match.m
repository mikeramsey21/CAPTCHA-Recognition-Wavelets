function [ best_match ] = find_best_match( blur_vector, known_character_blurs )
% This is a function that inputs an 8x8 matrix (which is the blur
% portion of a 64x64 matrix reshaped as a vector), and computes the
% "closeness" to the known_character_blurs as the other input argument. Our
% character blurs come from Character_Bank.csv for this particlar project,
% which are length 64 row vectors.

% Initialize the errors variable
errors=zeros(17,1);

% A for loop to calculate the "closenesss" to each character. We calculate
% closeness by using the 2 norm
for i=1:17
    % We need to reshape known_character_blurs into an 8x8 matrix because
    % initially it is a length 64 row vector
    % Each row of known_character_blurs corresponds to a letter in the bank
    % in alphabetic then numberical order
    errors(i)=norm(blur_vector - reshape(known_character_blurs(i,:),8,8));
end

% Output the errors vector for this function
best_match=errors;
end