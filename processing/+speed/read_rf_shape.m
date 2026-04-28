function pulse = read_rf_shape(filepath)
%READ_RF_SHAPE Read two-column Varian/Agilent shape file body: phase amp.
raw = readmatrix(filepath, 'FileType', 'text');
raw = raw(all(~isnan(raw(:,1:2)),2),1:2);
pulse.phase_deg = raw(:,1);
pulse.amp = raw(:,2);
pulse.complex = pulse.amp .* exp(1i*deg2rad(pulse.phase_deg));
pulse.filepath = filepath;
end
