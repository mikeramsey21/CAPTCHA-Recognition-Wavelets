% This is a matlab file that creates captcha letters similar to the one used by
% the Holiday Inn Priority Club
% This particular file is used to make the Captcha Letters for the
% Character Bank
% All you need to do is change the R value to the particular character that
% you want

% Create Database of character
characters = char(['I','V','X','C','D','L','M','0','1','2','3','4','5','6','7','8','9']);

R = '9';
% Generate random string on a plot
% Formatting the plot, activating the grid
set(gca,'XTick',0:.05:1);
set(gca,'YTick',0:.05:1);
set(gca,'XTickLabel','');
set(gca,'YTickLabel','');
set(gca,'GridLineStyle','-');
grid on;

% Place the random string called R on plot
h = text(.5,.5,['\fontsize{58}', ... % Font size
    '\fontname{Helvetica}','\color{gray}',R]); %Font style/color
