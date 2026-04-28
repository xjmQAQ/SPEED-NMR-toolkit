function fidData = load_varian_fid(fidFolder)
%LOAD_VARIAN_FID Minimal Varian/Agilent fid loader for first block/trace.
fidPath = fullfile(fidFolder, 'fid');
fid = fopen(fidPath,'r','ieee-be');
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

% first block header
scale     = fread(fid,1,'int16');
bstatus   = fread(fid,1,'int16');
index     = fread(fid,1,'int16');
mode      = fread(fid,1,'int16');
ctcount   = fread(fid,1,'int32');
lpval     = fread(fid,1,'float32');
rpval     = fread(fid,1,'float32');
lvl       = fread(fid,1,'float32');
tlt       = fread(fid,1,'float32');

if s_float == 1
    data = fread(fid,np,'float32');
elseif s_32 == 1
    data = fread(fid,np,'int32');
else
    data = fread(fid,np,'int16');
end

re = double(data(1:2:end));
im = double(data(2:2:end));

fidData.data = re + 1i*im;
fidData.header = struct('nblocks',nblocks,'ntraces',ntraces,'np',np,'ebytes',ebytes,...
    'tbytes',tbytes,'bbytes',bbytes,'vers_id',vers_id,'status',status,'nbheaders',nbheaders,...
    'scale',scale,'bstatus',bstatus,'index',index,'mode',mode,'ctcount',ctcount,...
    'lpval',lpval,'rpval',rpval,'lvl',lvl,'tlt',tlt);
end
