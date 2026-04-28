function write_rf_shape(filepath, z)
%WRITE_RF_SHAPE Write complex waveform as phase/amplitude text.
ph = mod(rad2deg(angle(z)),360);
am = abs(z);
fid = fopen(filepath,'w');
cleanup = onCleanup(@() fclose(fid));
for k = 1:numel(z)
    fprintf(fid,'%-7.3f   %-11.6f  1  1\n', ph(k), am(k));
end
end
