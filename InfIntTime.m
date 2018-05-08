function [Tcount, NewSatCheck] = InfIntTime(iTime,PMT,SatCheck,handles)
% This function will allow for integration times of greater than 1 s. 
Rcount = 0;
Rcount2 = 0;

if iTime >= 1

switch rem(iTime,1)
    case 0
    Rtime = iTime;
    Rtime2 = 0;
    fwrite(PMT,uint8([80; bitand(100,255); 13])) %This sets the integration time to 1 s
    PMTErrorCheck(1,PMT)
   % set(handles.Messages, 'string', sprintf('PMT Integration is Set to %d s.', iTime))
otherwise
    Rtime = floor(iTime,1);
    Rtime2 = rem(iTime,1);
    fwrite(PMT,uint8([80; bitand(100,255); 13])) %This sets the integration time to 1s
    PMTErrorCheck(1,PMT)
   % set(handles.Messages, 'string', sprintf('PMT Integration is Set to %d s.', iTime))
end

%h=waitbar(0, 'Recording the Luminescence');

%%Java status bar
%jFrame = get(handles, 'JavaFrame');
%jRootPane = jFrame.fFigureClient.getWindow;
%statusbarObj = com.mathworks.mwswing.MJStatusBar;

%Add a progress bar to left side
%jProgressBar = javax.swing.JProgressBar;
%set(jProgessBar, 'Minimum', 0, 'Maximum', 500, 'Value', 234);
%statusbarObj.add(jProgressBar, 'West');

%Set this container as the figure's status bar
%jRootPane.setStatusBar(statusbarObj);

%statusbarObj.setText('Recording Luminescence');
%jRootPane.setStatusBarVisible(true):

sb = statusbar('Measuring the Luminescence');
set(sb.CornerGrip, 'visible',true);

tic
for N=1:1:Rtime
    fwrite(PMT,uint8(hex2dec(['53'; '0D'])));
    pause(1.1)
    sol=fread(PMT,PMT.BytesAvailable);
    CheckCount = sol(1)*16777216 +sol(2)*65536 + sol(3)*256 + sol(4);
    set(sb.ProgressBar, 'Visible',true, 'Minimum',0, 'Maximum',100, 'Value',N*100/Rtime)
    %waitbar(N/Rtime,h)
    if sol(1)==255 | CheckCount > 10^7
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
    Rcount = Rcount + CheckCount;
end
toc
%delete(h)

if Rtime2 > 0
   P=Rtime2*100;
   test=bitshift(P,-8);
   if test(1)==0
       fwrite(PMT,uint8([80; bitand(P,255); 13])) %P is 80
       PMTErrorCheck(1,PMT)
   else
       fwrite(PMT,uint8([80; bitshift(P,-8); bitand(P,255); 13])) %P is 80
       PMTErrorCheck(1,PMT)   
   end
   fwrite(PMT,uint8(hex2dec(['53'; '0D'])));
   pause(1.1)
   sol=fread(PMT,PMT.BytesAvailable);
   CheckCount = sol(1)*16777216 +sol(2)*65536 + sol(3)*256 + sol(4);
   if sol(1)==255 | CheckCount > 10^7
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
   Rcount2 = checkcount;
end

NewSatCheck = SatCheck;
Tcount = Rcount + Rcount2;
%If statement ends here for single run
else
    Rtime = iTime;
    Rtime2 = 0;
    P=iTime*100;
    test=bitshift(P,-8);
    if test(1)==0
        fwrite(PMT,uint8([80; bitand(P,255); 13])) %P is 80
        PMTErrorCheck(1,PMT)
    else
        fwrite(PMT,uint8([80; bitshift(P,-8); bitand(P,255); 13])) %P is 80
        PMTErrorCheck(1,PMT)
    end
    fwrite(PMT,uint8(hex2dec(['53'; '0D'])));
    pause(1.1)
    sol=fread(PMT,PMT.BytesAvailable);
    CheckCount = sol(1)*16777216 +sol(2)*65536 + sol(3)*256 + sol(4);
    if sol(1)==255 | CheckCount > 10^7
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
    NewSatCheck = SatCheck;
    Tcount = CheckCount;
end
set(sb.CornerGrip, 'visible',false);


