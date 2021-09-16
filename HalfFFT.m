  
function fftSignal = HalfFFT(signal)
    %Applies the fast fourier transform of the signal and removes the
    %unnecessary reflection
    
    fftSignal = (fft(signal,[],2));
    fftSignal = fftSignal(:,length(fftSignal)/2:length(fftSignal));
    
end