clc;
clear all;
load 'data_set_IVa_av.mat';
fs=100;
sum1=0;
sum2=0;
acc=0;
NumberData=length(find(mrk.y==1))+length(find(mrk.y==2));
newMrk = mrk.pos(1:NumberData);
Loop=1:length(newMrk);
M = mrk.y(1:NumberData)  ;
[b,a]=butter(5,[8 30]*2/fs);
filter=filtfilt(b,a,double(cnt));
newCnt=(filter - mean(filter)).'; 
for i=1:length(newMrk)
   E(:,:,i) = newCnt(:,newMrk(i)+(fs/2):newMrk(i)+(3*fs/2)-1);
end
 for i=1:NumberData
    X_test =E(:,:,i);
    X_train(:,:,1:NumberData-1) =E(:,:,Loop(Loop~=i)); %on every itaration Loo which is defined at first,has valuse of 1:150 except i.
    y_test=M(i);
    y_train=M(Loop(Loop~=i));
    for j=find(y_train==1)
        sum1=sum1+(X_train(:,:,j)*X_train(:,:,j).');
    end                
    c1=(1/length(find(y_train==1)))*sum1; 
    for j=find(y_train==2)
        sum2=sum2+(X_train(:,:,j)*X_train(:,:,j).');
    end                
    c2=(1/length(find(y_train==2)))*sum2; 
    [W,Result]=eig(inv(c2)*c1);
    Result=sum(Result); 
    Wopt1=W(:,Result==max(Result));
    Wopt2=W(:,Result==min(Result));

    p1=0;
    p2=0;
    Power_y_test=(Wopt2.')*X_test*(X_test.')*Wopt2;
    Power_x_test=(Wopt1.')*X_test*(X_test.')*Wopt1;
    for l=1:length(y_train)
        p1=p1+1;
        Power_x_clss(p1) = (Wopt1.')*X_train(:,:,l)*(X_train(:,:,l).')*Wopt1;
    end
    for l=1:length(y_train) 
        p2=p2+1;
        Power_y_clss(p2) = (Wopt2.')*X_train(:,:,l)*(X_train(:,:,l).')*Wopt2;
    end
    for j=1:NumberData-1
        A1=(Power_x_test-Power_x_clss(j))^2;
        A2=(Power_y_test-Power_y_clss(j))^2;
        distannce(j)=sqrt(A1+ A2);
    end
    d=sort(distannce);
    D=d(1:5);
    class1=0;
    class2=0;
    for j=1:5
        if y_train(distannce==(D(j)))==1 
            class1=class1+1;
        else
            class2=class2+1;
        end    
    end
    if class1>class2
        Y_pre=1;
    else
        Y_pre=2;
    end

    if Y_pre==y_test

        acc=acc+1;
    end


    
   


 end
 
 accuracy = (acc/length(newMrk))*100;
 




    
    
   

  
      


