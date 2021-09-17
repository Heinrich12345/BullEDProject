function [AoA2,AoA3] = CalculateAoA(phi,s,f)
    %Calculates the AoA using the course(AoA2) and fine(AoA3) resolutions.
    %The course and fine resolutions that are closest together are
    %determined and the fine resolution of the closest pair is given as the
    %AoA
    
    c=1;
    for k = 1:width(phi)
        lamda = 3e8/f(k);
        I2max=round(s(2)/lamda);
        I3max=round(s(3)/lamda);
        dif=100;
        for i2 = -I2max:I2max
            for i3 = -I3max:I3max
                AoA2temp=asin(lamda*(phi(2,k)/(2*pi)+i2)/s(2));
                AoA3temp=asin(lamda*(phi(3,k)/(2*pi)+i3)/s(3));
                if dif > abs(AoA2temp-AoA3temp)
                    dif = abs(AoA2temp-AoA3temp);
                    I2=i2;
                    I3=i3;
                end
            end
        end
        AoA2(c)=asin(lamda*(phi(2,k)/(2*pi)+I2)/s(2));
        AoA3(c)=asin(lamda*(phi(3,k)/(2*pi)+I3)/s(3));
        c=c+1;
    end
    
end

