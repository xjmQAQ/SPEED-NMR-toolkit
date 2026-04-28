function write_varian_fid(templateFidFolder, outputFidFolder, newData)
%WRITE_VARIAN_FID Copy template fid folder and replace first block data.
if exist(outputFidFolder,'dir')
    rmdir(outputFidFolder,'s');
end
copyfile(templateFidFolder, outputFidFolder);

fidPath = fullfile(outputFidFolder, 'fid');
fid = fopen(fidPath,'r+','ieee-be');
if fid == -1
    error('Cannot open %s', fidPath);
end
cleanup = onCleanup(@() fclose(fid));

nblocks   = fread(fid,1,'int32');
ntraces   = fread(fid,1,'int32');
np        = fread(fid,1,'int32');
ebytes    = fread(fid,1,'int32');
tbytes    = fread(fid,1,'int32');
bbytes    = fread(fid,1,'int32');
vers_id   = fread(fid,1,'int16');
status    = fread(fid,1,'int16');
nbheaders = fread(fid,1,'int32');

s_32      = bitget(status,3);
s_float   = bitget(status,4);

% move to first block data
fseek(fid, 32 + 28, 'bof');

z = newData(:);
interleaved = zeros(2*numel(z),1);
interleaved(1:2:end) = real(z);
interleaved(2:2:end) = imag(z);

if numel(interleaved) ~= np
    error('Length mismatch between new data and template fid.');
end

if s_float == 1
    fwrite(fid, interleaved, 'float32');
elseif s_32 == 1
    fwrite(fid, int32(round(interleaved)), 'int32');
else
    fwrite(fid, int16(round(interleaved)), 'int16');
end
end
