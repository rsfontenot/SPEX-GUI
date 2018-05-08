clear all
close all
fclose('all')

%% Setting up the global variables
global voltage Slit_Width MinVoltage MaxVoltage IntTime  SPEX_Wavelength VaryWavelength_Ans ...
    VaryVoltage_Ans MinWavelength MaxWavelength End_Wavelength ...
    Inc_Wavelength Start Inc_Voltage dname scram FullDir NumRuns ContMeasurement WarnContMeasurement;

%%Setting up the save location folder

dname = uigetdir('C:\Users\MathurVK\Desktop\'); %This sets the directory where the files to be abalyzed are created.
if exist('SPEX and MONO Test')==0
    mkdir(dname,'Results'); % This creates a new folder to move the selected files. 
else
    beep
    msgbox('A folder called Results already exists! Change folder name!')
    error('A folder called Results already exists! Change folder name!')
end

FullDir = sprintf('%s\\Results',dname);


%% Opening the SpecControl GUI
f=SpecControl;
handles=guidata(f);

voltage = [];
MinVoltage = 1000;
MaxVoltage = 1200;
IntTime = [];
VaryVoltage_Ans = 0;
SPEX_Wavelength = [];
VaryWavelength_Ans = 0;
MinWavelength = 100;
MaxWavelength = 1000;
End_Wavelength = [];
Inc_Wavelength = 1;
Start = 0;
Inc_Voltage = 5;
scram = 0;
NumRuns = 1;
ContMeasurement = 0;
WarnContMeasurement = 0;
Slit_Width = 0

%% Setting up the default settings for the program
set(handles.Start, 'enable', 'off')
set(handles.Messages, 'Max', 2)
set(handles.VoltageMax, 'enable', 'off')
set(handles.VoltageMin, 'enable', 'off')
set(handles.Wavelength_Max, 'enable', 'off')
set(handles.Wavelength_Min, 'enable', 'off')
set(handles.Inc_Wavelength, 'enable', 'off')
set(handles.IncVoltage, 'enable', 'off')
set(handles.VaryingWavelength, 'Value', 0)
set(handles.VaryVoltage, 'Value', 0)
set(handles.Graph, 'visible', 'on');
get(handles.VaryingWavelength)
get(handles.VaryVoltage)
set(handles.PMT_Saturation, 'Visible', 'off')
set(handles.Messages, 'String', 'Program Messages')
set(handles.Messages, 'FontSize', 12, 'FontName', 'Times New Roman')
