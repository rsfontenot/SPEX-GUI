function ptime(time)
%h=waitbar(0, 'SPEX Monochromator Initializing');
sb = statusbar('Monochromator Initializing');
set(sb.CornerGrip, 'visible',true);
for i=1:10
    set(sb.ProgressBar, 'Visible',true, 'Minimum',0, 'Maximum',100, 'Value',i*10)
    %waitbar(i/10,h)
    pause(time/10)
    %java.lang.Thread.sleep(12*1000);
end
set(sb.CornerGrip, 'visible',false);
%delete(h)
