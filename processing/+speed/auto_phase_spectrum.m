function [specPhased, phiDeg] = auto_phase_spectrum(spec)
%AUTO_PHASE_SPECTRUM Simple automatic zero-order phase correction.
%   Chooses a single zero-order phase to maximize absorptive real signal and
%   minimize negative/imaginary contribution. Input and output are row vectors.

spec = spec(:).';
obj = @(phi) objective(spec, phi);
phi = fminsearch(obj, 0, optimset('Display','off'));
phiDeg = phi;
specPhased = spec .* exp(1i*pi*phi/180);
end

function y = objective(spec, phi)
sp = spec .* exp(1i*pi*phi/180);
r = real(sp);
im = imag(sp);
negPenalty = sum(abs(r(r<0)));
% favor strong positive absorptive signal and small imaginary residue
shapePenalty = sum(abs(im));
peakReward = -sum(max(r,0));
y = negPenalty + 0.15*shapePenalty + 0.02*peakReward;
end
