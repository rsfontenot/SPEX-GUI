global voltage Slit_Width MinVoltage MaxVoltage IntTime  SPEX_Wavelength VaryWavelength_Ans ...
    VaryVoltage_Ans MinWavelength MaxWavelength End_Wavelength ...
    Inc_Wavelength Inc_Voltage dname scram FullDir NumRuns ContMeasurement WarnContMeasurement SPEX PMT;


%% Opening the SpecControl GUI
f=SpecControl;
handles=guidata(f);
hold on


set(handles.VoltageMax, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.VoltageMin, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.Wavelength_Max, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.Wavelength_Min, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.Inc_Wavelength, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.Voltage, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.IntTime, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.SPEX_Slit, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.Desired_Wavelength, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.IncVoltage, 'enable', 'off', 'FontWeight', 'bold', 'background', 'white')
set(handles.NumberOfRuns, 'enable', 'off', 'FontWeight', 'bold')

%%Continuous Measurement Check
if WarnContMeasurement == 1;
    error('Continuous measurement can only occur for constant voltage and wavelength! Program is closing!')
end

%% Setting up communications with the PMT

%delete(instrfindall) %deletes all instruments so Matlab can initialize PMT.
PMT=serial('COM5'); %creates the serial object in this case PMT tube

% This writes the correct PMT settings specified by the manufacturer.

PMT.BaudRate=9600; %The following are the manufacturer specifications
PMT.DataBits=8; 
PMT.StopBits=1; 
PMT.Terminator='CR';
PMT.Parity='none';
PMT.FlowControl='none';

% Communicating with the PMT

fopen(PMT);
PMT.ReadAsyncMode='continuous';
set(handles.Messages, 'String', 'PMT setup successful');
pause(1.5)

%% Setting up communications with the SPEX Monochromator
SPEX=gpib('ni',0,3); %creates the gpib object for the SPEX
fopen(SPEX)
SPEX.EOIMode = 'off';
SPEX.EOSMode = 'none';
%obj2.Timeout = 100
fprintf(SPEX,'%s',' ');
check = char(fread(SPEX,1))

if check == 'B'
    fwrite(SPEX,uint8([79; 50; 48; 48; 48; 0])) %Mean O2000\0
    char(fread(SPEX,1))
    fwrite(SPEX,uint8([65])) %A (initialze motor)
    ptime(120)
    char(fread(SPEX,1))
    set(handles.Messages, 'string', 'SPEX Monochromator successfully initialized')
elseif check == 'o'
    set(handles.Messages, 'string', 'Monochromator is not in the correct state. Restart!')
    error('Monochromator is not in the correct state. Restart!')
elseif check == 'F'  
    set(handles.Messages, 'string', 'Monochromator is not in the correct state. Restart!')
    error('Monochromator is not in the correct state. Restart!')
else 
    set(handles.Messages, 'string', 'Monochromator in weird state. Restart!')
    error('Monochromator in weird state. Restart!')
end

%% Setting up the Slits

%fwrite(SPEX,uint8([105;48;44;48;44;48;13]))
%char(fread(SPEX,1))
SPEX.EOSMode = 'read';
SPEX.EOSCharCode = 13;
fwrite(SPEX, uint8([69]))
 busy = fread(SPEX,2)
 while busy(2) == 113
     disp('Motor is busy')
     ptime(30)
     fwrite(SPEX, uint8([69]))
     busy = fread(SPEX,1)
 end
    

fwrite(SPEX,uint8([106;48;44;48;13]))
%char(fread(obj2,1))
sline = 1; i=1;
while sline ~= 13
    sline (i) = fread(SPEX,1);
    i=i+1;
end
startSlitEntPosition = str2num(char(sline(2:length(sline)-1)'))

fwrite(SPEX,uint8([106;50;44;48;13]))
sline = 1; i=1;
while sline ~= 13
    sline(i) = fread(SPEX,1);
    i=i+1;
end
startSlitExitPosition = str2num(char(sline(2:length(sline)-1)'))
whos
pause(120)
SlitStepsToMove = double(transpose(int2str((Slit_Width*80 - startSlitEntPosition))))
char(SlitStepsToMove)
fwrite(SPEX, uint8([107;48;44;48;44; SlitStepsToMove; 13]))
%fwrite(SPEX, uint8([107;48;44;48;44; 49; 50; 48; 13]))
pause(5)
fread(SPEX,1)


% if Slit_Width * 1.2 <=14.0
%     ExitSlitsStepsToMove = double(transpose(int2str((Slit_Width*80*1.2 - startSlitExitPosition))))
% else
%     ExitSlitsStepsToMove = double(transpose(int2str((Slit_Width*80 - startSlitExitPosition))))
% end
% 
% pause(120)
% fwrite(SPEX, uint8([107;48;44;51;44; ExitSlitsStepsToMove; 13]))
% pause(5)
% fread(SPEX,1)

%% Setting the SPEX Wavlength

%SPEX.EOSMode = 'read';
%SPEX.EOSCharCode = 13;
fwrite(SPEX, uint8([72;48;13]))
tline = fread(SPEX)
%SPEX.EOSMode = 'none';
SPEX_Wavelength = 0.03125*str2num(char(tline(2:length(tline)-1)'))-7.8415;
%SPEX.EOSMode = 'none';
%The 7.5729 takes into the account the callibration error of the 270M. 

%% Setting the voltage

switch VaryVoltage_Ans
    case 0
    if voltage == 'D'
        fwrite(PMT,uint8(hex2dec(['44'; '0D'])))
        pause(0.5)
        PMTErrorCheck(1,PMT)
        set(handles.Messages, 'string', 'Voltage Set to Default')
    elseif voltage >= 0 & voltage <= 1200
        fwrite(PMT,uint8([86; bitshift(voltage,-8); bitand(voltage,255); 13])) %set voltage to #
        PMTErrorCheck(1,PMT)
        set(handles.Messages, 'string', sprintf('Voltage Set to %d V.', voltage))
    else
        fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
        error('Invalid Voltage! Program shutdown and voltage set to 0')
    end
    otherwise 
      disp('Varying voltage chosen')
end

%% Setting the Integration time

switch rem(IntTime,1)
    case 0
        if IntTime < 0.01 
            set(handles.Messages, 'string', 'Incorrect Integration Time. Program is now exiting!')
            error('Integration time must be greater than 10 ms and less than 1 s')
        end
    otherwise
        if IntTime < 0.01 | rem(IntTime,1)<0.01
            set(handles.Messages, 'string', 'Incorrect Integration Time. Program is now exiting!')
            error('Integration time must be greater than 10 ms and less than 1 s')
        end
end    


%% Moving the Monochromator to the Desired Wavelength

switch VaryWavelength_Ans
    case 0
if End_Wavelength <=1100 & End_Wavelength >=0
    StepsToMove=double(transpose(int2str(((End_Wavelength-SPEX_Wavelength)*32))));
    fwrite(SPEX,uint8([70; 48; 44; StepsToMove; 13])); %Moves the grating!
    ptime(120)
    set(handles.Messages, 'string', sprintf('The Monochromator has moved to %d nm.', End_Wavelength))
    SPEX_Wavelength = End_Wavelength;
else
    set(handles.Messages, 'string', 'Monochromator Limits Exceeded!!! Choose a wavelength between 100 and 1100')
    error('Monochromator Limits Exceeded!!! Choose a wavelength between 100 and 1100')
end
    case 1
        disp('Varying wavelength chosen')
end

%% The case for a continuous run

if ContMeasurement == 1;
    %Setting up the files to be written
    fid1=fopen(fullfile(FullDir,'Continuous_Measurements_Results.txt'), 'w');
    %fid2=fopen(fullfile(FullDir,'Continuous_Measurements_Results.xlsx'), 'w');
    fname3=fullfile(FullDir,'Continuous_Measurements_Results.xlsx');
    
    %Writing the headers of the files
    fprintf(fid1, 'The wavelength for this test is %d nm. \r\n',End_Wavelength);
    fprintf(fid1, 'The voltage for this test is %d V. \r\n',voltage); 
    fprintf(fid1, 'The integration time of the PMT is %0.2f s. \r\n', IntTime);
    fprintf(fid1, '%s \t %s\r\n','Elapsed Time (s)', 'Counts');
    xlswrite(fname3, {'Elapsed Time (s)'}, 'Continuous Measurement', 'A1');
    xlswrite(fname3, {'Counts'},'Continuous Measurement', 'B1');
   
    
    %Writing the Experimental Data to the file
    xlswrite(fname3, {'Voltage'}, 'Experiment Conditions', 'A1');
    xlswrite(fname3, voltage, 'Experiment Conditions', 'B1');
    xlswrite(fname3, {'Wavelength'}, 'Experiment Conditions', 'A2')
    xlswrite(fname3, End_Wavelength, 'Experiment Conditions', 'B2')
    xlswrite(fname3, {'Integration Time (s)'}, 'Experiment Conditions', 'A3')
    xlswrite(fname3, IntTime, 'Experiment Conditions', 'B3')
    
    N=10; t=1;
    SatCheck=0;
    CheckCount = 0;
    tstart = tic;
    while N<100;
        [tcount, NewSatCheck] = InfIntTime(IntTime,PMT,SatCheck,handles);
        SatCheck = NewSatCheck;
        counts(t)= tcount;
        telapsed(t) = toc(tstart);
            
        set(handles.Messages, 'String', ...
        sprintf('Time Elapsed: %0.0f s \n Counts: %0.0f', ...
        [telapsed(t) counts(t)]));
    
        %Graphing the plot
        handles.Graph =plot(telapsed, counts, '-or', 'LineWidth', 1.5);
        xlabel('\bf Elapsed Time \rm (s)')
        ylabel('\bf Counts')
        drawnow;
        
        %Saving the Data
        fprintf(fid1, '%0.4f \t %d\r\n',[telapsed(t); counts(t)]);
        ETime = strcat('A',num2str(t+1));
        StrCounts = strcat('B',num2str(t+1));
        xlswrite(fname3,telapsed(t),'Continuous Measurement', ETime)
        xlswrite(fname3,counts(t),'Continuous Measurement', StrCounts)
        if scram == 1
           msgbox('Emergency Shutdown Procedure Initiated!!!')
           fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
           figure
           plot(telapsed, counts, '-or', 'LineWidth', 1.5)
           xlabel('\bf Elapsed Time \rm (s)')
           ylabel('\bf Counts')
           saveas(gcf,'Continuous Run', 'tiffn')
           saveas(gcf,'Continuous Run', 'jpg')
           fclose('all');
           error('Emergency Shutdown Procedure Initiated!!!')
        end
        t=t+1;
    end
end

%% The Case of Varying Voltage and Single Wavelength

if VaryWavelength_Ans == 0 & VaryVoltage_Ans == 1
%FullDir=sprintf('%s\\Results',dname);
fid1=fopen(fullfile(FullDir,'PMT_Varying_Results.txt'), 'w');
%fid2=fopen(fullfile(FullDir,'PMT_Varying_Results.xlsx'), 'w');
fname3=fullfile(FullDir,'PMT_Varying_Results.xlsx');
fprintf(fid1, 'The wavelength for this test is %d nm. \r\n',End_Wavelength); 
fprintf(fid1, '%s \t %s\r\n','Voltage (V)', 'Counts');    
SatCheck=0;
N=1;
for N=1:1:NumRuns
    Voltage_Plot=zeros(length(1:1:NumRuns),length(MinVoltage:Inc_Voltage:MaxVoltage));
    VoltageNew = 1;
    start=1;
    for Voltage=MinVoltage:Inc_Voltage:MaxVoltage
    f=SpecControl;
    handles=guidata(f);
    fwrite(PMT,uint8([86; bitshift(Voltage,-8); bitand(Voltage,255); 13])) %set voltage to #
    PMTErrorCheck(1,PMT)
    if VoltageNew ==1
        ptime(30)
        cla
    else
        pause(0.5)
    end
    fwrite(PMT,uint8(hex2dec(['53'; '0D'])));
    pause(1.1)
    sol=fread(PMT,PMT.BytesAvailable);
    if sol(1)==255
        SatCheck=SatCheck+1;
        set(handles.PMT_Saturation, 'background', 'red');
    else
        set(handles.PMT_Saturation, 'background', 'green');
    end
    if SatCheck==3
        fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
        msgbox('Program shutdown due to too much light! Reduce Integration time or light!')
        error('Too much light! 3 saturation readings!')
    end
    counts(N,start)= sol(1)*16777216 +sol(2)*65536 + sol(3)*256 + sol(4);
    fprintf(fid1, '%0.3f \t %0.3f\r\n',[Voltage; counts(start)]);
    Voltage_Plot(N,start)=Voltage;
    set(handles.Messages, 'String', ...
    sprintf('Run Number: %d \n Current Voltage: %d V \n Current Counts: %d \n Total Counts: %d', ...
    [N Voltage_Plot(N,start) counts(N,start) sum(counts(1:1:N,start))]));
    
    %Graphing the total plots
    handles.Graph =plot(sum(Voltage_Plot(:,start),1), sum(counts(1:1:N,start)), '-or', 'LineWidth', 1.5);
    xlabel('\bf Voltage \rm (V)')
    ylabel('\bf Counts')
    start=start+1;
    VoltageNew = 0;
    drawnow;
       if scram == 1
           msgbox('Emergency Shutdown Procedure Initiated!!!')
           fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
           error('Emergency Shutdown Procedure Initiated!!!')
       end
    end
if N == 1
  xlswrite(fname3,Voltage_Plot(1,:)','Varying Voltage', 'A2')
  xlswrite(fname3,{'Voltage'},'Varying Voltage', 'A1') 
end

if N ~= NumRuns
    ExcelString = strcat(xlsColNum2Str(N+1),'2');
    ExcelStringHead = strcat(xlsColNum2Str(N+1),'1');
    xlswrite(fname3,counts(N,:)','Varying Voltage', ExcelString{1})
    xlswrite(fname3,{'Counts'},'Varying Voltage', ExcelStringHead{1})
else
    ExcelString = strcat(xlsColNum2Str(N+1),'2');
    ExcelStringHead = strcat(xlsColNum2Str(N+1),'1');
    xlswrite(fname3,counts(N,:)','Varying Voltage', ExcelString{1})
    xlswrite(fname3,{'Counts'},'Varying Voltage', ExcelStringHead{1})
end

%xlswrite(fname3,Voltage_Plot(1),'Varying Voltage', xlsColNum2Str(N+1))
%cla
N=N+1;
end
%xlswrite(fname3,counts(N),'Varying Voltage', xlsColNum2Str(1))
fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
hold off
figure
plot(Voltage_Plot(:,1), sum(counts(:,1)), '-or', 'LineWidth', 1.5)
xlabel('\bf Voltage \rm (V)')
ylabel('\bf Counts')
saveas(gcf,'Varying_Voltage', 'tiffn')
saveas(gcf,'Varying_Voltage', 'jpg')
end

%% The Case of varying wavelength and constant voltage

if VaryWavelength_Ans == 1 & VaryVoltage_Ans == 0
FullDir=sprintf('%s\\Results',dname);
%fid1=fopen(fullfile(FullDir,'Varying_Wavelength_Results.txt'), 'w');
%fid2=fopen(fullfile(FullDir,'Wavelength_Varying_Results.xlsx'), 'w');
%fprintf(fid1, 'The voltage for this test is %d V. \r\n',voltage); 
%fprintf(fid1, '%s \t %s\r\n','Wavelength (nm)', 'Counts');    
start=1;
SatCheck=0;



    %Setting up the files to be written
    fid1=fopen(fullfile(FullDir,'Wavelength_Varying_Results.txt'), 'w');
    %fid2=fopen(fullfile(FullDir,'Continuous_Measurements_Results.xlsx'), 'w');
    fname2=fullfile(FullDir,'Wavelength_Varying_Results.xlsx');
    
    %Writing the headers of the files
    fprintf(fid1, 'The wavelength for this test is %d nm. \r\n',End_Wavelength);
    fprintf(fid1, 'The voltage for this test is %d V. \r\n',voltage); 
    fprintf(fid1, 'The integration time of the PMT is %0.2f s. \r\n', IntTime);
    fprintf(fid1, '%s \t %s\r\n','Elapsed Time (s)', 'Counts');
    xlswrite(fname2, {'Elapsed Time (s)'}, 'Continuous Measurement', 'A1');
    xlswrite(fname2, {'Counts'},'Continuous Measurement', 'B1');
   
    
    %Writing the Experimental Data to the file
    xlswrite(fname2, {'Voltage'}, 'Experiment Conditions', 'A1');
    xlswrite(fname2, voltage, 'Experiment Conditions', 'B1');
    xlswrite(fname2, {'Wavelength'}, 'Experiment Conditions', 'A2')
    xlswrite(fname2, End_Wavelength, 'Experiment Conditions', 'B2')
    xlswrite(fname2, {'Integration Time (s)'}, 'Experiment Conditions', 'A3')
    xlswrite(fname2, IntTime, 'Experiment Conditions', 'B3')
    


% Setting the Constant Voltage
    if voltage == 'D'
        fwrite(PMT,uint8(hex2dec(['44'; '0D'])))
        pause(0.5)
        PMTErrorCheck(1,PMT)
        set(handles.Messages, 'string', 'Voltage Set to Default')
    elseif voltage >= 0 & voltage <= 1200
        fwrite(PMT,uint8([86; bitshift(voltage,-8); bitand(voltage,255); 13])) %set voltage to #
        PMTErrorCheck(1,PMT)
        set(handles.Messages, 'string', sprintf('Voltage Set to %d V.', voltage))
    else
        error('Invalid Voltage! Program shutdown and voltage set to 0')
        fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
    end
    
%Varying the Wavelength

PauseTime = Inc_Wavelength*0.1;
if MinWavelength <=1100 & MinWavelength >=0
    StepsToMove = double(transpose(int2str(((MinWavelength-SPEX_Wavelength)*32))));
    fwrite(SPEX,uint8([70; 48; 44; StepsToMove; 13])); %Moves the grating!
    pause(0.1)
    char(fread(SPEX,1));
    set(handles.Messages, 'string', sprintf('The Monochromator has moved to %d nm.', MinWavelength))
    SPEX_Wavelength = MinWavelength;
else
    set(handles.Messages, 'string', 'Monochromator Limits Exceeded!!! Choose a wavelength between 100 and 1100')
    error('Monochromator Limits Exceeded!!! Choose a wavelength between 100 and 1100')
end

ptime(120);
Wavelength_Plot=zeros(length(1:1:NumRuns),length(MinWavelength:Inc_Wavelength:MaxWavelength));

%% Setting up the Monochromator

%Checking the slit position for Entrance Slit

fwrite(SPEX, uint8([106;48;44;48;13]))
pause(1)
fread(SPEX,1)
sline = 1; i=1;
while sline ~= 13
    sline(i) = fread(SPEX,1);
    i=i+1;
end
slitCheck = str2num(char(sline));

%Opening the slit all the way aka 1120 steps or 14 mm

if slitCheck == 0
    fwrite(SPEX, uint8([107;48;44;48;44;49;49;50;48;13;]))
    pause(120)
    fread(SPEX,1)
    disp('Enterance Slit is now fully open')
else
    error('set the slit to zero')
end

fwrite(SPEX, uint8([106;48;44;48;13]))
pause(1)
fread(SPEX,1)
sline2 = 1; i=1;
while sline2 ~= 13
    sline2(i) = fread(SPEX,1);
    i=i+1;
end
slitCheck2 = str2num(char(sline2));

%Checking the slit position for Exit Slit

fwrite(SPEX, uint8([106;48;44;51;13]))
pause(1)
fread(SPEX,1)
ExitSline = 1; i=1;
while ExitSline ~= 13
    ExitSline(i) = fread(SPEX,1);
    i=i+1;
end
ExitslitCheck = str2num(char(ExitSline));

%Opening the slit all the way aka 1120 steps or 14 mm

if ExitslitCheck == 0
    fwrite(SPEX, uint8([107;48;44;51;44;49;49;50;48;13]))
    pause(120)
    fread(SPEX,1)
    disp('Exit Slit is now fully open')
else
    error('set the slit to zero')
end

fwrite(SPEX, uint8([106;48;44;50;13]))
pause(1)
fread(SPEX,1)
ExitSline2 = 1; k=1;
while ExitSline2 ~= 13
    ExitSline2(k) = fread(SPEX,1);
    k=k+1;
end
ExitslitCheck2 = str2num(char(ExitSline2));

N=1;
for N=1:1:NumRuns
    %WavelengthNew = 1;
    start=1;
for Wavelength=MinWavelength:Inc_Wavelength:MaxWavelength
    f=SpecControl;
    handles=guidata(f);
    [tcount, NewSatCheck] = InfIntTime(IntTime,PMT,SatCheck,handles);
    SatCheck = NewSatCheck;
    StepsToMoveInc = double(transpose(int2str(((Inc_Wavelength)*32))));
    %fwrite(PMT,uint8(hex2dec(['53'; '0D'])));
    %pause(1.1)
    %sol=fread(PMT,PMT.BytesAvailable);
    %if sol(1)==255 
    %    SatCheck=SatCheck+1;
    %    set(handles.PMT_Saturation, 'background', 'red');
    %else
    %    set(handles.PMT_Saturation, 'background', 'green');
    %end
    %if SatCheck==3
    %    fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
    %    msgbox('Program shutdown due to too much light! Reduce Integration time or light!')
    %    error('Too much light! 3 saturation readings!')
    %end
    %counts(N,start)= sol(1)*16777216 +sol(2)*65536 + sol(3)*256 + sol(4);
    counts(N,start) = tcount;
    fprintf(fid1, '%0.3f nm\t %0.0f\r\n',[Wavelength; counts(start)]);
    Wavelength_Plot(N,start)=Wavelength;
    
    set(handles.Messages, 'String', ...
    sprintf('Run Number: %0.0f \n Current Wavelength: %0.3f nm \n Current Counts: %d \n Total Counts: %0.0f', ...
    [N Wavelength_Plot(N,start) counts(N,start) sum(counts(1:1:N,start))]));
    
    handles.Graph = plot(Wavelength_Plot(1,start), sum(counts(1:1:N,start),1), '*r', 'LineWidth', 1.5);
    xlabel('\bf Wavelength \rm (nm)')
    ylabel('\bf Counts')
    %set(handles.Messages, 'String', sprintf('Current Wavelength: %d nm \n Current Counts: %d',[Wavelength_Plot(start) counts(start)]));
    start=start+1;
    drawnow;
       if scram == 1
           msgbox('Emergency Shutdown Procedure Initiated!!!')
           fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
           error('Emergency Shutdown Procedure Initiated!!!')
       end
   % fwrite(SPEX,uint8([50;50;50]))
   % pause(0.3)
    fwrite(SPEX,uint8([70; 48; 44; StepsToMoveInc; 13])); %Moves the grating!
    char(fread(SPEX,1));
    pause(PauseTime);
    fwrite(SPEX, uint8([32]))
    char(fread(SPEX,1))
    SPEX_Wavelength = Wavelength
end
if N == 1
    xlswrite(fname2,Wavelength_Plot(1,:)','Varying Wavelength', 'A2')
    xlswrite(fname2,{'Wavelength'},'Varying Wavelength', 'A1') 
end
if N ~= NumRuns
    ExcelString = strcat(xlsColNum2Str(N+1),'2');
    ExcelStringHead = strcat(xlsColNum2Str(N+1),'1');
    xlswrite(fname2,counts(N,:)','Varying Wavelength', ExcelString{1})
    xlswrite(fname2,{'Counts'},'Varying Wavelength', ExcelStringHead{1})
N=N+1;
StepsToMoveNew = double(transpose(int2str(((MinWavelength-MaxWavelength)*32-32*Inc_Wavelength))));
fwrite(SPEX,uint8([70; 48; 44; StepsToMoveNew; 13]));
char(fread(SPEX,1));
ptime(120)
clear StepsToMoveInc;
cla
else
    ExcelString = strcat(xlsColNum2Str(N+1),'2');
    ExcelStringHead = strcat(xlsColNum2Str(N+1),'1');
    xlswrite(fname2,counts(N,:)','Varying Wavelength', ExcelString{1})
    xlswrite(fname2,{'Counts'},'Varying Wavelength', ExcelStringHead{1})
end

end
hold off
figure
plot(Wavelength_Plot(1,:), sum(counts,1), '-r', 'LineWidth', 1.5)
xlabel('\bf Wavelength \rm (nm)')
ylabel('\bf Counts')
ax=gca;
set(ax, 'XMinorTick','on', 'YMinorTick','on')
set(gca, 'YTickLabel', num2str(transpose(get(gca,'YTick'))))
saveas(gcf,'Varying_Wavelength', 'tiffn')
saveas(gcf,'Varying_Wavelength', 'jpg')
saveas(gcf,'Varying_Wavelength', 'fig')
saveas(gcf,'Varying_Wavelength', 'm')
fwrite(PMT,uint8([86; bitshift(0,-8); bitand(0,255); 13]))
end

%% Closing the program
fwrite(SPEX, uint8([107;48;44;48;44;45; SlitStepsToMove; 13]))
fread(SPEX,1)
pause(60)
fwrite(SPEX, uint8([107;48;44;51;44;45; ExitSlitsStepsToMove; 13]))
fread(SPEX,1)
msgbox('I am done!')
fclose('all')

