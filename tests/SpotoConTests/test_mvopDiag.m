function test_suite = test_mvopDiag
%test_opDiag  Unit tests for the opDiag operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_mvopDiag_multiply
%% Test for multivectors multiplication
n = randi(100);
d = iCon.randn(n,1);
D = opDiag(d);
x = iCon.randn(n);

assertEqual(diag(d)*x,D*x);
assertEqual(diag(d)'*x,D'*x);
end % Built-in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_mvopDiag_diag
%% Function to test multivec opDiag
   n = randi(100); k = randi(10);

   b = iCon.randn(n,k);
   d = iCon.randn(n,1);
   D = opDiag(d);
   
   assertEqual( diag(double(D)), d )
   assertElementsAlmostEqual( diag(d)\b, D\b )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_mvopDiag_class
   n = randi(100);
   d = iCon.randn(n,1);
   assertEqual( double(diag(d)), double(opDiag(d)) ) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_mvopDiag_divide
   n = randi(100);
   d = iCon.randn(n,1) + 1i*iCon.randn(n,1);
   b = iCon.randn(n,2) + 1i*iCon.randn(n,2);
   D = opDiag(d);
   assertEqual( D\b,  [d.\b(:,1) d.\b(:,2)]) 
   assertEqual( D'\b, [conj(d).\b(:,1) conj(d).\b(:,2)])
   assertEqual( D.'\b, [d.\b(:,1) d.\b(:,2)]) 
end
