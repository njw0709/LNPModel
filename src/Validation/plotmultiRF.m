function plotmultiRF()
% Original receptive field plotting script

close all;

[txt_name, txtfile_path] = uigetfile('*.ker', 'Import Ker files','Multiselect','on');
if(~iscell(txt_name))
    txt_name = {txt_name};
end

h = figure;
set(h, 'units','normalized','outerposition',[0 0 1 1])
figpos=getpixelposition(h);
resolution=get(0,'ScreenPixelsPerInch');
set(h,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution])

set(gcf,'DefaultAxesFontName','Myriad Pro');

load('RKB.mat');

count = 1;
for tal = 1:length(txt_name)
    
    txtfile_name = txt_name{tal};
    
    [ker_struct, ~, ~] = ui_load_ker(txtfile_path,txtfile_name);

    ker = ker_struct.ker;
    ktime = ker_struct.ker_time;

    if(tal==1)
        ha = tight_subplot(length(txt_name),size(ker,3)+1,0.005);
    end
    
    subplot(ha(tal+(tal-1)*10));
    lastdot_pos = find(txtfile_name == '_', 1, 'last');
    nm1 = txtfile_name(1:lastdot_pos-1);
    nm2 = txtfile_name(lastdot_pos:end);
    nm = sprintf('%s\n%s',nm1,nm2);
    text(0,0.5,nm,'Interpreter','none','Color','red',...
        'FontSize',14);
    set(gca, 'visible', 'off');
    
    for k = 1:size(ker,3)
        
        subplot(ha(count+1));
        
        currker = ker(:,:,k);
        
        contour_RF(gca, currker, 0, color_map, 0);
        
        if(tal==1)
        %if(count<=size(ker,3))
            tit = title(sprintf('t = %d',floor(ktime(k))));
            set(tit,'FontSize',12);
        end
        
        if(mod(count+1,size(ker,3)+1))
            count = count+1;
        else
            count = count+2;
        end
    end
end

%tight_subplot(length(txt_name),size(ker,3)+1, [0.1 1], 1, 1);

tightfig(gcf);

end

function [ker_struct, flag] = load_ker(f_spec)

%LOAD_KER loads contents from a .KER file.
%   
%   ker_struct = LOAD_KER(f_spec) generates a structure ker_struct with 
%   fields ker_time, ker, conter, win_size and comments, as contained in 
%   the .KER file specified by f_spec.
%   
%   [ker_struct, flag] = LOAD_KER(f_spec) returns a second output flag 
%   which equals to 1 upon successful loading, to 0 when loading fails.
%   
%   Xin Wang, October 2005.

ker_struct.ker_time = [];
ker_struct.ker = [];
% ker_struct.center = [];
% ker_struct.win_size = [];
ker_struct.comments = '';
flag = 0;

try
    f_struct = load(f_spec, '-mat');
    var_name_cell = fieldnames(f_struct);
    ker_struct = getfield(f_struct, var_name_cell{1});
    flag = 1;
catch
    ker_struct.ker_time = [];
    ker_struct.ker = [];
%     ker_struct.center = [];
%     ker_struct.win_size = [];
    ker_struct.comments = '';
    flag = 0;
end
end

function [ker_struct, txtfile_name, flag] = ui_load_ker(txtfile_path,txtfile_name)

[ker_struct, flag] = load_ker([txtfile_path, txtfile_name]);
prompt = {'Input Start Frame:'};
dlg_title = 'Input Start Frame';
num_lines = 1;
def = {'1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

startfrm= str2double(answer{1});

%ker_struct.ker = ker_struct.ker;
ker_struct.ker = ker_struct.ker./max(max(max(abs(ker_struct.ker))));

ker_struct.ker = ker_struct.ker(:,:,startfrm:end);
ker_struct.ker_time = ker_struct.ker_time(startfrm:end);
ker_size = size(ker_struct.ker);

[x, y, t] = size(ker_struct.ker);
if ~(x == y) || ~(x <= 16 || x == 32 || x == 64)
    flag = 0;
    %     error('Incompatible Kernel File!');
end

end

function contour_RF(h, frame, absmx, color_map, ttl)

% [x_size, y_size] = size(frame);
% frame = frame / absmx;
% levels = -1 : 0.1 : 1;
% 
% axes(h); cla;
% contourf(frame, levels, 'LineStyle', 'none');
% colormap(color_map);
% caxis([-1 1]);
% 
% % % %Cell G 
% % %  a1=0.51; b1= 0.58; x10= 7.83; y10= 9.12; theta1= 0.43;
% % %  RF1.a= a1; RF1.b= b1; RF1.x0= x10; RF1.y0= y10; RF1.theta= theta1;  
% % % % % %% Param for Ganglion Input RF
% % % % %% LARGE
% % % % Cell E
% % % a2= 0.66; b2= 0.85; x20= 7.24; y20= 10.43; theta2= -0.09;
% % % RF2.a= a2; RF2.b= b2; RF2.x0= x20; RF2.y0= y20; RF2.theta= theta2;  
% % % 
% % 
% % % %Cell I
% % %  a1=0.70; b1= 1.66; x10= 6.34; y10= 8.25; theta1= -0.25;
% % %  RF1.a= a1; RF1.b= b1; RF1.x0= x10; RF1.y0= y10; RF1.theta= theta1;  
% % % % % %% Param for Ganglion Input RF
% % % % %% LARGE
% % % % Cell J
% % % a2= 0.66; b2= 0.94; x20= 9.56; y20= 7.14; theta2= -0.11;
% % % RF2.a= a2; RF2.b= b2; RF2.x0= x20; RF2.y0= y20; RF2.theta= theta2;  
% 
% 
% for y = 1 : y_size +1
%     line([y-.5 y-.5], [0.5 x_size+0.5], 'LineWidth', 0.25, 'Color', 'k');
% end
% for x = 1 : x_size +1
%     line([0.5 y_size+0.5], [x-.5 x-.5], 'LineWidth', 0.25, 'Color', 'k');
% end
% %   draw_ellipse(gca, -theta1, y10, x10, b1, a1, [1 1 0], '-');
% %   %% large  
% %   draw_ellipse(gca, -theta2, y20, x20, b2, a2, [1 1 1], '-');
% 
% % rectangle('Position', [yl, xl, yu-yl+1e-20, xu-xl+1e-20], 'EdgeColor', 'y', 'LineWidth', 2);
% 
% %% Original by Xin
% set(h, 'XTick', [], 'YTick', [], 'YDir', 'Rev', 'DataAspectRatioMode', 'manual', ...
%     'YLim', [.5, x_size + .5], 'XLim', [.5, y_size + .5], 'Color', 'k', 'DataAspectRatio', [1 1 1]);
% %  set(h, 'XTick', [], 'YTick', [], 'YDir', 'Rev', 'DataAspectRatioMode', 'manual', ...
% %      'YLim', [1.5, x_size - .5], 'XLim', [1.5, y_size - .5], 'Color', 'k', 'DataAspectRatio', [1 1 1]);
% 
% 
% title(ttl);
% %colorbar;


%%%%%%%%%%%%%%%%%%%% BY VISHAL
[x_size, y_size] = size(frame);
% button = questdlg('Normalize RF to itself');
% if strcmp(button,'Yes')
%    frame = frame / absmx;
% end
levels = -1 : 0.1 : 1;

temp = frame;
data = zeros([x_size + 2, y_size + 2]);
data(2 : x_size + 1, 2 : y_size + 1) = temp;


axes(h); cla;
contourf(data, levels, 'LineStyle', 'none');
colormap(color_map);
%color_map = color_map;
%caxis([-0.3922 0.6155]);
caxis([-1 1]);
%caxis([min(min(frame)) max(max(frame))]); %% scale values to the frame itself.


set(h, 'XTick', [], 'YTick', [], 'YDir', 'Rev', 'DataAspectRatioMode', 'manual', ...
    'YLim', [1.5, y_size + 1.5], 'XLim', [1.5, x_size + 1.5], 'Color', 'k', 'DataAspectRatio', [1 1 1]);

for i = 1.5 : 1 : x_size + 1.5
    line([i, i], [1.5, x_size + 1.5], 'Color', [0 0 0]);
end
for j = 1.5 : 1 : y_size + 1.5
    line([1.5, y_size + 1.5], [j, j], 'Color', [0 0 0]);
end
end

function hfig = tightfig(hfig)
% tightfig: Alters a figure so that it has the minimum size necessary to
% enclose all axes in the figure without excess space around them.
% 
% Note that tightfig will expand the figure to completely encompass all
% axes if necessary. If any 3D axes are present which have been zoomed,
% tightfig will produce an error, as these cannot easily be dealt with.
% 
% hfig - handle to figure, if not supplied, the current figure will be used
% instead.

    if nargin == 0
        hfig = gcf;
    end

    % There can be an issue with tightfig when the user has been modifying
    % the contnts manually, the code below is an attempt to resolve this,
    % but it has not yet been satisfactorily fixed
%     origwindowstyle = get(hfig, 'WindowStyle');
    set(hfig, 'WindowStyle', 'normal');
    
    % 1 point is 0.3528 mm for future use

    % get all the axes handles note this will also fetch legends and
    % colorbars as well
    hax = findall(hfig, 'type', 'axes');
    
    % get the original axes units, so we can change and reset these again
    % later
    origaxunits = get(hax, 'Units');
    
    % change the axes units to cm
    set(hax, 'Units', 'centimeters');
    
    % get various position parameters of the axes
    if numel(hax) > 1
%         fsize = cell2mat(get(hax, 'FontSize'));
        ti = cell2mat(get(hax,'TightInset'));
        pos = cell2mat(get(hax, 'Position'));
    else
%         fsize = get(hax, 'FontSize');
        ti = get(hax,'TightInset');
        pos = get(hax, 'Position');
    end
    
    % ensure very tiny border so outer box always appears
    ti(ti < 0.1) = 0.15;
    
    % we will check if any 3d axes are zoomed, to do this we will check if
    % they are not being viewed in any of the 2d directions
    views2d = [0,90; 0,0; 90,0];
    
    for i = 1:numel(hax)
        
        set(hax(i), 'LooseInset', ti(i,:));
%         set(hax(i), 'LooseInset', [0,0,0,0]);
        
        % get the current viewing angle of the axes
        [az,el] = view(hax(i));
        
        % determine if the axes are zoomed
        iszoomed = strcmp(get(hax(i), 'CameraViewAngleMode'), 'manual');
        
        % test if we are viewing in 2d mode or a 3d view
        is2d = all(bsxfun(@eq, [az,el], views2d), 2);
               
        if iszoomed && ~any(is2d)
           error('TIGHTFIG:haszoomed3d', 'Cannot make figures containing zoomed 3D axes tight.') 
        end
        
    end
    
    % we will move all the axes down and to the left by the amount
    % necessary to just show the bottom and leftmost axes and labels etc.
    moveleft = min(pos(:,1) - ti(:,1));
    
    movedown = min(pos(:,2) - ti(:,2));
    
    % we will also alter the height and width of the figure to just
    % encompass the topmost and rightmost axes and lables
    figwidth = max(pos(:,1) + pos(:,3) + ti(:,3) - moveleft);
    
    figheight = max(pos(:,2) + pos(:,4) + ti(:,4) - movedown);
    
    % move all the axes
    for i = 1:numel(hax)
        
        set(hax(i), 'Position', [pos(i,1:2) - [moveleft,movedown], pos(i,3:4)]);
        
    end
    
    origfigunits = get(hfig, 'Units');
    
    set(hfig, 'Units', 'centimeters');
    
    % change the size of the figure
    figpos = get(hfig, 'Position');
    
    set(hfig, 'Position', [figpos(1), figpos(2), figwidth, figheight]);
    
    % change the size of the paper
    set(hfig, 'PaperUnits','centimeters');
    set(hfig, 'PaperSize', [figwidth, figheight]);
    set(hfig, 'PaperPositionMode', 'manual');
    set(hfig, 'PaperPosition',[0 0 figwidth figheight]);    
    
    % reset to original units for axes and figure 
    if ~iscell(origaxunits)
        origaxunits = {origaxunits};
    end

    for i = 1:numel(hax)
        set(hax(i), 'Units', origaxunits{i});
    end

    set(hfig, 'Units', origfigunits);
    
%      set(hfig, 'WindowStyle', origwindowstyle);
     
end