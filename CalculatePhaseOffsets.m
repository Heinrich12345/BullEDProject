function phi = CalculatePhaseOffsets(f,theta,s)
lambda = 3e8/f;

phi = wrapToPi(2*pi*s*sin(theta)/lambda);
end