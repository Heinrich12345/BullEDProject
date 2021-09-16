function signal = GeneratePulse(Fc,Fs,n, dc)
    %Function Generates a pulse signal
    
    N = 1:1:n;

    t = N*(1/Fs);
    
    cw = sin(2*pi*Fc*t);
    
    signal = cw.*[ones(1,n*dc) zeros(1,n*(1-dc))];


end

