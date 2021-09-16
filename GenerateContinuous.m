function signal = GenerateContinuous(Fc,Fs,n)
    %Function Generates CW signal
    N = 1:1:n;

    t = N*(1/Fs);
    
    signal = sin(2*pi*Fc*t);

end

