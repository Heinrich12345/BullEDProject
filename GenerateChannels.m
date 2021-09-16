function channels = GenerateChannels(signal, s, theta, f)
    %Generates a signal in each of the element channels of the array.
    
    
    channels = repmat(signal,length(s),1);%makes the same signal for each channel. This would 
                                          %have to be done differently if
                                          %amplitude comparison is to be used
    
    phi = CalculatePhaseOffsets(f,theta,s);%calculating phase offset at each element
    
    channels = channels.*exp(1i*phi');%creating phase difference in each channel
end
