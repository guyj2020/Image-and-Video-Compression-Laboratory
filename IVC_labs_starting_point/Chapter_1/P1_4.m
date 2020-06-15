X = [0, 1, 0, -1, 0];
Vq = interp1(0:4, X, 0:0.5:4, 'nearest');
Vq_2 = interp1(0:4, X, 0:0.5:4, 'linear');
Vq_3 = interp1(0:4, X, 0:0.5:4, 'cubic');

figure;
subplot(1,3,1);
stem(Vq);
title("NN")

subplot(1,3, 2);
stem(Vq_2);
title("LIN")

subplot(1,3,3);
stem(Vq_3);
title("SINC")

y=X;
m = 1;
u = linspace(1,length(y),length(y)*m); 
x = linspace(1,length(y),length(y));
for i=1:length(u)
    yp(i) = sum(y.*sinc(u(i) - x));           
end
figure;
stem(yp);