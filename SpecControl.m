function varargout = SpecControl(varargin)
% SPECCONTROL MATLAB code for SpecControl.fig
%      SPECCONTROL, by itself, creates a new SPECCONTROL or raises the existing
%      singleton*.
%
%      H = SPECCONTROL returns the handle to a new SPECCONTROL or the handle to
%      the existing singleton*.
%
%      SPECCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECCONTROL.M with the given input arguments.
%
%      SPECCONTROL('Property','Value',...) creates a new SPECCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpecControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpecControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpecControl

% Last Modified by GUIDE v2.5 27-Oct-2015 11:36:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpecControl_OpeningFcn, ...
                   'gui_OutputFcn',  @SpecControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpecControl is made visible.
function SpecControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpecControl (see VARARGIN)

% Choose default command line output for SpecControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpecControl wait for user response (see UIRESUME)
% uiwait(handles.DataPlot);


% --- Outputs from this function are returned to the command line.
function varargout = SpecControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function Voltage_Callback(hObject, eventdata, handles)
% hObject    handle to Voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Voltage as text
%        str2double(get(hObject,'String')) returns contents of Voltage as a double

Current_Voltage = get(handles.Voltage, 'String')
global voltage End_Wavelength MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;

    switch isletter(Current_Voltage(1))
        case 1
            if length(Current_Voltage)>1
               set(hObject, 'BackgroundColor', [1 0 0])
                MinVoltage = [];
                MaxVoltage = [];
                StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
            elseif Current_Voltage == 'D'
                set(hObject, 'BackgroundColor', [0 1 0])
                handles.Voltage = 'D'
                voltage = 'D'
                MinVoltage = 1;
                MaxVoltage = 1;
                StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
            else
                set(hObject, 'BackgroundColor', [1 0 0])
                MinVoltage = [];
                MaxVoltage = [];
                StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
            end
        case 0
            if str2num(Current_Voltage) < 0 | str2num(Current_Voltage)>1200
                set(hObject, 'BackgroundColor', [1 0 0])
                MinVoltage = [];
                MaxVoltage = [];
                StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
            else
                set(hObject, 'BackgroundColor', [0 1 0])
                handles.Voltage = str2num(Current_Voltage);
                voltage = str2num(Current_Voltage);
                MinVoltage = 100;
                MaxVoltage = 1100;
                StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
            end
    end



% --- Executes during object creation, after setting all properties.
function Voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IntTime_Callback(hObject, eventdata, handles)
% hObject    handle to IntTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IntTime as text
%        str2double(get(hObject,'String')) returns contents of IntTime as a double
global voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;

Current_IntTime = get(handles.IntTime, 'String')

switch rem(str2num(Current_IntTime),1)
    case 0
if str2num(Current_IntTime) < 0.01 
            set(hObject, 'BackgroundColor', [1 0 0])
            handles.IntTimeHandle = false;
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
        else
            set(hObject, 'BackgroundColor', [0 1 0])
            handles.IntTime = str2num(Current_IntTime);
            IntTime = str2num(Current_IntTime);
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end
    otherwise
        if str2num(Current_IntTime) < 0.01 | rem(str2num(Current_IntTime),1)<0.01
            set(hObject, 'BackgroundColor', [1 0 0])
            handles.IntTimeHandle = false;
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
        else
            set(hObject, 'BackgroundColor', [0 1 0])
            handles.IntTime = str2num(Current_IntTime);
            IntTime = str2num(Current_IntTime);
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
        end
end


% --- Executes during object creation, after setting all properties.
function IntTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in VaryVoltage.
function VaryVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to VaryVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global voltage End_Wavelength VaryVoltage_Ans  MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;

VaryVoltage_Ans = get(handles.VaryVoltage, 'Value');
switch VaryVoltage_Ans 
    case 0
        set(handles.Voltage, 'enable', 'on')
        set(handles.VoltageMax, 'enable', 'off','BackgroundColor', [1 1 1], 'String', 'Max')
        set(handles.VoltageMin, 'enable', 'off', 'BackgroundColor', [1 1 1], 'String', 'Min')
        set(handles.IncVoltage, 'enable', 'off')
        VoltageMax = [];
        VoltageMin = [];
        Inc_Voltage = [];
        StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
    case 1
        set(handles.VoltageMax, 'enable', 'on')
        set(handles.VoltageMin, 'enable', 'on')
        set(handles.IncVoltage, 'enable', 'on')
        set(handles.Voltage, 'enable', 'off', 'BackgroundColor', [1 1 1], 'String', 'D or 0-1200')
        voltage = [];
        StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end
        

% Hint: get(hObject,'Value') returns toggle state of VaryVoltage



function VoltageMin_Callback(hObject, eventdata, handles)
% hObject    handle to VoltageMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VoltageMin as text
%        str2double(get(hObject,'String')) returns contents of VoltageMin as a double

global voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;

Current_MinVoltage = get(handles.VoltageMin, 'String')
 if str2num(Current_MinVoltage) < 0 | str2num(Current_MinVoltage)>1200
            set(hObject, 'BackgroundColor', [1 0 0])
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
        else
            set(hObject, 'BackgroundColor', [0 1 0])
            handles.MinVoltage = str2num(Current_MinVoltage);
            MinVoltage = str2num(Current_MinVoltage);
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
        end


% --- Executes during object creation, after setting all properties.
function VoltageMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VoltageMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VoltageMax_Callback(hObject, eventdata, handles)
% hObject    handle to VoltageMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VoltageMax as text
%        str2double(get(hObject,'String')) returns contents of VoltageMax as a double
global voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;

Current_MaxVoltage = get(handles.VoltageMax, 'String')
 if str2num(Current_MaxVoltage) < MinVoltage | str2num(Current_MaxVoltage)>1200
            set(hObject, 'BackgroundColor', [1 0 0])
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
 else
     set(hObject, 'BackgroundColor', [0 1 0])
     handles.MaxVoltage = str2num(Current_MaxVoltage);
     MaxVoltage = str2num(Current_MaxVoltage);
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
 end


% --- Executes during object creation, after setting all properties.
function VoltageMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VoltageMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SPEX_Slit_Callback(hObject, eventdata, handles)
% hObject    handle to SPEX_Slit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPEX_Slit as text
%        str2double(get(hObject,'String')) returns contents of SPEX_Slit as a double
global voltage Slit_Width MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;

Current_Slit = get(handles.SPEX_Slit, 'String');
 if str2num(Current_Slit) < 0 | str2num(Current_Slit)>=14.0
            set(hObject, 'BackgroundColor', [1 0 0])
            sprintf('The settings should be between 0 and 1.4')
            SPEX_Wavelength = 650;
            StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
 else
     set(hObject, 'BackgroundColor', [0 1 0])
     SPEX_Wavelength = 650;
     Slit_Width = str2num(Current_Slit);
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
 end



% --- Executes during object creation, after setting all properties.
function SPEX_Slit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPEX_Slit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Desired_Wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to Desired_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Desired_Wavelength as text
%        str2double(get(hObject,'String')) returns contents of Desired_Wavelength as a double
global End_Wavelength voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;

Wavelength_check = get(handles.Desired_Wavelength, 'String');
if str2num(Wavelength_check) < 100 | str2num(Wavelength_check) > 1000
     set(hObject, 'BackgroundColor', [1 0 0])
     End_Wavelength = [];
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
     End_Wavelength = str2num(Wavelength_check);
     set(hObject, 'BackgroundColor', 'green')
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end
    



% --- Executes during object creation, after setting all properties.
function Desired_Wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Desired_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in VaryingWavelength.
function VaryingWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to VaryingWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VaryingWavelength
global VaryWavelength_Ans End_Wavelength;
global voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;

VaryWavelength_Ans = get(handles.VaryingWavelength, 'Value');
switch VaryWavelength_Ans
    case 0
        set(handles.Desired_Wavelength, 'enable', 'on')
        set(handles.Wavelength_Max, 'enable', 'off','BackgroundColor', [1 1 1], 'String', 'Max')
        set(handles.Wavelength_Min, 'enable', 'off', 'BackgroundColor', [1 1 1], 'String', 'Min')
        set(handles.Inc_Wavelength, 'enable', 'off', 'BackgroundColor', [1 1 1], 'String', '1')
        Inc_Wavelength = 50;
        MaxWavelength = 500;
        MinWavelength = 600;
        End_Wavelength =[];
        StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
    case 1
        set(handles.Wavelength_Max, 'enable', 'on')
        set(handles.Wavelength_Min, 'enable', 'on')
        set(handles.Inc_Wavelength, 'enable', 'off')
        set(handles.Desired_Wavelength, 'enable', 'off', 'BackgroundColor', [1 1 1], 'String', '650')
        End_Wavelength = [];
        MaxWavelength = [];
        MinWavelength = [];
        Inc_Wavelength = [];
        StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end



function Wavelength_Min_Callback(hObject, eventdata, handles)
% hObject    handle to Wavelength_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wavelength_Min as text
%        str2double(get(hObject,'String')) returns contents of Wavelength_Min as a double
global voltage End_Wavelength MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;
Wavelength_check = get(handles.Wavelength_Min, 'String');
if str2num(Wavelength_check) < 100 | str2num(Wavelength_check) > 1100
     set(hObject, 'BackgroundColor', 'red')
     End_Wavelength = [];
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    MinWavelength = str2num(Wavelength_check);
     set(hObject, 'BackgroundColor', 'green')
     set(handles.Inc_Wavelength, 'enable', 'on')
     End_Wavelength = 550;
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end


% --- Executes during object creation, after setting all properties.
function Wavelength_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wavelength_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Wavelength_Max_Callback(hObject, eventdata, handles)
% hObject    handle to Wavelength_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wavelength_Max as text
%        str2double(get(hObject,'String')) returns contents of Wavelength_Max as a double
global voltage End_Wavelength MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength;
Wavelength_check = get(handles.Wavelength_Max, 'String');
if str2num(Wavelength_check) < MinWavelength | str2num(Wavelength_check) > 1100
     set(hObject, 'BackgroundColor', 'red')
     End_Wavelength = [];
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    MaxWavelength = str2num(Wavelength_check);
     set(hObject, 'BackgroundColor', 'green')
     set(handles.Inc_Wavelength, 'enable', 'on')
     End_Wavelength = 550;
     StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end


% --- Executes during object creation, after setting all properties.
function Wavelength_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wavelength_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Inc_Wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to Inc_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Inc_Wavelength as text
%        str2double(get(hObject,'String')) returns contents of Inc_Wavelength as a double
global IncWavelength_check voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;
IncWavelength_check = get(handles.Inc_Wavelength, 'String');

if isempty(MaxWavelength) | isempty(MinWavelength)
    set(hObject, 'BackgroundColor', 'red')
    display('Must Set Min and Max wavelengths first');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    set(handles.Inc_Wavelength, 'enable', 'on')
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end

if str2num(IncWavelength_check)<0.02
    set(hObject, 'BackgroundColor', 'red')
    display('Increment must be greater than 0.02 nm');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
elseif str2num(IncWavelength_check) > abs(MaxWavelength - MinWavelength)
    set(hObject, 'BackgroundColor', 'red')
    display('Increment is too large. Its larger than the difference between the the maximum and minimum wavelengths');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
elseif mod(str2num(IncWavelength_check),0.03125) ~= 0
    set(hObject, 'BackgroundColor', 'red')
    display('The increment must be divisible by 0.0313!');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    set(hObject, 'BackgroundColor', 'green')
    Inc_Wavelength = str2num(IncWavelength_check);
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end

    
    

% --- Executes during object creation, after setting all properties.
function Inc_Wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inc_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on Voltage and none of its controls.
function Voltage_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Voltage (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Start_Value = get(handles.Start, 'Value')
if Start_Value == 1
    set(handles.Start, 'Enable', 'off', 'Visible', 'off')
    set(handles.PMT_Saturation, 'Visible', 'on', 'Enable', 'on', 'String', 'Program Starting', 'Background', 'green')
    pause(2.0)
    set(handles.PMT_Saturation, 'Visible', 'on', 'Enable', 'on', 'String', 'PMT Saturation', 'Background', 'white')
    run('ControllingEverything270M.m');
end
    



function PMT_Saturation_Callback(hObject, eventdata, handles)
% hObject    handle to PMT_Saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT_Saturation as text
%        str2double(get(hObject,'String')) returns contents of PMT_Saturation as a double


% --- Executes during object creation, after setting all properties.
function PMT_Saturation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT_Saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SCRAM.
function SCRAM_Callback(hObject, eventdata, handles)
global scram;
% hObject    handle to SCRAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scram = get(handles.SCRAM, 'Value');



function Messages_Callback(hObject, eventdata, handles)
% hObject    handle to Messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Messages as text
%        str2double(get(hObject,'String')) returns contents of Messages as a double



% --- Executes during object creation, after setting all properties.
function Messages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IncVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to IncVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IncVoltage as text
%        str2double(get(hObject,'String')) returns contents of IncVoltage as a double
global IncWavelength Inc_Voltage_check Inc_Voltage voltage MaxVoltage MinVoltage IntTime MinWavelength MaxWavelength SPEX_Wavelength Inc_Wavelength End_Wavelength;
IncVoltage_check = get(handles.IncVoltage, 'String');

if isempty(MaxVoltage) | isempty(MinVoltage)
    set(hObject, 'BackgroundColor', 'red')
    display('Must Set Min and Max voltages first');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    set(handles.IncVoltage, 'enable', 'on')
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end

if str2num(IncVoltage_check)<0
    set(hObject, 'BackgroundColor', 'red')
    display('Increment must be greater than 0 V');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
elseif str2num(IncVoltage_check) > abs(MaxVoltage - MinVoltage)
    set(hObject, 'BackgroundColor', 'red')
    display('Increment is too large. Its larger than the difference between the the maximum and minimum voltages');
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
else
    set(hObject, 'BackgroundColor', 'green')
    Inc_Voltage = str2num(IncVoltage_check);
    StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
end


% --- Executes during object creation, after setting all properties.
function IncVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IncVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberOfRuns_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfRuns as text
%        str2double(get(hObject,'String')) returns contents of NumberOfRuns as a double
global NumRuns NumCheck;
NumCheck = str2num(get(handles.NumberOfRuns, 'String'));
if NumCheck == fix(NumCheck)
    NumRuns = str2num(get(handles.NumberOfRuns, 'String'));
    set(hObject, 'BackgroundColor', 'green')
else
    set(hObject, 'BackgroundColor', 'red')
    NumRuns = 1;
end


% --- Executes during object creation, after setting all properties.
function NumberOfRuns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ContinuousMeasurement.
function ContinuousMeasurement_Callback(hObject, eventdata, handles)
% hObject    handle to ContinuousMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ContinuousMeasurement
global ContMeasurement WarnContMeasurement;
ContMeasurement=get(handles.ContinuousMeasurement, 'Value')
if ContMeasurement == 1 & get(handles.VaryingWavelength, 'Value')== 1 | ...
        ContMeasurement == 1 & get(handles.VaryVoltage, 'Value')== 1 
    msgbox('Warning! This option is only for a constant Voltage and Wavelegnth. Try again')
    WarnContMeasurement = 1;
end
