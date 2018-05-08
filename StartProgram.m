function StartProgram(MaxVoltage, MinVoltage, IntTime, MinWavelength, MaxWavelength, SPEX_Wavelength, Inc_Wavelength, End_Wavelength)
%This program is designed to enable the start button once all the
%parameters are correct
f=SpecControl;
handles=guidata(f);
if ~isempty(MinVoltage) & ~isempty(MaxVoltage) & ~isempty(IntTime) & ~isempty(MinWavelength) & ~isempty(MaxWavelength) & ~isempty(SPEX_Wavelength) & ~isempty(Inc_Wavelength) & ~isempty(End_Wavelength)
    set(handles.Start, 'enable', 'on') 
else
    set(handles.Start, 'enable', 'off')
end