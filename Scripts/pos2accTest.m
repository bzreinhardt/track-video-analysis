%% Goal - get good acceleration data from the position data
% possibly useful function 'interp' 'pspline'

%% Define constants
m = 294.5/1000; %mass in kg
%%
load('15DegAnalyzedData.mat');
x_cart = x_cart/100; %positions in meters
%'t_cart','x_cart',...
%    'newMotorData','spinStartFrame','spinStopFrame'
%% Test moving polynomial fit 

%interpolate data
dt = t_cart(2)-t_cart(1);
dt_interp = dt/5; %interp by 5
t_cart_interp = t_cart(1):dt_interp:t_cart(end);
x_cart_interp = interp1(t_cart,x_cart,t_cart_interp); %positions in cm

%define window size
w = 201;
%define fit order
n = 2;
v = zeros(size(x_cart_interp));
a = zeros(size(x_cart_interp));
fits = zeros(3,size(x_cart_interp,2));
for i = 1:numel(x_cart_interp)
    
    if i < floor(w/2)+1
        time = t_cart_interp(1:w-1);
        pos = x_cart_interp(1:w-1);
        
        
    elseif i > numel(x_cart_interp)-floor(w/2)
        time = t_cart_interp(end-w:end);
        pos = x_cart_interp(end-w:end);
        
    else
    
        time = t_cart_interp((i-floor(w/2)):(i+floor(w/2)));
        pos = x_cart_interp((i-floor(w/2)):(i+floor(w/2)));
    end
    
        p = polyfit(time, pos, n);
        fits(:,i) = p';
        x_test = polyval(p,time);
        %Plot the windowed fits for debugging
%         figure(2);hold on;
%         plot(time,x_test,'k');
        v(i) = polyval([2*p(1),p(2)],t_cart_interp(i));
    
end
% find acceleration
a = 2 * fits(1,:); 
% find external force on cart
f = m*a; %yes, really.
%plot position, velocity, acceleration


figure(2);clf;
subplot(311)
plot(t_cart,x_cart,'r');hold on; plot(t_cart_interp,x_cart_interp,'g');
subplot(312); plot(t_cart_interp,v);

subplot(313);plot(t_cart_interp,f);





figure(1);clf;
plot(newMotorData.time,newMotorData.M1,newMotorData.time,newMotorData.M2); %plot motor data
ylabel(gca,'Motor Duty Cycle %');  %# Add a label to the left y axis
set(gca,'FontSize',16);
legend('Motor 1','Motor2');
limits = get(gca,'YLim');
set(gca,'Box','off');   %# Turn off the box surrounding the whole axes
axesPosition = get(gca,'Position');          %# Get the current axes position
hNewAxes = axes('Position',axesPosition,...  %# Place a new axes on top...
                'Color','none',...           %#   ... with no background color
                'YLim',limits*0.1,...            %#   ... and a different scale
                'YAxisLocation','right',...  %#   ... located on the right
                'XTick',[],...               %#   ... with no x tick marks
                'Box','off');                %#   ... and no surrounding box
ylabel(hNewAxes,'Force on Cart');  %# Add a label to the right y axis
set(gca,'FontSize',16);
hold on
plot(t_cart_interp,f,'r');
hold off;
legend('Force (N)');
%loop through data, generate polynomial fit for the window
% TEST: check that the fits look reasonable
%use polynomial fit's derivative evaluated at middle to find velocity

%repeat both steps to find acceleration

%% Test MATLAB Savitzky-Golay filter
N = 2;                 % Order of polynomial fit
F = 201;                % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients

HalfWin  = ((F+1)/2) -1;
SG0 = zeros(size(x_cart_interp));
SG1 = zeros(size(x_cart_interp));
SG2 = zeros(size(x_cart_interp));
for i = 1:numel(x_cart_interp)
    
    if i < (F+1)/2
        time = t_cart_interp(1:(F-1));
        pos = x_cart_interp(1:(F-1));
        p = polyfit(time, pos, N);
       
        SG0(i) = polyval(p,t_cart_interp(i));
        SG1(i) = polyval([2*p(1) p(2)],t_cart_interp(i));
        SG2(i) = polyval([2*p(1) ],t_cart_interp(i));
        %SG2(i) = 2*p(1);
    elseif i > numel(x_cart_interp)-(F+1)/2
        time = t_cart_interp(end-(F-1):end);
        pos = x_cart_interp(end-(F-1):end);
        p = polyfit(time, pos, N);
        
        SG0(i) = polyval(p,t_cart_interp(i));
       SG1(i) = polyval([2*p(1) p(2)],t_cart_interp(i));
        SG2(i) = polyval([2*p(1) ],t_cart_interp(i));
    end
end
for n = (F+1)/2:numel(x_cart_interp)-(F+1)/2,
  % Zero-th derivative (smoothing only)
  SG0(n) =   dot(g(:,1), x_cart_interp(n - HalfWin: n + HalfWin));
  
  % 1st differential
  SG1(n) =   dot(g(:,2), x_cart_interp(n - HalfWin: n + HalfWin))/dt_interp;
  
  % 2nd differential
  SG2(n) = 2*dot(g(:,3), x_cart_interp(n - HalfWin: n + HalfWin))/(dt_interp*dt_interp);
end

dir = pwd;
if ~strcmp(dir(end-5:end),'Images')
    cd Images
end

figure(3);clf;
subplot(411);
plot(t_cart_interp,x_cart_interp);
title('Image Processed X Data');
subplot(412);

plot(t_cart_interp,SG0);
title('Filtered X Data');
subplot(413);

plot(t_cart_interp,SG1);
title('Velocity from differentiated X Data');
subplot(414);

plot(t_cart_interp,SG2);
title('Acceleration from twice-differentiated V Data');
print -djpeg -f3 -r300 all_data

%% Test Interp-->2 Derivatives --> Butterworth Filter
x_cart_spline = spline(t_cart,x_cart,t_cart_interp);
v_cart_spline = (x_cart_spline(2:end)-x_cart_spline(1:end-1))/dt_interp;
a_cart_spline = (v_cart_spline(2:end)-v_cart_spline(1:end-1))/dt_interp;
t_spline = t_cart_interp(1:end-2);

order = 9;
wn = 1*dt_interp*2;
[z,p,k] = butter(order,wn);
[sos,g] = zp2sos(z,p,k);	     % Convert to SOS form
a_filtfilt = filtfilt(sos,g,a_cart_spline); %filter the data
figure(5);clf; plot(t_spline, a_filtfilt); 

