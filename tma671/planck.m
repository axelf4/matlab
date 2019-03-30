function me=planck(lambda,T)
	h=6.6256e-34;c=2.9979e8;k=1.3805e-23;a=2*pi*h*c^2;b=h*c/k./lambda./T;
	me=a./lambda.^5./(exp(b)-1);
