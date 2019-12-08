function Data_Viewer
	f = figure('Name','Memristor measurement data viewer','NumberTitle','off','MenuBar','none','Units','normal',...
	'Position',[0,.042,1,.94],'Color',[0.7,0.7,0.7],'CloseRequestFcn',@my_closereq,'KeyPressFcn',@keydetect);
	ax = axes('Parent',f,'OuterPosition',[-0.05,0,0.7,1],'Color','k','XGrid','on','YGrid','on','GridColorMode','manual',...
	'NextPlot','replacechildren','GridColor','w','XMinorGrid','on','YMinorGrid','on','MinorGridColor','w');
	ax.Title.String = 'Scope data';
	ax.XLabel.String = 'Time, us';
	ax.YLabel.String = 'Voltage, V';
	plot(ax,linspace(0,1),cos(linspace(0,1)),'y',linspace(0,1),sin(linspace(0,1)),'c',linspace(0,1),tan(linspace(0,1)),'m');
	lgd = legend(ax,{'Load Resistor Voltage','Input Voltage','Memristor Voltage'},'TextColor','w');
	legend(ax,'boxoff');
	text(0.01,0.98,'May the memristor switch for you today, good sir!','Interpreter','none','Units','normalized','Backgroundcolor','none','FontUnits','normalized','FontSize',0.03,'color','w','parent',ax)		
	%interpreter is an interesting command. Google "TeX Markup" and "Text Properties"
	
%	uit = uitable('Parent',f,'Units','pix','FontUnits','normalized','FontSize',0.02,'Position',[1450,100,100,600],'cellSelectionCallback',@cell_select);
	uit_param = uitable('Parent',f,'Units','normalized','FontName','FixedWidth','FontUnits','normalized','FontSize',0.018,'RowName',[],...
	'ColumnName',{'Process';'Pulse width, us';'Rise time, us';'Slope';'SET Voltage';'RESET Voltage';'Rload, Ohm'},...
	'Position',[0.59,0.05,0.4,0.8],'Visible','off','cellSelectionCallback',@cell_select); %,'KeyPressFcn',@keydetect);

%	'FontUnits','normalized','FontSize',0.02
	
	Path_button = uicontrol('Parent',f,'Units','normal','String','Folder','FontUnits','normalized','FontSize',0.4,'Position',[0.91,0.9,0.08,0.05],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);	
	Path_button.Callback = @Pathbutton;
	Next_File_button = uicontrol('Parent',f,'String','NEXT','Units','normal','FontUnits','normalized','FontSize',0.4,'Position',[0.8,0.9,0.07,0.05],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Next_File_button.Callback = @NextFilebutton;
	Previous_File_button = uicontrol('Parent',f,'String','PREV','Units','normal','FontUnits','normalized','FontSize',0.4,'Position',[0.72,0.9,0.07,0.05],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Previous_File_button.Callback = @PreviousFilebutton;
	
	filter_button = uicontrol('Parent',f,'Style','togglebutton','String','Filter OFF','FontUnits','normalized','FontSize',0.4,'Units','normal','Position',[.6,.9,.07,.05],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	filter_button.Callback = @filtering;
	
%	Filenum = uicontrol('Parent',f,'Style','edit','Units','normal','String','Current file','FontUnits','normalized','FontSize',0.5,'Position',[0.816,0.8,0.08,0.03]);
%	Current_file = uicontrol('Parent',f,'Style','edit','Units','normal','String','1','FontUnits','normalized','FontSize',0.5,'Position',[0.816,0.85,0.08,0.03]);
%	Current_file.Callback = @retrieve_Current_file;
	
	oldfolder = cd;
	
	path = '';
	i = 1;
	max_i = 1;

	percent_x = [];
	analysis_x_points = [];
	analysis_y_points = [];
	slope = [];
	
	
	%data filtering
	windowSize = 5;
	filt = (1/windowSize)*ones(1,windowSize);
	filter_on = 0;
		
	function Pathbutton(src,event)
		path = uigetdir;
		i = 1;
		draw;
		Fileimport;
		end
		
	function NextFilebutton(src,event)
		if i < max_i
			i = i+1;
			Current_file.String = num2str(i);
			draw;
			scroll_table;
			end
		end
		
	function PreviousFilebutton(src,event)
		if i > 1
			i = i-1;
			Current_file.String = num2str(i);
			draw;
			scroll_table;
			end
		end
		
	function filtering(src,event)
		button_state = get(src,'Value');
		if button_state == 1
			filter_button.BackgroundColor = 'k';
%			filter_button.Foregroundcolor = 'k';
			filter_on = 1;
			filter_button.String = 'Filter ON';
			else 
			filter_on = 0;
			filter_button.BackgroundColor = 'k';
			filter_button.String = 'Filter OFF';
			end
		draw;
		end
	
	function retrieve_Current_file(src,event)
		i = str2double(get(src,'string'));
		draw;
		scroll_table;
		end
	
	function cell_select(src,event)			%drawing from cell selection
		cell_indices = event.Indices;		%this returns (row,column)
		i = cell_indices(1);
		Current_file.String = num2str(i);
		draw;
		end
	
	function draw			%an easy way of saving time #Lazy
		cd(path);
		if exist(sprintf('%d_SET.txt', i))  == 2 
			data = importdata(sprintf('%d_SET.txt', i));
			Filenum.String = sprintf('%d_SET', i);
			elseif exist(sprintf('%d_RESET.txt', i))  == 2
			data = importdata(sprintf('%d_RESET.txt', i));
			Filenum.String = sprintf('%d_RESET', i);
			elseif exist(sprintf('%d_READ1.txt', i))  == 2
			data = importdata(sprintf('%d_READ1.txt', i));
			Filenum.String = sprintf('%d_READ1', i);
			elseif exist(sprintf('%d_READ2.txt', i))  == 2
			data = importdata(sprintf('%d_READ2.txt', i));
			Filenum.String = sprintf('%d_READ2', i);
			end
		if filter_on == 1;
			data(:,2) = filter(filt,1,data(:,2));
			data(:,3) = filter(filt,1,data(:,3));
			end
		plot(ax,data(:,1),data(:,2),'y',data(:,1),data(:,3),'c',data(:,1),data(:,3)-data(:,2),'m');
%		slope_calculation
		data = [];
		cd(oldfolder);
		text(0.01,0.98,Filenum.String,'Interpreter','none','Units','normalized','Backgroundcolor','none','FontUnits','normalized','FontSize',0.03,'color','w','parent',ax)
%		text(0.01,0.94,slope(1),'Interpreter','none','Units','normalized','Backgroundcolor','none','FontUnits','normalized','FontSize',0.03,'color','w','parent',ax)
		end
	
	function slope_calculation		%not working properly
		percent_x = floor(length(data)/100);
		analysis_x_points = [percent_x*10,percent_x*11,percent_x*12,percent_x*13,percent_x*14,percent_x*15,percent_x*16,percent_x*17,percent_x*18,percent_x*19,percent_x*20,];
		for k = 1:11
			analysis_y_points(k) = data(analysis_x_points(k),3);
			end
		for k = 1:10
			slope(k) = (analysis_y_points(k+1)-analysis_y_points(k))/(data(analysis_x_points(k),1)-data(analysis_x_points(k),1));			%problematic
			end
		end
	
	function Fileimport
		cd(path);
		data = struct2table(dir);
		data = sortrows(data, 'date');
		data = table2cell(data);
		o = 1;
		for k = 1:length(data)						%forming a deletion vector in order to delete from the end afterwards. deleting from starting edge would result in an error
			if data{k,4} == 1 | strcmp(data{k,1}, 'Parameters.txt')
				deletion_rows(o) = k;
				o = o+1;
				end
			end
		deletion_rows = fliplr(deletion_rows);		%this one flips the vector left-to-right making it possible to do it from behind ;)
		for k = 1:length(deletion_rows)				%error avoidance. was possible if we deleted from the start, and less rows were available each step, therefore reducing matrix dimensions
			data(deletion_rows(k),:) = [];			%and trying to delete row 5 out of 4 rows (<- example)
			end
		for k = 1:length(data)						%removing ".txt'
			data{k,1} = data{k,1}(1:end-4);
			end
%		parameters = num2cell(importdata('Parameters.txt'));
%		uit.Data = [data(:,1),parameters];
%		uit.Data = data(:,1);
%		uit.ColumnName = {};
%		uit.RowName = {};
		uit_param.Data = [data(:,1),num2cell(importdata('Parameters.txt'))];
		cd(oldfolder);
		max_i = length(data);
		uit_param.Visible = 'on';
		end
	
	function scroll_table
%		jUIScrollPane = findjobj_fast(uit);				%BlackBox 	(downloaded Java Tricks) to scroll table
%		jUITable = jUIScrollPane.getViewport.getView;	%BlackBox 	(downloaded Java Tricks) to scroll table
%		jUITable.changeSelection(i-1,1, false, false);	%BlackBox 	(downloaded Java Tricks) to scroll table
		jUIScrollPane = findjobj_fast(uit_param);				%BlackBox 	(downloaded Java Tricks) to scroll table
		jUITable = jUIScrollPane.getViewport.getView;	%BlackBox 	(downloaded Java Tricks) to scroll table
		jUITable.changeSelection(i-1,1, false, false);	%BlackBox 	(downloaded Java Tricks) to scroll table
		end
		
	function my_closereq(src,callbackdata)
		% Close request function 
		selection = questdlg('Close The Program?',...
		'',...
		'Yes','No','Yes'); 
		switch selection 
			case 'Yes'
			delete(gcf)
			case 'No'
			return
			end
		end
	
	function keydetect(src,event)
		switch event.Key
			case 'rightarrow'
				NextFilebutton;
			case 'downarrow'
				NextFilebutton;
			case 'leftarrow'
				PreviousFilebutton;
			case 'uparrow'
				PreviousFilebutton;
			end
%		fprintf(strcat(event.Key,'\n'));	%debug
		end
end