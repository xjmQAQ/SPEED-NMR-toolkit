function out = decode_fids(fidFolders, method, outputDir)
%DECODE_FIDS Decode a set of encoded .fid folders and prepare plot-ready spectra.
%   Fourier: number of encoded FIDs must equal number of decoded channels.
%   Hadamard: number of encoded FIDs must equal a valid Hadamard order.
%   If the original input pulse count was smaller than the Hadamard order,
%   the extra decoded channels are expected to be near-zero.

if nargin < 3 || isempty(outputDir)
    outputDir = pwd;
end

nEncoded = numel(fidFolders);
if nEncoded < 1
    error('At least one encoded fid folder is required.');
end

X = [];
for k = 1:nEncoded
    d = speed.load_varian_fid(fidFolders{k});
    X(k,:) = d.data(:).';
end

m = lower(char(method));
switch m
    case 'hadamard'
        if nEncoded > 1 && abs(log2(nEncoded) - round(log2(nEncoded))) > eps
            error('Hadamard decoding requires 1, 2, 4, 8, ... encoded FIDs.');
        end
        H = speed.get_encoding_matrix('hadamard', nEncoded);
        decoded = H \ X;
    case 'fourier'
        F = speed.get_encoding_matrix('fourier', nEncoded);
        decoded = (F' * X) ./ nEncoded;
    otherwise
        error('Unsupported method.');
end

inputSpectra = zeros(size(X));
decodedSpectra = zeros(size(decoded));
phaseDegrees = NaN(1,size(decoded,1));

for k = 1:size(X,1)
    inSpec = fftshift(fft(X(k,:)));
    if strcmp(m,'hadamard')
        [inSpecP, ~] = speed.auto_phase_spectrum(inSpec);
        inputSpectra(k,:) = real(inSpecP);
    else
        inputSpectra(k,:) = abs(inSpec);
    end
end

for k = 1:size(decoded,1)
    outSpec = fftshift(fft(decoded(k,:)));
    if strcmp(m,'hadamard')
        [outSpecP, outPhi] = speed.auto_phase_spectrum(outSpec);
        decodedSpectra(k,:) = real(outSpecP);
        phaseDegrees(k) = outPhi;
    else
        decodedSpectra(k,:) = abs(outSpec);
    end
end

if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

outFiles = cell(1,size(decoded,1));
for k = 1:size(decoded,1)
    outFiles{k} = fullfile(outputDir, sprintf('%s_decoded_%02d.fid', m, k));
    speed.write_varian_fid(fidFolders{1}, outFiles{k}, decoded(k,:).');
end

out.method = method;
out.inputFids = fidFolders;
out.outputFids = outFiles;
out.encodedFids = X;
out.decodedFids = decoded;
out.inputSpectra = inputSpectra;
out.decodedSpectra = decodedSpectra;
out.phaseDegrees = phaseDegrees;
out.nEncoded = nEncoded;
out.nDecoded = size(decoded,1);
end
