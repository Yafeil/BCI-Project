function [sys,x0,str,ts] = zhhm(t,x,u,flag,Host,Socket,...
    NumCustomCmds,ISI,SimNumTrials,ResetSpellerPeriod,PausePeriod,SampleRate,Determination,channels,selectchannles,BaseAver,rep,targetp,starget,traintime)
% H,P,S,
%H,P,S,NumRows,NumCols,NumCustomCmds,CustomFlashCmd,ShowLetterCmd,ResetSpel
%lerCmd,ISI,SimNumTrials,LetterIndices,ShowLetterPeriod,ResetSpellerPeriod,PausePeriod
% see also:
%
% Reference(s):

%	$Revision: 0.10 $
%	$Id: mfRemoteScope.m$
%	Copyright (C) 2001-2004 by Reinhold Scherer
%	Reinhold.Scherer@TUGraz.at
%   This is part of the rtsBCI/BIOSIG-toolbox http://biosig.sf.net/

%	$Revision: 0.20 $
%	$Id: mfp300_without_fb.m$
%	petar.horki@student.tugraz.at

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.

global rtBCI

persistent NOT_READY
persistent READY
persistent TRUE
persistent FALSE
NOT_READY = 0;
READY = 1;
FALSE = 0;
TRUE = 1;

switch flag,
    case 0
        %%%%%%%%%%%%%%%%%%
        % Initialization %
        %%%%%%%%%%%%%%%%%%
        [sys,x0,str,ts]=mdlInitializeSizes;
        %load D:\competition\AB116\modeo      
        load ('C:\cj\cjdata\test\mode','CRF');
        %%%%%%%% the path of the built mode in offline period%%%%%%%%%
        gUDPcloseALL;
        pnet('closeall');
        rtBCI.SampleRate=SampleRate;
        tss=inv(rtBCI.SampleRate);
        splitIndex = strfind(Host,';');
        rtBCI.host1 = Host(1:splitIndex-1);
        rtBCI.host2 = Host(splitIndex+1:end);
        
        splitIndex = strfind(Socket,';');
        rtBCI.socket1 = str2double(Socket(1:splitIndex-1));
        rtBCI.socket2 = str2double(Socket(splitIndex+1:end));
         rtBCI.h1=gUDPinit(rtBCI.socket1);
%          if (Determination)
%              rtBCI.h2=pnet('tcpconnect',rtBCI.host2,rtBCI.socket2);
%          else
             rtBCI.h2 = -1;
%          end
         rtBCI.mfp300_without_fb.NumCustomCmds=NumCustomCmds;
        rtBCI.mfp300_without_fb.TrialCounter = 0;
        rtBCI.mfp300_without_fb.indices=[];
        rtBCI.mfp300_without_fb.starget=starget;
        if rtBCI.mfp300_without_fb.starget==1
            rtBCI.mfp300_without_fb.Letters=targetp(1:8);
        elseif rtBCI.mfp300_without_fb.starget==2
            rtBCI.mfp300_without_fb.Letters=targetp(9:16);
        elseif rtBCI.mfp300_without_fb.starget==3
            rtBCI.mfp300_without_fb.Letters=targetp(17:24);
        elseif rtBCI.mfp300_without_fb.starget==4
             rtBCI.mfp300_without_fb.Letters=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 1 2 3];
         elseif rtBCI.mfp300_without_fb.starget==5     
               rtBCI.mfp300_without_fb.Letters=ones(1,100);
               
        end
        rtBCI.mfp300_without_fb.ISI=round(ISI/tss/1000);
        rtBCI.mfp300_without_fb.ResetSpellerInterval=round(ResetSpellerPeriod/tss/1000);
        rtBCI.mfp300_without_fb.PauseInterval=round(PausePeriod/tss/1000);
        rtBCI.mfp300_without_fb.outputtime=round(PausePeriod/tss/1000);
        rtBCI.mfp300_without_fb.wait=round(10000/tss/1000);
        rtBCI.mfp300_without_fb.Status  = NOT_READY;
        rtBCI.mfp300_without_fb.decision=Determination;
        rtBCI.mfp300_without_fb.SimNumTrials=SimNumTrials;
        rtBCI.mfp300_without_fb.selectchannles=selectchannles;
        rtBCI.mfp300_without_fb.sefigure=0;
        rtBCI.b.verbose=CRF.LDA.b.verbose;
        rtBCI.b.evidence=CRF.LDA.b.evidence;
        rtBCI.b.beta=CRF.LDA.b.beta;
        rtBCI.b.w=CRF.LDA.b.w;
        rtBCI.b.alpha=CRF.LDA.b.alpha;
        rtBCI.b.p=CRF.LDA.b.p;
        rtBCI.n.min=CRF.LDA.n.min;
        rtBCI.n.max=CRF.LDA.n.max;
        rtBCI.n.mean=CRF.LDA.n.mean;
        rtBCI.n.std=CRF.LDA.n.std;
        rtBCI.n.method=CRF.LDA.n.method;
        rtBCI.w.limit_l=CRF.LDA.w.limit_l;
        rtBCI.w.limit_h=CRF.LDA.w.limit_h;
        rtBCI.mfp300_without_fb.EvPos = channels;
        rtBCI.mfp300_without_fb.lof=CRF.FrequencyBandl;
        rtBCI.mfp300_without_fb.hif=CRF.FrequencyBandh;
        rtBCI.resetBuff=0;
        rtBCI.Counternumber(1:rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials)=1;
        rtBCI.result=zeros(rtBCI.mfp300_without_fb.NumCustomCmds,1);
        rtBCI.result1=zeros(rtBCI.mfp300_without_fb.NumCustomCmds,1);
        rtBCI.Buff=zeros(rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials,...
            floor(rtBCI.SampleRate/10*8)-1,rtBCI.mfp300_without_fb.EvPos);
        rtBCI.mfp300_without_fb.waitCounter=0;
        rtBCI.count=0;
        rtBCI.count1=0;
        rtBCI.count2=0;
        rtBCI.count3=1;
        rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,'399');
        rtBCI.count4=1;
        rtBCI.mfp300_without_fb.ISICnt=0;
      
        rtBCI.count=0;
        rtBCI.mfp300_without_fb.ShowLetter=FALSE;
        rtBCI.mfp300_without_fb.ResetSpeller=FALSE;
        rtBCI.mfp300_without_fb.ShowLetterCounter=0;
        rtBCI.mfp300_without_fb.ResetSpellerCounter=0;
        rtBCI.mfp300_without_fb.ShowLetterState=FALSE;
        rtBCI.mfp300_without_fb.ShowLetterStateCounter=0;
        rtBCI.mfp300_without_fb.ResetSpellerState=FALSE;
        rtBCI.mfp300_without_fb.Pause=FALSE;
        rtBCI.mfp300_without_fb.PauseState=FALSE;
        rtBCI.mfp300_without_fb.PauseCounter=0;
        rtBCI.mfp300_without_fb.state=0;
        rtBCI.mfp300_without_fb.stateva=0;
        rtBCI.mfp300_without_fb.state=0;
        rtBCI.mfp300_without_fb.traintime=traintime;
        rtBCI.mfp300_without_fb.outputcount=0;
        rtBCI.mfp300_without_fb.staterecore=0;
        rtBCI.mfp300_without_fb.showresultstat=TRUE;
        rtBCI.mfp300_without_fb.indicesCnt1=0;
        rtBCI.mfp300_without_fb.indicesCnt2=1;
        rtBCI.mfp300_without_fb.tell=1;
        rtBCI.mfp300_without_fb.charasav=85;
        rtBCI.mfp300_without_fb.baseAvT=BaseAver;
        rtBCI.mfp300_without_fb.tell2=1;
        rtBCI.mfp300_without_fb.tell3=85;
        rtBCI.mfp300_without_fb.showresultstat4=TRUE;
        rtBCI.mfp300_without_fb.rep=rep;
        rtBCI.mfp300_without_fb.SPN=29;
        rtBCI.mfp300_without_fb.stage1=1;
        rtBCI.mfp300_without_fb.indicesCnt1=0;
        rtBCI.mft=0;
        rtBCI.mfp300_without_fb.outputcount=0;
        rtBCI.mfp300_without_fb.staterecore=0;
        rtBCI.mfp300_without_fb.state=0;
        rtBCI.mfp300_without_fb.showresultstat=TRUE;
        rtBCI.mfp300_without_fb.ISI1Cnt=0;
        rtBCI.mfp300_without_fb.ISI2Cnt=0;
        rtBCI.mfp300_without_fb.ISI3Cnt=0;
        rtBCI.mfp300_without_fb.ISI4Cnt=0;
        rtBCI.mfp300_without_fb.indicesCnt=0;
        rtBCI.mfp300_without_fb.label=1;
        rtBCI.mfp300_without_fb.tasknum=0;
        rtBCI.mfp300_without_fb.out=0;
%         lastone=randperm(12);
%         dirsel=randperm(2);
%         rtBCI.lastone=lastone(1)-1;
%         for i = 1:rtBCI.mfp300_without_fb.SimNumTrials
%             indices = rtBCI.mfp300_without_fb.indices;
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%             %add the new problem
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
%             if rtBCI.mfp300_without_fb.NumCustomCmds==12
%                 indices2 = getorder1(rtBCI.mfp300_without_fb.NumCustomCmds,rtBCI.lastone,dirsel);
%             end
%             rtBCI.mfp300_without_fb.indices = [indices indices2];
%             if dirsel(1)==1
%                 rtBCI.lastone=rtBCI.mfp300_without_fb.indices(end)+1;
%                 if rtBCI.lastone>11
%                     rtBCI.lastone= rtBCI.lastone-rtBCI.mfp300_without_fb.NumCustomCmds;
%                 end
%             elseif  dirsel(1)==2
%                 rtBCI.lastone=rtBCI.mfp300_without_fb.indices(end)-1;
%                 if rtBCI.lastone<0
%                     rtBCI.lastone=rtBCI.lastone+rtBCI.mfp300_without_fb.NumCustomCmds;
%                 end
%             end
%         end

rtBCI.mfp300_without_fb.indices = [];
% indexM = zeros(5,9);
% ttar = [1 2 3 7 8 9 10 11 12];
% indexM(1,:) = [11 1 2 3 7 8 9 10 12];
% indexM(2,:) = [12 1 2 11 7 3 8 9 10];
% indexM(3,:) = [9 12 11 8 1 3 2 7 10];
% indexM(4,:) = [8 3 1 2 12 11 7 9 10];
% indexM(5,:) = [11 1 3 2 7 12 8 9 10];

% indexM( randi(5),:)-1

lastone=randperm(12);
rtBCI.lastone=lastone(1);
for i = 1:rtBCI.mfp300_without_fb.SimNumTrials
    indices = rtBCI.mfp300_without_fb.indices;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %add the new problem
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
    if rtBCI.mfp300_without_fb.NumCustomCmds==12
        indices2 = getorder(rtBCI.mfp300_without_fb.NumCustomCmds,rtBCI.lastone);
    end
    rtBCI.mfp300_without_fb.indices = [indices indices2];
    rtBCI.lastone=rtBCI.mfp300_without_fb.indices(end);
    
end

    case 3
        %%%%%%%%%%%
        % Outputs %
        %%%%%%%%%%%
        sys=[10,10,10,10];
        if rtBCI.count2==0
            rtBCI.mfp300_without_fb.waitCounter=rtBCI.mfp300_without_fb.waitCounter+1;
            if rtBCI.mfp300_without_fb.wait*.2==rtBCI.mfp300_without_fb.waitCounter  % ???????
                ts=inv(rtBCI.SampleRate);
                rtBCI.mfp300_without_fb.waitCount=0;
                rtBCI.count2=1;
                rtBCI.mfp300_without_fb.Status=READY;
                rtBCI.mfp300_without_fb.ISICnt=0;
                rtBCI.mfp300_without_fb.indicesCnt=0;
                rtBCI.mfp300_without_fb.commands=[];
                rtBCI.mfp300_without_fb.Pause=TRUE;
            end
        end
        % status is ready if an event arrived recently
        if rtBCI.mfp300_without_fb.Status == READY
            if(TRUE==rtBCI.mfp300_without_fb.Pause)
                if(FALSE==rtBCI.mfp300_without_fb.PauseState)
                    %                     UDP command reseting the speller to initial state
                   
                    % add event to file containing command plus index
                    rtBCI.mfp300_without_fb.PauseState=TRUE;
                    rtBCI.mfp300_without_fb.out=rtBCI.mfp300_without_fb.Letters(rtBCI.mfp300_without_fb.tasknum+1)-1;
                    rtBCI.mfp300_without_fb.out=rtBCI.mfp300_without_fb.out+200;
                    rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,num2str(rtBCI.mfp300_without_fb.out));
                    % display(['send: ' num2str(rtBCI.mfp300_without_fb.out)]);
%                     rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.mfp300_without_fb.h1,Host,Socket,num2str(rtBCI.mfp300_without_fb.out+200));
                end
                rtBCI.mfp300_without_fb.PauseCounter = rtBCI.mfp300_without_fb.PauseCounter+1;
                if(rtBCI.mfp300_without_fb.PauseCounter==rtBCI.mfp300_without_fb.traintime*rtBCI.mfp300_without_fb.PauseInterval)%  2S
                    rtBCI.mfp300_without_fb.PauseCounter=0;
                    rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,num2str('299'));
                    rtBCI.mfp300_without_fb.Pause=FALSE;
%                     rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.mfp300_without_fb.h1,rtBCI.host2,Socket,'4 ');
                    rtBCI.mfp300_without_fb.ResetSpeller=TRUE;
                    
                end
            elseif(TRUE==rtBCI.mfp300_without_fb.ResetSpeller)
                
                % generate random indices of patterns to be flashed
                rtBCI.mfp300_without_fb.PauseCounter =  rtBCI.mfp300_without_fb.PauseCounter+1;
                if(rtBCI.mfp300_without_fb.PauseCounter==200)%  2S
                    rtBCI.mfp300_without_fb.PauseCounter=0;
                  rtBCI.mfp300_without_fb.ResetSpeller=FALSE;
                    %                     rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.mfp300_without_fb.h1,rtBCI.host2,Socket,'4 ');
                   
                  sys=[50,10,10,10];
                end
            elseif((FALSE == rtBCI.mfp300_without_fb.Pause) && (FALSE == rtBCI.mfp300_without_fb.ResetSpeller))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
                %added new problem
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
                if rtBCI.count1>rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials
                    rtBCI.count1=rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials;
                end
                if rtBCI.mfp300_without_fb.staterecore==0&&rtBCI.mfp300_without_fb.indicesCnt1>0
                    for i=1+rtBCI.count: rtBCI.count1
                        mid=isnan(u);
                        u(mid)=100;
                        rtBCI.Buff(i,rtBCI.Counternumber(i),1:rtBCI.mfp300_without_fb.EvPos)=u(selectchannles);
                        rtBCI.Counternumber(i)=rtBCI.Counternumber(i)+1;
                        rtBCI.count3=rtBCI.count3+1;
                        if  rtBCI.Counternumber(rtBCI.count+1)==floor(rtBCI.SampleRate/10*8);
                            rtBCI.count3=1;
                            buff3(:,:)=squeeze(rtBCI.Buff(rtBCI.count+1,1:(floor(rtBCI.SampleRate/10*8)-1),1:rtBCI.mfp300_without_fb.EvPos))';
                            rtBCI.count=rtBCI.count+1;
                            for mm=1:rtBCI.mfp300_without_fb.EvPos
                                buff4(mm,:)=filter(rtBCI.mfp300_without_fb.lof,rtBCI.mfp300_without_fb.hif,buff3(mm,:));
                            end
                            clear buff3;
                            buff5(:,:)=squeeze(buff4(1:rtBCI.mfp300_without_fb.EvPos,1:7:(floor(rtBCI.SampleRate/10*8)-1)));
                            clear buff4;
                            if rtBCI.mfp300_without_fb.decision==1
                                buff5 = applyw(rtBCI.w, buff5);
                                buff2 = applyn(rtBCI.n, buff5);
                                buff=reshape(buff2, 1,rtBCI.mfp300_without_fb.SPN*(rtBCI.mfp300_without_fb.EvPos));
                                d2 = classifybye(rtBCI.b, buff');%real
                            else d2 = 1;%test
                            end
                            rtBCI.result(rtBCI.mfp300_without_fb.indices(rtBCI.mfp300_without_fb.indicesCnt2)+1,1)=d2;
                            rtBCI.mfp300_without_fb.indicesCnt2=rtBCI.mfp300_without_fb.indicesCnt2+1;
                            rtBCI.count4= rtBCI.count4+1;
                            if rtBCI.count4>rtBCI.mfp300_without_fb.NumCustomCmds
                                rtBCI.result1=rtBCI.result+rtBCI.result1;
                                rtBCI.mft= rtBCI.mft+1;
                                [vau2 ord2]=sort(rtBCI.result1,'descend');
%                                 if rtBCI.mfp300_without_fb.NumCustomCmds==rtBCI.mfp300_without_fb.NumCustomCmds
                                    ord3=sort(ord2(1:2));
                                    [d5] = selectletter12(ord3(1),ord3(2));
                                     % display([ num2str(ord3)]);
%                                 end
                                 if (rtBCI.mft>=rtBCI.mfp300_without_fb.baseAvT&&rtBCI.mfp300_without_fb.charasav==d5)...
                                        ||(rtBCI.mfp300_without_fb.baseAvT==1&&rtBCI.mfp300_without_fb.rep==1);
                                    rtBCI.mfp300_without_fb.tell=rtBCI.mfp300_without_fb.tell+1;
                                    rtBCI.mfp300_without_fb.tell2=rtBCI.mfp300_without_fb.tell2+1;
                                end
                                if (rtBCI.mfp300_without_fb.tell2>=rtBCI.mfp300_without_fb.rep&&rtBCI.mfp300_without_fb.showresultstat4==TRUE&&...
                                        rtBCI.mft>=rtBCI.mfp300_without_fb.baseAvT)||(rtBCI.mft>(rtBCI.mfp300_without_fb.SimNumTrials-4)&&...
                                    rtBCI.mfp300_without_fb.showresultstat4==TRUE)
                                    rtBCI.mfp300_without_fb.tell3=d5;
                                    rtBCI.mfp300_without_fb.label=0;
                                    rtBCI.mfp300_without_fb.showresultstat4=FALSE;
                                    rtBCI.mfp300_without_fb.state=1;
                                    rtBCI.mfp300_without_fb.staterecore=1;
                                    beep;
                                end
                                if rtBCI.mfp300_without_fb.charasav~=d5
                                    rtBCI.mfp300_without_fb.tell=1;
                                    rtBCI.mfp300_without_fb.tell2=1;
                                end
                                rtBCI.mfp300_without_fb.charasav=d5;
                                rtBCI.count4=1;
                            end
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %MVEP
                %%%%%%%%%%5
                if rtBCI.mfp300_without_fb.state==0&&rtBCI.mfp300_without_fb.label==1
                    if rtBCI.mfp300_without_fb.stage1==1
                        rtBCI.mfp300_without_fb.indicesCnt = ...
                            rtBCI.mfp300_without_fb.indicesCnt+1;
                        rtBCI.mfp300_without_fb.indicesCnt1=rtBCI.mfp300_without_fb.indicesCnt1+1;
                        rtBCI.count1=rtBCI.count1+1;
                        rtBCI.mfp300_without_fb.stage1=0;
                        rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,num2str(rtBCI.mfp300_without_fb.indices(rtBCI.mfp300_without_fb.indicesCnt)+101));
                        % display(['2: ' num2str(rtBCI.mfp300_without_fb.indices(rtBCI.mfp300_without_fb.indicesCnt)+101)])
                        sys(2)=rtBCI.mfp300_without_fb.indices(rtBCI.mfp300_without_fb.indicesCnt)+1+200;
                    end
                    rtBCI.mfp300_without_fb.ISICnt=rtBCI.mfp300_without_fb.ISICnt+1;
                    if rtBCI.mfp300_without_fb.ISICnt==rtBCI.mfp300_without_fb.ISI
                        rtBCI.mfp300_without_fb.stage1=1;
                        rtBCI.mfp300_without_fb.ISICnt=0;
                    end
                end
                if rtBCI.mfp300_without_fb.state==1
                    %P300RESULT
                    if rtBCI.mfp300_without_fb.decision==1
                        if rtBCI.mfp300_without_fb.showresultstat==TRUE%%%
                            letterInd = rtBCI.mfp300_without_fb.tell3; %real
                            
%                             tcpComm = TCPfeecback(letterInd);
                            letterInd=letterInd+300;
%                             % % display([ num2str(letterInd)]);
                            rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,num2str(letterInd));
                            % display(['3: ' num2str(letterInd)]);
%                             if (~isempty(tcpComm))
%                                 pnet(rtBCI.h2,'write', tcpComm );
%                             end
%                             % display(tcpComm);
                            
                            sys(4)=letterInd;
                            rtBCI.mfp300_without_fb.showresultstat=FALSE;
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
                    rtBCI.mfp300_without_fb.outputcount=rtBCI.mfp300_without_fb.outputcount+1;
                    
                    if rtBCI.mfp300_without_fb.outputcount>rtBCI.mfp300_without_fb.outputtime/2% 0.5 S
                        rtBCI.count=0;
                        rtBCI.count1=0;
                        rtBCI.mfp300_without_fb.charasav=85;
                        rtBCI.mfp300_without_fb.tasknum=rtBCI.mfp300_without_fb.tasknum+1;
                        rtBCI.mfp300_without_fb.label=1;
                        rtBCI.count4=1;
                        rtBCI.mfp300_without_fb.indicesCnt=0;
                        rtBCI.mfp300_without_fb.indicesCnt1=0;
                        rtBCI.mfp300_without_fb.indicesCnt2=1;
                        rtBCI.mfp300_without_fb.ISI1Cnt=0;
                        rtBCI.mfp300_without_fb.ISICnt=0;
                        rtBCI.Buff=zeros(rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials,floor(rtBCI.SampleRate/10*8)-1,rtBCI.mfp300_without_fb.EvPos);
                        rtBCI.result=zeros(rtBCI.mfp300_without_fb.NumCustomCmds,1);
                        rtBCI.result1=zeros(rtBCI.mfp300_without_fb.NumCustomCmds,1);
                        rtBCI.Counternumber(1:rtBCI.mfp300_without_fb.NumCustomCmds*rtBCI.mfp300_without_fb.SimNumTrials)=1;
                        rtBCI.mfp300_without_fb.Pause=TRUE;
                        rtBCI.mfp300_without_fb.PauseState=FALSE;
                        rtBCI.mfp300_without_fb.stage1=1;
                        rtBCI.mft=0;
                        rtBCI.mfp300_without_fb.outputcount=0;
                        rtBCI.mfp300_without_fb.staterecore=0;
                        rtBCI.mfp300_without_fb.state=0;
                        rtBCI.mfp300_without_fb.showresultstat=TRUE;
                        rtBCI.mfp300_without_fb.showresultstat4=TRUE;
                        rtBCI.mfp300_without_fb.tell=1;
                        rtBCI.mfp300_without_fb.tell2=1;
                        rtBCI.mfp300_without_fb.tell3=85;
                        rtBCI.mfp300_without_fb.ISICnt=0;
                        rtBCI.mfp300_without_fb.Pause=TRUE;
                    end
                end
                
            end
        end
        
        
        
        
        
    case 9
        %%%%%%%%
        % stop %
        %%%%%%%%
%           rtBCI.mfp300_without_fb.nrByte=gUDPsend(rtBCI.h1,rtBCI.host1,rtBCI.socket1,'4 ');
    
        gUDPclose(rtBCI.h1)
         pnet('closeall');
          sys=[];
        
    case { 1, 2, 4}
        %%%%%%%%%%%%%%%%%%%
        % Unhandled flags %
        %%%%%%%%%%%%%%%%%%%
        sys=[];
        
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Unexpected flags (error handling)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        error(['Unhandled flag = ',num2str(flag)]);
end

%==========================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%==========================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 4;
sizes.NumInputs      = -1;  % dynamically sized
sizes.DirFeedthrough = 1;   % has direct feedthrough
sizes.NumSampleTimes = 1;

sys=simsizes(sizes);
str = [];
x0  = [];
ts  = [-1 0];   % inherited sample time
%=================================================================
%LDA
function [d2] = LDAtest(samples,V,p1,p2,u1,u2,L1,L2)

samples=samples';
m_size = size(samples);
m = m_size(2);
inV = inv(V);
A1 = inV*u1;
B1 = 0.5*(u1'*A1);
lgp1 = log(p1);

A2 = inV*u2;
B2 = 0.5*(u2'*A2);
lgp2 = log(p2);
for i=1:m
    d1 = samples(:,i)'*A1-B1+lgp1;
    d2 = samples(:,i)'*A2-B2+lgp2;
end
%===========================================================19
%select

%===========================================================14
%select
function s = TCPfeecback(num1)
if (num1<26)
    c1 = ['00' char(num1 + 'A')];
elseif (num1 < 36)
    c1 = ['00' char(num1 - 26 + '0')];
elseif (num1 == 36)
    c1 = '00,';
elseif (num1 == 37)
    c1 = '00.';
elseif (num1 == 38)
    c1 = '00_';
elseif (num1 == 39)
    c1 = '00?';
elseif (num1 == 40)
    c1 = '111';
else
%     % display(num1);
    s = '';
    return;
end

s = ['BCIID01CH' c1];


function [d] = selectletter12(number1,number2)
%%%%%%%%line1
if number1==1&&number2==4
    d=0;
elseif number1==1&&number2==5
    d=1;
elseif number1==1&&number2==6
    d=2;
elseif number1==1&&number2==7
    d=3;
elseif number1==1&&number2==8
    d=4;
elseif number1==1&&number2==9
    d=5;
elseif number1==2&&number2==10
    d=6;
elseif number1==2&&number2==5
    d=7;
elseif number1==2&&number2==6
    d=8;
elseif number1==2&&number2==7
    d=9;
elseif number1==2&&number2==8
    d=10;
elseif number1==2&&number2==9
    d=11;
    %%%%%%%%%%%%%%%line2
elseif number1==3&&number2==10
    d=12;
elseif number1==3&&number2==11
    d=13;
elseif number1==3&&number2==6
    d=14;
elseif number1==3&&number2==7
    d=15;
elseif number1==3&&number2==8
    d=16;
elseif number1==3&&number2==9
    d=17;
elseif number1==4&&number2==10
    d=18;
elseif number1==4&&number2==11
    d=19;
elseif number1==4&&number2==12
    d=20;
elseif number1==4&&number2==7
    d=21;
elseif number1==4&&number2==8
    d=22;
elseif number1==4&&number2==9
    d=23;
    %%%%%%%%%%%%%%%line3
elseif number1==5&&number2==10
    d=24;
elseif number1==5&&number2==11
    d=25;
elseif number1==5&&number2==12
    d=26;
elseif number1==1&&number2==10
    d=27;
elseif number1==5&&number2==8
    d=28;
elseif number1==5&&number2==9
    d=29;
elseif number1==6&&number2==10
    d=30;
elseif number1==6&&number2==11
    d=31;
elseif number1==6&&number2==12
    d=32;
elseif number1==3&&number2==12
    d=33;
elseif number1==2&&number2==11
    d=34;
elseif number1==6&&number2==9
    d=35;
% elseif number1==7&&number2==10
%     d=36;
% elseif number1==7&&number2==11
%     d=37;
% elseif number1==7&&number2==12
%     d=38;
% elseif number1==8&&number2==11
%     d=39;
% elseif number1==8&&number2==12
%     d=40;
% elseif number1==9&&number2==12
%     d=41;
else
    d=74;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%classifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
function varargout = classifybye(b, x)
x = [x; ones(1,size(x,2))];


%% compute mean of predictive distributions
m = b.w'*x;


%% if one output argument return mean only
if nargout == 1
    varargout(1) = {m};
end


%% if two output arguments compute and return variance also
if nargout == 2
    s = zeros(1,size(x,2));
    for i = 1:size(x,2);
        s(i) = x(:,i)'*b.p*x(:,i) + (1/b.beta);
    end
    varargout(1) = {m};
    varargout(2) = {s};
end

if nargout > 2
    fprintf('Too many output arguments!\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%applyn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
function x = applyn(n, x)

n_channels = size(x,1);
n_samples  = size(x,2);
n_trials   = size(x,3);

x = reshape(x,n_channels,n_samples*n_trials);

switch n.method
    
    case 'minmax'
        x = x -  repmat(n.min,1,n_samples*n_trials);
        x = x ./ repmat(n.max-n.min,1,n_samples*n_trials);
        x = 2*x - ones(n_channels,n_samples*n_trials);
        
    case 'z-score'
        x = x -  repmat(n.mean,1,n_samples*n_trials);
        x = x ./ repmat(n.std,1,n_samples*n_trials);
        
    otherwise
        fprintf('unknown normalization method');
        
end

x = reshape(x,n_channels,n_samples,n_trials);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%applyw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
function x = applyw(w, x)
n_channels = size(x,1);
n_samples  = size(x,2);
n_trials   = size(x,3);


%% clip the data
x = reshape(x,n_channels,n_samples*n_trials);
l = repmat(w.limit_l',1,n_samples*n_trials);
h = repmat(w.limit_h',1,n_samples*n_trials);
i_l = x < l;
i_h = x > h;
x(i_l) = l(i_l);
x(i_h) = h(i_h);
x = reshape(x,n_channels, n_samples, n_trials);

function indord = getorder(NumCustomCmds,lastone)
eleNum=NumCustomCmds;
enlab=eleNum-1;
seableNum=4;
indord=ones(1,eleNum)*12;
t=1;
if lastone==0;
    tx=randperm(4);
        if tx(1)==1
            a1=1;
        elseif tx(1)==2
            a1=2;
        elseif tx(1)==3
            a1=NumCustomCmds-1;
        elseif tx(1)==4
            a1=NumCustomCmds-2;
        end
end
if lastone>0
    if lastone==NumCustomCmds-1
        tx=randperm(4);
        if tx(1)==1
            a1=0;
        elseif tx(1)==2
            a1=1;
        elseif tx(1)==3
            a1=NumCustomCmds-2;
        elseif tx(1)==4
            a1=NumCustomCmds-3;
        end
    elseif lastone==NumCustomCmds-2
        tx=randperm(4);
        if tx(1)==1
            a1=NumCustomCmds-1;
        elseif tx(1)==2
            a1=0;
        elseif tx(1)==3
            a1=NumCustomCmds-3;
        elseif tx(1)==4
            a1=NumCustomCmds-4;
        end
    elseif lastone==1
        tx=randperm(4);
        if tx(1)==1
            a1=2;
        elseif tx(1)==2
            a1=3;
        elseif tx(1)==3
            a1=0;
        elseif tx(1)==4
            a1=NumCustomCmds-1;
        end
    elseif lastone==2
        tx=randperm(4);
        if tx(1)==1
            a1=1;
        elseif tx(1)==2
            a1=0;
        elseif tx(1)==3
            a1=3;
        elseif tx(1)==4
            a1=4;
        end
    else
        tx=randperm(4);
        if tx(1)==1
            a1=lastone+1;
        elseif tx(1)==2
            a1=lastone+2;
        elseif tx(1)==3
            a1=lastone-1;
        elseif tx(1)==4
            a1=lastone-2;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555?????2???

indord(1,t)=a1;%obtain the first order
t=t+1;
atrp=100;
vec1=[a1-2, a1-1, a1+1, a1+2]; %obtain selectable order
for ivec=1:seableNum
    if vec1(ivec)<0
        vec1(ivec)=vec1(ivec)+eleNum;
    end
    if vec1(ivec)>=eleNum;
        vec1(ivec)=mod(vec1(ivec),eleNum);
    end
end  %get the standard order
serse=randperm(seableNum); %get random selectable order
lab2=serse(1);
a1=vec1(lab2);
indord(1,t)=a1;%obtain next order
t=t+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5???????????
vec1=[a1-2, a1-1, a1+1, a1+2];
for ivec=1:seableNum
    if vec1(ivec)<0
        vec1(ivec)=vec1(ivec)+eleNum;
    end
    if vec1(ivec)>=eleNum;
        vec1(ivec)=mod(vec1(ivec),eleNum);
    end
end %obtain selectable order
tord=randperm(seableNum);
t1=tord(1);
n1=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5 ???????????
while t<eleNum+1 % stop time
    ord=sort(indord(1,1:t-1)); % find the order seri
    of=1;
    clear sudif
    for tnum=1:t-2
        sudif(of)=ord(tnum+1)-ord(tnum);
        if sudif(of)>7
            sudif(of)=eleNum-sudif(of);
        end
        of =of+1;
    end
    if ord(1)==0&&ord(end)==enlab
        sudif(of)=1;
    end
    label=2; %?????????????????sudif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5555??????????????1?
    while sum((find(sudif>1)))&&(~sum((find(sudif==1))))&&t<eleNum+1 %when no serial order% first
        n1=2;
        while sum(find(indord==vec1(1,t1))) %ontian the right order
            t1=tord(n1);
            n1=n1+1;
        end
        clear sudif
        a1=vec1(t1);
        indord(1,t)=a1;
        t=t+1;      %????????????????????
        %%%%%%%%%%%%%%%%%%%%5
        ord=sort(indord(1,1:t-1));
        of=1;
        for tnum=1:t-2
            sudif(of)=ord(tnum+1)-ord(tnum);
            if sudif(of)>7
                sudif(of)=eleNum-sudif(of);
            end
            of =of+1;
        end
        if ord(1)==0&&ord(end)==enlab
            sudif(of)=1;
        end                                        %?????????????????sudif
        vec1=[a1-2, a1-1, a1+1, a1+2];
        for ivec=1:seableNum
            if vec1(ivec)<0
                vec1(ivec)=vec1(ivec)+eleNum;
            end
            if vec1(ivec)>=eleNum;
                vec1(ivec)=mod(vec1(ivec),eleNum);
            end
        end
        tord=randperm(seableNum);
        t1=tord(1);
        label=1;
    end
    %%%%%%%%%%%%%%%%%%%%%%???1?????????????
    while sum((find(sudif>1)))&&sum(find(sudif==1))&&t<eleNum+1 &&label==1;%sun3
        compaind=(indord(1,t-1)-indord(1,t-2));
        if abs(compaind)>7
            compaind=compaind-eleNum;
        end
        if compaind<-7
            compaind=(eleNum+compaind);%11    13     0     2
            
        end %????????????????????
        if compaind>0&&t<eleNum+1 %??????
            while t<eleNum+1&&sum((find(sudif>1)))&&sum(find(sudif==1))
                if (~sum(find(indord==(mod(a1+1,eleNum)))))&&sum((find(sudif>1)))&&sum(find(sudif==1)) %??????1????????1
                    indord(1,t)=mod(a1+1,eleNum);
                    a1=mod(a1+1,eleNum);
                    t=t+1;
                elseif (~sum(find(indord==(mod(a1+1,eleNum)))))&&~sum((find(sudif>1)))&&sum(find(sudif==1))
                    label=2;
                else
                    if ~sum(find(indord==(mod(a1+2,eleNum))))&&sum((find(sudif>1)))&&sum(find(sudif==1))...
                            &&sum(find(indord==(mod(a1+1,eleNum))))&&sum(find(indord==(mod(a1+1,eleNum))))       %%??????2????????2
                        
                        indord(1,t)=mod(a1+2,eleNum);
                        a1=mod(a1+2,eleNum);
                        t=t+1;
                    end
                end
            end
        end
        if compaind<0&&t<eleNum+1 %??????
            while t<eleNum+1&&sum((find(sudif>1)))&&sum(find(sudif==1))
                if  (~sum(find(indord==(mod(a1-1+eleNum,eleNum)))))&&sum((find(sudif>1)))&&sum(find(sudif==1)) %??????1????????1
                    indord(1,t)=mod(a1-1+eleNum,eleNum);
                    a1=mod(a1-1+eleNum,eleNum);
                    t=t+1;
                elseif (~sum(find(indord==(mod(a1-1,eleNum)))))&&~sum((find(sudif>1)))&&sum(find(sudif==1))
                    label=2;
                else
                    if ~sum(find(indord==(mod(a1-2+eleNum,eleNum))))&&sum((find(sudif>1)))...
                            &&sum(find(sudif==1))&&sum(find(indord==(mod(a1-1,eleNum))))               %??????2????????2
                        indord(1,t)=mod(a1-2+eleNum,eleNum);
                        a1=mod(a1-2+eleNum,eleNum);
                        t=t+1;
                    end
                end
            end
        end
        clear sudif
        ord=sort(indord(1,1:t-1));
        of=1;
        for tnum=1:t-2
            sudif(of)=ord(tnum+1)-ord(tnum);
            if sudif(of)>7
                sudif(of)=eleNum-sudif(of);
            end
            of =of+1;
        end
        if ord(1)==0&&ord(end)==enlab
            sudif(of)=1;
        end                                               %?????????????????sudif
        if (~sum(find(indord==(mod(a1-1,eleNum)))))&&~sum((find(sudif>1)))&&sum(find(sudif==1))% ??????????????2?
            label=2;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    while (~sum((find(sudif>1))))&&sum(find(sudif==1))&&t<eleNum+1&&label~=1% when only seri%second??????????????2?
        n1=2;
        while sum(find(indord==vec1(1,t1)))
            t1=tord(n1);
            n1=n1+1;
        end
        a1=vec1(t1);
        indord(1,t)=a1;
        
        t=t+1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
        ord=sort(indord(1,1:t-1));
        of=1;
        for tnum=1:t-2
            sudif(of)=ord(tnum+1)-ord(tnum);
            if sudif(of)>7
                sudif(of)=eleNum-sudif(of);
            end
            of =of+1;
        end
        if ord(1)==0&&ord(end)==enlab
            sudif(of)=1;
        end                                                            %?????????????????sudif??undainad
        vec1=[a1-2, a1-1, a1+1, a1+2];
        for ivec=1:seableNum
            if vec1(ivec)<0
                vec1(ivec)=vec1(ivec)+eleNum;
            end
            if vec1(ivec)>=eleNum;
                vec1(ivec)=mod(vec1(ivec),eleNum);
            end
        end
        tord=randperm(seableNum);
        t1=tord(1);
        label=2;
    end
    %%%%%%%%%%%%%%%%%%%%%%5???2?????????????
    while sum((find(sudif>1)))&&sum(find(sudif==1))&&t<eleNum+1&&label==2; %sun3
        compaind=(indord(1,t-1)-indord(1,t-2));
        if abs(compaind)>7
            compaind=compaind-eleNum;
        end
        if compaind<-7
            compaind=(eleNum+compaind);
            
        end  %????????????????????
        if compaind>0&&t<eleNum+1 %?????
            while t<eleNum+1
                if (~sum(find(indord==(mod(a1+2,eleNum))))) %??????1????????2
                    indord(1,t)=(mod(a1+2,eleNum));
                    a1=(mod(a1+2,eleNum));
                    t=t+1;
                else
                    if ~sum(find(indord==(mod(a1+1,eleNum))))&&sum(find(indord==(mod(a1+2,eleNum))))  %??????2????????1
                        indord(1,t)=(mod(a1+1,eleNum));
                        a1=(mod(a1+1,eleNum));
                        t=t+1;
                    elseif ~sum(find(indord==(mod(a1-1+eleNum,eleNum))))&&sum(find(indord==(mod(a1+2,eleNum))))  %??????3????????1
                        indord(1,t)=(mod(a1-1+eleNum,eleNum));
                        a1=(mod(a1-1+eleNum,eleNum));
                        t=t+1;
                    else
                        if ~sum(find(indord==(mod(a1-2+eleNum,eleNum))))&&sum(find(indord==(mod(a1-1,eleNum)))) %??????4????????2
                            indord(1,t)=mod(a1-2+eleNum,eleNum);
                            a1=mod(a1-2+eleNum,eleNum);
                            t=t+1;
                        end
                    end
                end
            end
        end
        
        
        if compaind<0&&t<eleNum+1  %?????
            while t<eleNum+1&&sum(find(sudif==1))&&t<eleNum+1&&label==2;
                
                if (~sum(find(indord==mod((a1-2+eleNum),eleNum))))&&sum(find(sudif==1))&&t<eleNum+1&&label==2; %??????1????????2
                    indord(1,t)=mod((a1-2+eleNum),eleNum);
                    a1=mod((a1-2+eleNum),eleNum);
                    t=t+1;
                else
                    if ~sum(find(indord==mod((a1-1+eleNum),eleNum)))&&...
                            sum(find(sudif==1))&&t<eleNum+1&&label==2&&sum(find(indord==mod((a1-2+eleNum),eleNum)))   %??????2????????1
                        
                        indord(1,t)=mod((a1-1+eleNum),eleNum);
                        a1=mod((a1-1+eleNum),eleNum);
                        t=t+1;
                    elseif ~sum(find(indord==mod((a1+1),eleNum)))&&sum(find(indord==mod((a1-1+eleNum),eleNum)))....
                            &&sum(find(sudif==1))&&t<eleNum+1&&label==2&&sum(find(indord==mod((a1-1+eleNum),eleNum))) %??????3????????1
                        indord(1,t)=mod((a1+1),eleNum);
                        a1=mod((a1+1),eleNum);
                        t=t+1;
                    else
                        if ~sum(find(indord==mod((a1+2),eleNum)))&&sum(find(sudif==1))&&...
                                t<eleNum+1&&label==2&&sum(find(indord==mod((a1-2+eleNum),eleNum)))  %??????4????????2
                            indord(1,t)=mod((a1+2),eleNum);
                            a1=mod((a1+2),eleNum);
                            t=t+1;
                        end
                    end
                end
            end
        end
        clear sudif
        ord=sort(indord(1,1:t-1));
        of=1;
        for tnum=1:t-2
            sudif(of)=ord(tnum+1)-ord(tnum);
            if sudif(of)>7
                sudif(of)=eleNum-sudif(of);
            end
            of =of+1;
        end
        if ord(1)==0&&ord(end)==enlab
            sudif(of)=1;
        end                                              %?????????????????sudif??undainad
        if (~sum(find(indord==(mod(a1-1,eleNum)))))&&~sum((find(sudif>1)))&&sum(find(sudif==1))
            label=2;
        end                            % ??????????????2?
    end
end
%% 
function indord = getorder1(NumCustomCmds,startpoint,dirsel)
indord=ones(1,NumCustomCmds)*18;
indord(1)=startpoint;
for i=2:NumCustomCmds
    if dirsel(1)==1
        startpoint=startpoint+1;
        if startpoint<NumCustomCmds
            indord(i)=startpoint;
        end
        if startpoint>(NumCustomCmds-1)
            startpoint=startpoint-NumCustomCmds;
               indord(i)=startpoint;
        end
    elseif dirsel(1)==2
         startpoint=startpoint-1;
         if startpoint>-1
            indord(i)=startpoint;
         end
         if startpoint<0
            startpoint=startpoint+NumCustomCmds;
            indord(i)=startpoint;
         end
    end
end