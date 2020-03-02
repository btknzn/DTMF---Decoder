function [numbers] = DTMFsolver(Audio1,fs)
% daha sonra ise bu ses dosyas?n? dinliyorum
%ilk olarak frekans vektörünü olu?turmak için 
Ts = 1/fs;
uzunluk = length(Audio1)/fs
t =0:Ts:uzunluk-Ts;
figure()
%Ses sinyalimiz a?a??dad?r.
plot(t,Audio1);
title("(THE AUDIO DATA)Sampling Frequnect:8000hz")
% Bu k?s?mda ?öyle bir varsay?m yapt?k 100 tane arka arkaya 0 olmayan say?
% geli?yorsa buras? bizim ses sinyalimizin ba?lang?ç k?sm?d?r.
counter =0
%ilk olarak 20 tane ?ölye bir varsay?m yap?yoruz 20 farkl? ses sinyali
%gelebilir bundan dolay? 20 tane bizim ses sinyalimizle zaman olarak
%uzunluklar? ayn? sinyal yap?yoruz
seperatedSignal = zeros(length(Audio1),1,20);
beginOfNumberSignal=1;
endOfNumberSignal=1;
numberOfSignal = 1;
% Bu kod ile her sinyali ayr?lm?? olarak bulduk.
for i = 1:length(Audio1)
    %Sinyali bul ba?lang?c?n? bul.
    if ((Audio1(i)~=0) && (i>endOfNumberSignal))
        %Sinyalin biti? noktas?n? bul
        for j = 1:(length(Audio1)-i)
            %arada sin sinyalinin kendi 0 de?eri var bundan dolay? o
            %sinyalden sonraki 10 sample 0 m? diye bak?p buran?n end
            %noktas? olup olmad???na karar verice?iz
            control = 0;
            for k=1:10
                if (Audio1(i+j+k)~=0)
                    control=1;
                end
            end
            if ((Audio1(i+j)==0) && (control==0))
                endOfNumberSignal=i+j;
                beginOfNumberSignal=i;
                seperatedSignal(i:1:(i+j),1,numberOfSignal)=Audio1(i:1:(i+j));
                numberOfSignal=numberOfSignal+1;
                break
            end
        end
        
    end
   
end
%?imdi her sinyalin fft sini al?caz
audiofft=fft(Audio1);
numbersfourier=zeros(length(seperatedSignal(:,1,1)),numberOfSignal);
f = linspace(0,fs,length(audiofft));
for i=1:1:numberOfSignal
    numbersfourier(:,i) =double(abs(fft(seperatedSignal(:,1,i))));
end
% Bu k?s?mda sinyalleri yar?ya indiriyoruz.
f = f (1:1:length(f)/2);
seperatedNumber = zeros(length(audiofft)/2,numberOfSignal);

for i=1:1:numberOfSignal
    seperatedNumber(:,i)= numbersfourier(1:1:length(audiofft)/2,i);
end
%?imdi ise sinyallerin 1000Hzden büyük ve küçük frekanslar?n? buluyoruz
%1000 bizim sampling rate imize göre 1801 inci array bundan dolay?
size=length(f(:));
stepsize=f(2)-f(1);
untiltousendhertz = 1000/stepsize;
LowFrequency = zeros(1,numberOfSignal);
HighFrequency = zeros(1,numberOfSignal);

Size=length(seperatedNumber)
%?imdi ise rakam? bulmak için a?a??daki kodu uyguluyorum
%Bu freknaslarda noiseden dolay? -10 luk bir treshold yap?yorum.
LowGroup1=697-10
LowGroup2=770-1
LowGroup3=852-10
HighGroup1=1209-10
HighGroup2=1336-10
HighGroup3=1447-10
Zerocontrol=941-20
numbers=zeros(1,numberOfSignal);
for i = 1:1:numberOfSignal
    High=max(seperatedNumber(untiltousendhertz:1:Size,i));
    Low=max(seperatedNumber(1:1:untiltousendhertz,i));
    LowFrequency(i) = f*[seperatedNumber(:,i)==Low];
    HighFrequency(i) =f*[seperatedNumber(:,i)==High];

    counterLowTone=double(LowFrequency(i)>LowGroup1);
    counterHighTone=double(HighFrequency(i)>HighGroup1);
    counterLowTone=double(counterLowTone)+double(LowFrequency(i)>LowGroup2);
    counterHighTone=double(counterHighTone)+double(HighFrequency(i)>HighGroup2);
    counterLowTone=double(counterLowTone)+double(LowFrequency(i)>LowGroup3);
    counterHighTone=double(counterHighTone)+double(HighFrequency(i)>HighGroup3);
    numbers(i)=counterHighTone+3*(counterLowTone-1);
    if(LowFrequency(i)>Zerocontrol)
        numbers(i)=0
    end
    
end
figure()
for x = 1:1:9
     subplot(3,3,x)
     plot(f,seperatedNumber(:,x));
     title([' number:',num2str(numbers(x)),' freqlow: ',num2str(LowFrequency(x)),' FreqHigh: ',num2str(HighFrequency(x))])
end
end

