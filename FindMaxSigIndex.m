function I = FindMaxSigIndex(fftsignal)
    %Function finds fft signal index with highest power
    [~,I] = max(fftsignal);
end