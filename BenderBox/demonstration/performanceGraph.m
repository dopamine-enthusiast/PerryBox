

x = 1:200;

y = 100./(1+100*exp(-x./10));


performance = [y(46:100) y(30:130)];

plot(performance)
box off;