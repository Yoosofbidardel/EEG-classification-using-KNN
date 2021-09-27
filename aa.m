clc;
clear all;
load('data_set_IVa_aa.mat');
%% preprocessing
fs=100;
acc=0;
% sum1=0;
% sum2=0;
KNN=5; % length of algorithm
tp=0;
fp=0;
fn=0;
Number_of_data=length(find(mrk.y==1))+length(find(mrk.y==2));
new_mrk = mrk.pos(1:Number_of_data);
Loo=1:length(new_mrk);
Y       = mrk.y(1:Number_of_data)  ;
e1      = new_mrk(Y==1);
e2      = new_mrk(Y==2); %beginig of thinking class 2
[b,a]   = butter(5,[8 30]*2/fs);
filter = filtfilt(b,a,double(cnt));
new_cnt=(filter-mean(filter)).'; % data is ready to be processed.

%% asserting E's value
for i=1:length(new_mrk)
   E(:,:,i) = new_cnt(:,new_mrk(i)+(fs/2):new_mrk(i)+(3*fs/2)-1);%for picking test and train data
end



 for i=1:Number_of_data
    %% feature extraction
    X_test =E(:,:,i);
    X_train(:,:,1:Number_of_data-1) =E(:,:,Loo(Loo~=i)); %on every itaration Loo which is defined at first,has valuse of 1:150 except i.
    y_test=Y(i);
    y_train=Y(Loo(Loo~=i));
    sum1=0;
    sum2=0;
    for j=find(y_train==1)
        sum1=sum1+(X_train(:,:,j)*X_train(:,:,j).');
    end                
    c1=(1/length(find(y_train==1)))*sum1; %covariance1
    for j=find(y_train==2)
        sum2=sum2+(X_train(:,:,j)*X_train(:,:,j).');
    end                
    c2=(1/length(find(y_train==2)))*sum2; %covariance2
    
    [W,R]=eig(c2\c1);
    R=sum(R); % to put them in one row where each is represented as an eignvalue
    Wopt1=W(:,R==max(R));
    Wopt2=W(:,R==min(R));
    %% power of classes
    p1=0;
    p2=0;
    for l=1:length(y_train)
        p1=p1+1;
        powerx_clss(p1) = (Wopt1.')*X_train(:,:,l)*(X_train(:,:,l).')*Wopt1;
    end
    for l=1:length(y_train) 
        p2=p2+1;
        powery_clss(p2) = (Wopt2.')*X_train(:,:,l)*(X_train(:,:,l).')*Wopt2;
    end
   
 
%% test power
powery_test=(Wopt2.')*X_test*(X_test.')*Wopt2;
powerx_test=(Wopt1.')*X_test*(X_test.')*Wopt1;
%% Knn calculation
for j=1:Number_of_data-1
    distannce(j)=sqrt((powerx_test-powerx_clss(j))^2 + (powery_test-powery_clss(j))^2);
end
dis=sort(distannce);
diss=dis(1:KNN);% 5 nearest.
%k=5 so we tend to calculate just 5 of the nearests.
class1=0;
class2=0;
for j=1:KNN
    if y_train(distannce==(diss(j)))==1  % because powerx_clss is sorted like class1:class2
        class1=class1+1;
    else
        class2=class2+1;
    end    
end
if class1>class2
    Y_predict=1;
else
    Y_predict=2;
end

if Y_predict==y_test
    
    acc=acc+1;
    
end
%% Precision & Recall  class1 is considered as the Positive one
if Y_predict==y_test && y_test==1
    tp=tp+1;
end
if Y_predict~=y_test && y_test==2
    fn=fn+1;
end
if Y_predict~=y_test && y_test==1
    fp=fp+1;
end


    
   


 end
 
 accuracy = (acc/length(new_mrk))*100;
 precision = tp/(tp+fp)*100;
 Recall = tp/(tp+fn)*100;
 F1_score=2*Recall*precision/(precision+Recall);
 T=table(accuracy,precision,Recall,F1_score);
 disp(T);

 %% ploting the last train
hold on
suptitle('last sampel');
powerx_cls1=powerx_clss(y_train==1);
powery_cls1=powery_clss(y_train==1);
powerx_cls2=powerx_clss(y_train==2);
powery_cls2=powery_clss(y_train==2);

stem(powerx_cls1,powery_cls1,'LineStyle','none',...
      'MarkerFaceColor','y','MarkerEdgeColor','red')
xlabel('W1_power');
ylabel('W2_power');
stem(powerx_cls2,powery_cls2,'LineStyle','none',...
      'MarkerFaceColor','blue','MarkerEdgeColor','red')
stem(powerx_test,powery_test,'LineStyle','none',...  
      'MarkerFaceColor','g','MarkerEdgeColor','red')%  test sample

hold off


    
    
   

  
      


