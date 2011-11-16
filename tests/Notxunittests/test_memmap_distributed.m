function test_distributed()
if isempty(whos('global','SDCglobalTmpDir'))
    SeisDataContainer_init();
end
disp('Start');
gstart=tic;
assert(matlabpool('size')>0,'matlabpool has to be open first')
Il=2; Jl=2; Kl=2;
I=matlabpool('size')*Il; J=matlabpool('size')*Jl; K=matlabpool('size')*Kl;
disp([I J K])
imat3=distributed.rand(I,J,K);
imat3=complex(imat3,imat3);
spmd
    codistr = codistributor1d(2,codistributor1d.unsetPartition,[I J K]);
    myLocalPart = rand(I,Jl,K);
    imat2 = codistributed.build(myLocalPart, codistr);
end

disp('distributed header')
tic
hdrb=DataContainer.basicHeaderStructFromX(imat3);
hdrx=DataContainer.addDistHeaderStructFromX(hdrb,imat3);
hdrd=DataContainer.addDistHeaderStruct(hdrb,hdrx.distribution.dim,[]);
assert(isequal(hdrx,hdrd),'distributions do not match')
toc

disp('global write')
tic
td=ConDir();
DataContainer.io.memmap.dist.FileWrite(path(td),imat3,0);
toc
disp('global read')
tic
[x hdrn] = DataContainer.io.memmap.dist.FileRead(path(td));
toc
disp('global read slice and verify')
tic
for k=1:K
    x = DataContainer.io.memmap.dist.FileReadLeftSlice(path(td),[k]);
    assert(isequal(x,imat3(:,:,k)),'no match')
    fprintf('%d ',k)
end
fprintf('\n')
toc

disp('global alloc')
tic
td=ConDir();
hdrs=DataContainer.basicHeaderStructFromX(imat3);
DataContainer.io.memmap.serial.FileAlloc(path(td),hdrs);
toc
disp('global write slice')
tic
for k=1:K
    DataContainer.io.memmap.dist.FileWriteLeftSlice(path(td),imat2(:,:,k),[k])
    fprintf('%d ',k)
end
fprintf('\n')
toc
disp('global read slice and verify')
tic
for k=1:K
    x = DataContainer.io.memmap.dist.FileReadLeftSlice(path(td),[k]);
    assert(isequal(imat2(:,:,k),x))
    fprintf('%d ',k)
end
fprintf('\n')
toc
disp('global distribute 1st')
tic
tdo=ConDir();
tdod=ConDistDirs();
DataContainer.io.memmap.dist.FileDistribute(path(td),path(tdo),path(tdod),1);
toc
disp('global distribute 2nd')
tic
tdod=ConDistDirs();
DataContainer.io.memmap.dist.FileDistribute(path(td),path(tdo),path(tdod),2);
toc
disp('global distribute 3rd')
tic
tdod=ConDistDirs();
DataContainer.io.memmap.dist.FileDistribute(path(td),path(tdo),path(tdod),3);
toc
disp('global distribute 3rd verify')
tic
cmat = DataContainer.io.memmap.dist.FileRead(path(tdo));
assert(isequal(gather(imat2),gather(cmat)))
toc

disp('distributed write')
tic
td=ConDir();
tdd=ConDistDirs();
DataContainer.io.memmap.dist.FileWrite(path(td),imat3,1,path(tdd));
toc
disp('distributed read')
tic
[x hdrn] = DataContainer.io.memmap.dist.FileRead(path(td));
toc

disp('distributed alloc')
tic
td=ConDir();
tdo=ConDir();
tdd=ConDistDirs();
hdrs=DataContainer.basicHeaderStructFromX(imat3);
hdrs=DataContainer.addDistHeaderStruct(hdrs,hdrs.dims-1,[]);
hdrs=DataContainer.io.addDistFileHeaderStruct(hdrs,path(tdd));
DataContainer.io.memmap.dist.FileAlloc(path(td),hdrs);
toc
disp('distributed write slice')
tic
for k=1:K
    DataContainer.io.memmap.dist.FileWriteLeftSlice(path(td),imat2(:,:,k),[k])
    fprintf('%d ',k)
end
fprintf('\n')
toc
disp('distributed read slice')
tic
for k=1:K
    x = DataContainer.io.memmap.dist.FileReadLeftSlice(path(td),[k]);
    assert(isequal(imat2(:,:,k),x))
    fprintf('%d ',k)
end
fprintf('\n')
toc
disp('distributed gather')
tic
DataContainer.io.memmap.dist.FileGather(path(td),path(tdo));
toc
disp('distributed gather verify')
tic
cmat = DataContainer.io.memmap.serial.FileRead(path(tdo));
assert(isequal(gather(imat2),gather(cmat)))
toc

disp('Done');
disp(toc(gstart));
end
