% This is a matlab file that creates a captcha similar to the one used by
% the Holiday Inn Priority Club
% Just simply run the file and it generates a random string of 5 letters in
% a captcha

% Create Database of character
characters = char(['I','V','X','C','D','L','M','0','1','2','3','4','5','6','7','8','9']);
charlength = length(characters); % Comupte the size of our database

% We want a string of 
len = 5;

% Generate random characters from bank, save as R
i = ceil(charlength*rand(1,len));
R = characters(i);

% Generate random string on a plot
% Formatting the plot, activating the grid
set(gca,'XTick',0:.05:1);
set(gca,'YTick',0:.05:1);
set(gca,'XTickLabel','');
set(gca,'YTickLabel','');
set(gca,'GridLineStyle','-');
grid on;

% Place the random string called R on plot
h = text(.4*rand,.2+.6*rand,['\fontsize{58}', ... % Font size
    '\fontname{Helvetica}','\color{gray}',R]); %Font style/color
set(h,'Rotation',-10 + 20*rand); % Rotation between -10 and 10 degrees
