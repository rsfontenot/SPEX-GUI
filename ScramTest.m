function ScramTest()
f=SpecControl;
handles=guidata(f);
scram = get(handles.SCRAM, 'Value');
if scram == 1
    msgbox('Emergency Shutdown Procedure Initiated!!!') 
    fwrite(SPEX, uint8([107;48;44;48;44;45; SlitStepsToMove; 13]))
    fread(SPEX,1)
    pause(60)
    fwrite(SPEX, uint8([107;48;44;51;44;45; ExitSlitsStepsToMove; 13]))
    fread(SPEX,1)
    pause(60)
    msgbox('Slits are closed!!!') 
    error('Emergency Shutdown Procedure Initiated!!!')
end
guidata(f,handles)