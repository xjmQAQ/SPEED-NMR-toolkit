function E = get_encoding_matrix(method, N)
%GET_ENCODING_MATRIX Return the encoding/decoding matrix.
%   For Fourier encoding, the matrix size is N x N.
%   For Hadamard encoding, the matrix size is M x M where
%   M = 2^nextpow2(N), i.e. the nearest valid Hadamard order.
%
%   Examples:
%       N = 3  -> Hadamard uses H4
%       N = 5:8 -> Hadamard uses H8
%
%   The pulse-combination function pads missing input channels with zeros
%   when N is smaller than the Hadamard order.

method = lower(string(method));
switch method
    case "hadamard"
        if N <= 1
            E = 1;
        else
            order = 2^nextpow2(N);
            E = hadamard(order);
        end
    case "fourier"
        [m,n] = ndgrid(0:N-1,0:N-1);
        E = exp(-1i*2*pi.*m.*n./N);
    otherwise
        error('Unsupported method: %s', method);
end
end
