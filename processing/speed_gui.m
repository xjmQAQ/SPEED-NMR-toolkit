function speed_gui()
%SPEED_GUI Minimal GUI for pulse combination and FID decoding.

fig = uifigure('Name','SPEED Toolkit','Position',[100 100 1180 720]);

tg = uitabgroup(fig,'Position',[10 10 1160 700]);
tab1 = uitab(tg,'Title','Build RF Pulses');
tab2 = uitab(tg,'Title','Decode FIDs');

baseDir = fileparts(fileparts(mfilename('fullpath')));

% ==== TAB 1 ====
uilabel(tab1,'Text','Method','Position',[20 650 60 22]);
ddPulseMethod = uidropdown(tab1,'Items',{'Hadamard','Fourier'},'Position',[90 650 120 22]);

uilabel(tab1,'Text','Unencoded pulse folder','Position',[20 610 160 22]);
efPulseIn = uieditfield(tab1,'text','Position',[180 610 550 22], ...
    'Value',fullfile(baseDir,'acquisition','pulses','unencoded','Hadamard'));
uibutton(tab1,'Text','Browse','Position',[740 610 80 22],...
    'ButtonPushedFcn',@(src,event)browseFolder(efPulseIn));

uilabel(tab1,'Text','Output pulse folder','Position',[20 570 160 22]);
efPulseOut = uieditfield(tab1,'text','Position',[180 570 550 22], ...
    'Value',fullfile(baseDir,'acquisition','pulses','encoded','Hadamard'));
uibutton(tab1,'Text','Browse','Position',[740 570 80 22],...
    'ButtonPushedFcn',@(src,event)browseFolder(efPulseOut));

btnBuild = uibutton(tab1,'Text','Build Encoded Pulses','Position',[20 530 180 30],...
    'ButtonPushedFcn',@(~,~)buildPulses());

uilabel(tab1,'Text','Unencoded pulse preview','Position',[20 490 180 22]);
uilabel(tab1,'Text','Encoded pulse preview','Position',[590 490 180 22]);

axPulseIn = uiaxes(tab1,'Position',[20 160 520 320]);
axPulseIn.Box = 'on';
axPulseOut = uiaxes(tab1,'Position',[590 160 520 320]);
axPulseOut.Box = 'on';

taPulse = uitextarea(tab1,'Position',[20 20 1090 120],'Editable','off');

% ==== TAB 2 ====
uilabel(tab2,'Text','Method','Position',[20 650 60 22]);
ddFidMethod = uidropdown(tab2,'Items',{'Hadamard','Fourier'},'Position',[90 650 120 22], ...
    'ValueChangedFcn', @(src,event)syncMethodFolders());

uilabel(tab2,'Text','Encoded FID folder','Position',[20 610 140 22]);
efFidIn = uieditfield(tab2,'text','Position',[180 610 550 22], ...
    'Value',fullfile(baseDir,'acquisition','FIDs','Encoded','Hadamard'));
uibutton(tab2,'Text','Browse','Position',[740 610 80 22],...
    'ButtonPushedFcn',@(src,event)browseFolder(efFidIn));

uilabel(tab2,'Text','Decoded output folder','Position',[20 570 150 22]);
efFidOut = uieditfield(tab2,'text','Position',[180 570 550 22], ...
    'Value',fullfile(baseDir,'acquisition','FIDs','Decoded','Hadamard'));
uibutton(tab2,'Text','Browse','Position',[740 570 80 22],...
    'ButtonPushedFcn',@(src,event)browseFolder(efFidOut));

btnDecode = uibutton(tab2,'Text','Decode FIDs','Position',[20 530 120 30],...
    'ButtonPushedFcn',@(~,~)decodeFids());

uilabel(tab2,'Text','Before decoding','Position',[20 490 160 22]);
uilabel(tab2,'Text','After decoding','Position',[590 490 140 22]);

axFidIn = uiaxes(tab2,'Position',[20 160 520 320]);
axFidIn.Box = 'on';
axFidOut = uiaxes(tab2,'Position',[590 160 520 320]);
axFidOut.Box = 'on';

taFid = uitextarea(tab2,'Position',[20 20 1090 120],'Editable','off');

    function browseFolder(editField)
        startDir = editField.Value;
        if ~isfolder(startDir)
            startDir = pwd;
        end
        p = uigetdir(startDir, 'Select folder');
        if isequal(p,0), return; end
        editField.Value = p;
        drawnow;
        try
            fig.WindowState = 'normal';
        catch
        end
        try
            fig.Visible = 'off';
            pause(0.05);
            fig.Visible = 'on';
        catch
        end
    end

    function syncMethodFolders()
        method = char(ddFidMethod.Value);
        efFidIn.Value = fullfile(baseDir,'acquisition','FIDs','Encoded',method);
        efFidOut.Value = fullfile(baseDir,'acquisition','FIDs','Decoded',method);
    end

    function buildPulses()
        inDir = efPulseIn.Value;
        outDir = efPulseOut.Value;
        method = ddPulseMethod.Value;
        if ~isfolder(inDir)
            uialert(fig,'Please choose a valid unencoded pulse folder.','Input error');
            return;
        end
        rf = dir(fullfile(inDir,'*.RF'));
        if isempty(rf)
            uialert(fig,'No .RF files found in selected pulse folder.','Input error');
            return;
        end
        filesIn = fullfile({rf.folder},{rf.name});
        out = speed.combine_rf_pulses(filesIn, method, outDir);
        cla(axPulseIn); cla(axPulseOut);
        hold(axPulseIn,'on');
        for ii = 1:size(out.unencodedMatrix,2)
            plot(axPulseIn, abs(out.unencodedMatrix(:,ii)), 'LineWidth',1.0);
        end
        hold(axPulseIn,'off');
        hold(axPulseOut,'on');
        for ii = 1:size(out.encodedMatrix,2)
            plot(axPulseOut, abs(out.encodedMatrix(:,ii)), 'LineWidth',1.0);
        end
        hold(axPulseOut,'off');
        taPulse.Value = compose("Built %d encoded pulses using %s into:%s", numel(out.outputFiles), method, outDir);
    end

    function decodeFids()
        inDir = efFidIn.Value;
        outDir = efFidOut.Value;
        method = ddFidMethod.Value;
        if ~isfolder(inDir)
            uialert(fig,'Please choose a valid encoded FID folder.','Input error');
            return;
        end
        d = dir(fullfile(inDir,'*.fid'));
        d = d([d.isdir]);
        if isempty(d)
            uialert(fig,'No .fid directories found in selected FID folder.','Input error');
            return;
        end
        fidList = fullfile({d.folder},{d.name});
        out = speed.decode_fids(fidList, method, outDir);
        cla(axFidIn); cla(axFidOut);
        hold(axFidIn,'on');
        for ii = 1:size(out.inputSpectra,1)
            plot(axFidIn, out.inputSpectra(ii,:), 'LineWidth',1.0);
        end
        hold(axFidIn,'off');
        hold(axFidOut,'on');
        for ii = 1:size(out.decodedSpectra,1)
            plot(axFidOut, out.decodedSpectra(ii,:), 'LineWidth',1.0);
        end
        hold(axFidOut,'off');
        if strcmpi(method,'Hadamard')
            taFid.Value = compose("Decoded %d FIDs using %s into:%s", numel(out.outputFids), method, outDir);
        else
            taFid.Value = compose("Decoded %d FIDs using %s into:%s", numel(out.outputFids), method, outDir);
        end
    end
end
