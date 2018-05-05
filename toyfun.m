
function toyfun

A=-5:1:5;
B=-5:1:5;
C=-5:1:5; %half max location
D=-5:1:5;

x = -5:.1:5;
figure;
hold on;



for c=1:length(C)
    y = A(a)+(B(b)-A(c))./(1+10.^((C(c)-x)*D(d)));
    plot(x,y);
end

