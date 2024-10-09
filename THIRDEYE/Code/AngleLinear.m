%%Example

% Specify the file path
% BYBevents = 'C:\Users\74147\Downloads\BYB_Recording_2024-10-03_14.03.33-events.txt';
% Angles = [0 10 0 20 0 30 0 40 0 50 0 -10 0 -20 0 -30 0 -40 0 -50];
% 
% Events = Angleliner(BYBevents,Angles); 

% in the later readings, make sure the label is correct. 
%%
function Events = AngleLiner(BYBEvents,Angles)
labeltime = readtable(BYBEvents);
Label = zeros(1,height(labeltime));

time = zeros(1,height(labeltime));
for i=1:height(labeltime)
    % keyboard
reading = labeltime(i,:);
reading = table2array(reading);
% reading= sscanf(join(reading,''),'[%f,%f]',[2,inf]).';
Label(i)=reading(1,1);
time(i)=reading(1,2);
end
if width(labeltime)>2
    Events = table2array(labeltime);
    
else
lengthevent = length(Label);
lengthAngle = length(Angles);
if lengthevent < lengthAngle
Events = [Label;time;Angles(1:length(Label))]';
disp('Hmmm We get less marker than we should')
else
Events = [Label(1:length(Angles));time(1:length(Angles));Angles]';
disp('That looks about right')
end
end
end
