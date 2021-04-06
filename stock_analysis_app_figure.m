function stock_analysis_app_figure()
close all; clear;
global pathname_excel loadnum filename button_dist width_button...
    num_value str_value length_button top_button_pos button_gap fontval S...
    s3 s4  count2 handles
fontval=12;
top_button_pos=0.9;
width_button=0.06;
length_button=0.7;
button_gap=0.03;
button_dist=0.04;
pathname_excel=[];
filename={};
loadnum=0;
count2=false;
version_num=1;
handles.carmodel={};
handles.fileno=[];
data={};
num_value={};
str_value={};
%handles.year={};
S.fh = figure('units','normalized',...
    'position',[0.15 0.2 .65 0.65],...
    'menubar','figure',...
    'name','Verify Password.',...
    'resize','on',...
    'numbertitle','off',...
    'name',strcat(['Stock data analysis code: Version ',num2str(version_num)]));
panel=uipanel(S.fh,'Units','normalized','position',[0 0 .3 1]);


S.hp1=uipanel('BackgroundColor','white',...
    'units','pixels','Position',[20 80 280 80],'Title','Status Bar');
S.hp1.Units='normalized';
S.figure_window = uipanel('BackgroundColor','white',...
    'units','normalized','Position',[0.3,0,0.69,0.99],'Title','Figure Window');


S.date_bar=uicontrol(panel,'Style','edit','units','normalized','Position',[0.1 (top_button_pos-button_gap) length_button width_button],...
    'String',date,'Callback',@curdate);
button_gap=button_gap+2*button_dist;
S.pb_input = uicontrol(panel,'style','push',...
    'units','normalized',...
    'position',[0.1 (top_button_pos-button_gap) length_button width_button],...
    'HorizontalAlign','left',...
    'string','Load input files',...
    'fontsize',fontval,'FontName','Calibri','fontweight','bold','Callback',@load_excel_files);
button_gap=button_gap+2*button_dist;
S.ed_search = uicontrol(panel,'style','edit',...
    'units','normalized',...
    'position',[0.1 (top_button_pos-button_gap) length_button width_button],...
    'HorizontalAlign','center',...
    'string','Stock Name',...
    'fontsize',fontval,'FontName','Calibri','fontweight','normal','Callback',@search_name,'ButtonDownFcn',@clear_val);
button_gap=button_gap+2*button_dist;
S.pb_analysis = uicontrol(panel,'style','push',...
    'units','normalized',...
    'position',[0.1 (top_button_pos-button_gap) length_button width_button],...
    'HorizontalAlign','left',...
    'string','Perform Analysis',...
    'fontsize',fontval,'FontName','Calibri','fontweight','bold','Callback',@data_analysis);
button_gap=button_gap+2*button_dist;
handles.axis1=subplot(3,1,1,'parent',S.figure_window);
handles.axis2=subplot(3,1,2,'parent',S.figure_window);
handles.axis3=subplot(3,1,3,'parent',S.figure_window);

axes(handles.axis1)
axis off
axes(handles.axis2)
axis off
axes(handles.axis3)
axis off

s3=subplot(2,1,1,'parent',S.hp1);
s4=subplot(2,1,2,'parent',S.hp1);
axes(s3)
axis off
axes(s4)
axis off
end
function[]= data_analysis(~,~)
    global handles s3 s4 S
stock_name=get(S.ed_search,'string');
stock_name=upper(stock_name);
handles.stockdata=getMarketDataViaYahoo(stock_name,'1-Jan-2014',datetime('today')+1,'1d');
timeseries_stockdata=table2timetable(handles.stockdata);
sma= indicators(timeseries_stockdata.AdjClose,'sma',20);
ema= indicators(timeseries_stockdata.AdjClose,'ema',9);
atr=indicators([timeseries_stockdata.High,timeseries_stockdata.Low,timeseries_stockdata.Close],'atr');
don_dn=indicators([timeseries_stockdata.High,timeseries_stockdata.Low],'donchain');
DON_down=don_dn(:,1);
rsi=rsindex(timeseries_stockdata);
[MACDLine,SignalLine] = macd(timeseries_stockdata);
TMW=timeseries_stockdata;
TMW.Volume = []; % remove VOLUME field
% momentum = tsmom(TMW);
%obv = onbalvol(TMW);
% plot(momentum.Time,momentum.Variables)
% legend('OPEN','HIGH','LOW','CLOSE')

%%%
%stock_name='TSLA';
options = weboptions('ContentType','text', 'UserAgent', 'Mozilla/5.0');
travel_data = webread(['https://finance.yahoo.com/calendar/earnings?symbol=',stock_name],options);
travel_data_tree = htmlTree(travel_data);
selector = "td";
subtrees = findElement(travel_data_tree,selector);
str = extractHTMLText(subtrees);
table_data = str(1:end); % first three elements are just the column names
reshape_ncols=6;
reshape_nrows = length(table_data)/reshape_ncols;
table_data_reshaped = reshape(table_data,reshape_ncols,reshape_nrows)';
earning_data_table = array2table(table_data_reshaped,'VariableNames',["Ticker" "Name" "EarningDate" "EPSEstimate" "EPSReported" "Surprise"]);
str_check=earning_data_table.EarningDate;
if(~isempty(str_check))
    ind=regexp(str_check,',');
    for ii=1:length(ind)
        str_val{ii}=str_check{ii}(1:ind{ii}(1,2)-1);
    end
    date=datetime(str_val,'InputFormat','MMM d,yyyy');
    earning_data_table.EarningDate=date';
end


axes(s3)
cla(s3)
text(0,0,[stock_name,' data found']);
axes(s4)
axis off
cla(s4)
text(0,0,'Plotting data...');
axes(handles.axis1)
cla(handles.axis1)
candle(timeseries_stockdata);
hold(handles.axis1,'on')
plot(timeseries_stockdata.Date,ema,'-k','linewidth',1.5);
title(handles.axis1,'Price & EMA');
xlim([(datetime('today')-day(150)) datetime('today')])

axes(handles.axis2)
cla(handles.axis2)
plot(timeseries_stockdata.Date,rsi.RelativeStrengthIndex,'-k','linewidth',1.5);
ybars = [30 70];
hold(handles.axis2,'on')
fill(handles.axis2,[datetime(timeseries_stockdata.Date(1,1)) datetime(timeseries_stockdata.Date(end,1)) datetime(timeseries_stockdata.Date(end,1)) datetime(timeseries_stockdata.Date(1,1))],[ybars(1) ybars(1) ybars(2) ybars(2)],'blue','FaceAlpha',0.5)
title(handles.axis2,'RSI');
xlim([(datetime('today')-day(150)) datetime('today')])

axes(handles.axis3)
cla(handles.axis3)
plot(handles.axis3,MACDLine.Time,MACDLine.Close,SignalLine.Time,SignalLine.Close,'linewidth',1.5);
title(handles.axis3,'MACD');
xlim([(datetime('today')-day(150)) datetime('today')])


axes(s4)
cla(s4)
text(0,0,'Data Plotted');
end

 function search_name(~,~)
 global handles s6 S
 s6=get(S.ed_search,'string');
 if isempty(s6)
     set(S.ed_search,'String','Stock Name');
     set(S.ed_search,'Enable', 'inactive');
 else
     s6=get(S.ed_search,'String');
     set(S.ed_search,'Enable', 'inactive');
 end
 handles.name_search=s6;
 %guidata(hObject,handles)
 end
 
 function clear_val(hObj, event) %#ok<INUSD>
global S
  set(S.ed_search, 'String', '', 'Enable', 'on');
  uicontrol(hObj); % This activates the edit box and 
                   % places the cursor in the box,
                   % ready for user input.

end