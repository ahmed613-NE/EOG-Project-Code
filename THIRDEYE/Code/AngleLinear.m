%%Example

% Specify the file path
% BYBevents = 'C:\Users\74147\Downloads\BYB_Recording_2024-10-03_14.03.33-events.txt';
% Angles = [0 10 0 20 0 30 0 40 0 50 0 -10 0 -20 0 -30 0 -40 0 -50];
% 
% Events = Angleliner(BYBevents,Angles); 

% in the later readings, make sure the label is correct. 
%%
function Events = Angleliner(BYBEvents,Angles)
labeltime = importdata(BYBEvents);
Label = zeros(1,length(labeltime));

time = zeros(1,length(labeltime));
for i=1:length(labeltime)
reading = labeltime{i};
reading= sscanf(join(reading,''),'[%f,%f]',[2,inf]).';
Label(i)=reading(1);
time(i)=reading(2);
end
lengthevent = length(Label);
lengthAngle = length(Angles);
keyboard
if lengthevent < lengthAngle
Events = [Label;time;Angles(1:length(Label))]';
else
Events = [Label(1:length(Angles));time(1:length(Angles));Angles]';
end
end
